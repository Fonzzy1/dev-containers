import os
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
import time
import feedparser
import shutil
import pytz
import json
import requests
from mutagen.id3 import (
        ID3, 
    ID3NoHeaderError)

from mutagen.id3._frames import (
    APIC,
    TIT2,
    TPE1,
    TALB,
    TCON,
    TRCK,
    TPE2,
    USLT,
)
import argparse
import subprocess
from PIL import Image
from io import BytesIO
from tqdm import tqdm
from mutagen.mp3 import MP3

# Configuration
OPML_FILE = "/root/feeds/pods.opml"
DEST_FOLDER = "./Podcasts"
AUS_TZ = pytz.timezone("Australia/Sydney")
TEMP_COVER = "_temp_cover.jpg"
TEMP_DIR = "./temp"

def parse_opml(file):
    feeds = []
    tree = ET.parse(file)
    for outline in tree.findall(".//outline"):
        url = outline.attrib.get("xmlUrl")
        title = outline.attrib.get("title", outline.attrib.get("text", url))
        is_series = (
            outline.attrib.get("isSeries", "0") == "1"
        )  # Convert to boolean
        if url:
            feeds.append({"url": url, "title": title, "is_series": is_series})
    return feeds

def sanitize_filename(name):
    return "".join(c for c in name if c.isalnum() or c in " ._-").rstrip()

def is_episode_in_window(entry, window_start, window_end):
    dt = None
    if entry['published_parsed']:
        dt = datetime(*entry['published_parsed'][:6])
    if dt:
        dt = pytz.utc.localize(dt).astimezone(AUS_TZ)
        return window_start <= dt < window_end
    return False


def get_file_duration(path):
    """Get the actual duration of an MP3 file in seconds."""
    try:
        audio = MP3(path)
        return audio.info.length
    except Exception:
        return None


def parse_duration(duration):
    """Parse itunes_duration - can be seconds (int/str), HH:MM:SS, MM:SS, or H:MM:SS."""
    if not duration:
        return None
    
    if isinstance(duration, int):
        return duration
    
    duration = str(duration)
    parts = duration.split(':')
    
    if len(parts) == 1:
        # Just seconds
        try:
            return int(parts[0])
        except ValueError:
            return None
    elif len(parts) == 2:
        # MM:SS
        try:
            return int(parts[0]) * 60 + int(parts[1])
        except ValueError:
            return None
    elif len(parts) == 3:
        # HH:MM:SS
        try:
            return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])
        except ValueError:
            return None
    return None


def download(url, outpath):
    """Download with content-length header for size validation."""
    try:
        r = requests.get(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
            },
            stream=True,
            timeout=30,
        )
        r.raise_for_status()
        
        expected_size = int(r.headers.get('content-length', 0))
        
        with open(outpath, "wb") as f:
            for chunk in r.iter_content(1024 * 128):
                f.write(chunk)
        
        actual_size = os.path.getsize(outpath)
        
        return {
            "success": True,
            "expected_size": expected_size,
            "actual_size": actual_size
        }
    except requests.RequestException as e:
        print("Failed:", url, str(e))
        return {"success": False, "expected_size": 0, "actual_size": 0}


def ensure_jpeg(img_bytes):
    img = Image.open(BytesIO(img_bytes))
    if img.format != "JPEG":
        out = BytesIO()
        img.convert("RGB").save(out, format="JPEG")
        return out.getvalue()
    return img_bytes


def download_cover_image(url):
    if not url:
        return None
    try:
        resp = requests.get(url, timeout=20)
        resp.raise_for_status()
        jpeg_bytes = ensure_jpeg(resp.content)
        with open(TEMP_COVER, "wb") as f:
            f.write(jpeg_bytes)
        return TEMP_COVER
    except Exception:
        return None


def get_episode_image(entry):
    # 1. Try entry-level image fields
    img_url = None
    if "image" in entry:
        if isinstance(entry['image'], dict):
            img_url = entry['image'].get("href")
        elif isinstance(entry['image'], str):
            img_url = entry['image']
    if not img_url:
        if "media_thumbnail" in entry and entry['media_thumbnail']:
            img_url = entry['media_thumbnail'][0].get("url")
        elif "media_content" in entry and entry['media_content']:
            img_url = entry['media_content'][0].get("url")
    # It is possible entry has itunes_image
    if not img_url and hasattr(entry, "itunes_image"):
        img_url = entry['itunes_image']
    return img_url


def get_feed_image(feed):
    img_url = None
    # Try feed-level <image> (RSS)
    if hasattr(feed, "image"):
        img = feed.image
        if isinstance(img, dict):
            img_url = img.get("href") or img.get("url")
        elif hasattr(img, "href"):
            img_url = img.href
        elif hasattr(img, "url"):
            img_url = img.url
    # Try feed-level <itunes:image href="..."/>
    if not img_url and hasattr(feed, "itunes_image"):
        img_url = feed.itunes_image
    return img_url


def embed_metadata(
    mp3_path,
    artist,
    title,
    album,
    genre,
    track,
    cover_path,
    lyrics=None,
):
    try:
        id3 = ID3(mp3_path)
    except ID3NoHeaderError:
        id3 = ID3()

    id3.delall("APIC")
    id3.delall("USLT")

    id3.add(TIT2(encoding=3, text=str(title)))
    id3.add(TPE1(encoding=3, text=str(artist)))
    id3.add(TALB(encoding=3, text=str(album)))
    id3.add(TCON(encoding=3, text=str(genre)))
    id3.add(TRCK(encoding=3, text=str(track)))
    id3.add(TPE2(encoding=3, text="Various Podcasters"))

    if lyrics:
        id3.add(USLT(encoding=3, lang="eng", desc="Description", text=lyrics))

    if cover_path:
        ext = cover_path.lower().split(".")[-1]
        mime = "image/jpeg" if ext in ("jpg", "jpeg") else "image/png"

        with Image.open(cover_path) as img:
            img.thumbnail((600, 600), Image.LANCZOS)
            img_buffer = BytesIO()
            pil_format = "JPEG" if mime == "image/jpeg" else "PNG"
            img.save(img_buffer, format=pil_format)
            img_data = img_buffer.getvalue()

        id3.add(
            APIC(
                encoding=3,
                mime=mime,
                type=3,
                desc="Cover",
                data=img_data,
            )
        )

    id3.save(mp3_path, v2_version=3)

class DateTimeEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime):
            return {"__datetime__": True, "value": o.isoformat()}
        if isinstance(o, timedelta):
            return {"__timedelta__": True, "value": o.total_seconds()}
        return super().default(o)


def datetime_parser(dct):
    for key in ["start", "end"]:
        if key in dct and isinstance(dct[key], dict):
            if dct[key].get("__datetime__"):
                dct[key] = datetime.fromisoformat(dct[key]["value"])
            elif dct[key].get("__timedelta__"):
                dct[key] = timedelta(seconds=dct[key]["value"])
    return dct


def make_or_load_windows(today_9am):
    # See if there is a windows.json in TMP
    path = os.path.join(TEMP_DIR, today_9am.strftime('%Y-%m-%d'))
    if os.path.exists(path):
        with open(path, 'r') as f:
            return json.load(f, object_hook=datetime_parser)
    else:
        windows = make_windows(today_9am)
        files = os.listdir(TEMP_DIR)
        # Clean old ones
        for file in files:
            os.remove(os.path.join(TEMP_DIR, file))
        # Create new one
        with open(path, 'w') as f:
            json.dump(windows, f, cls=DateTimeEncoder)
        # Reload iso 
        return make_or_load_windows(today_9am)



def make_windows(today_9am):
    windows = {}
    for i in range(0, 3):
        date = today_9am - timedelta(days=i)
        windows[date.strftime("%Y-%m-%d")] = {
            "start": date - timedelta(days=1),
            "end": date,
            "episodes": [],
            "album_name": f"{date.strftime('%Y-%m-%d')} Podcasts",
        }

    feeds = parse_opml(OPML_FILE)

    # Collect episodes
    for feed_idx, feed in tqdm(
        enumerate(feeds), total=len(feeds), desc="Fetching Episode Data"
    ):
        parsed = feedparser.parse(feed["url"])

        for entry in parsed.entries:
            feed_title = feed["title"]
            is_series = feed["is_series"]

            if is_series:
                # Always download, assign to a dedicated series album
                album_name = sanitize_filename(feed_title[:40])
                windows.setdefault(
                    album_name, {"episodes": [], "album_name": album_name}
                )
                windows[album_name]["episodes"].append(
                    {
                        "feed_pos": feed_idx,
                        "feed_title": feed_title,
                        "feed": parsed.feed,
                        "entry": entry,
                    }
                )
            else:
                # Existing time window logic
                for k, v in windows.items():
                    if is_episode_in_window(entry, v["start"], v["end"]):
                        windows[k]["episodes"].append(
                            {
                                "feed_pos": feed_idx,
                                "feed_title": feed_title,
                                "feed": parsed.feed,
                                "entry": entry,
                            }
                        )
    return windows





def main():
    parser = argparse.ArgumentParser(
        description="Podcast downloader and tagger"
    )
    parser.add_argument(
        "-m",
        "--music",
        action="store_true",
        help="Sync /Music from computer to ./Music on this device",
    )
    args = parser.parse_args()
    
    # Clean up any failed downloads from previous runs
    
    # Time window: 9AM YESTERDAY to 9AM TODAY (Sydney)
    now = datetime.now(AUS_TZ)


    today_9am = now.replace(hour=9, minute=0, second=0, microsecond=0)
    if now < today_9am:
        today_9am -= timedelta(days=1)

    windows = make_or_load_windows(today_9am)


    os.makedirs(DEST_FOLDER, exist_ok=True)
    all_tracks = []

    for date, v in windows.items():
        os.makedirs(os.path.join(DEST_FOLDER, date), exist_ok=True)
        episodes = windows[date]["episodes"]
        episodes.sort(
            key=lambda e: (
                e["feed_pos"],
                e["entry"].get( "published_parsed", (0, 0, 0, 0, 0, 0)))
        )
        for track_idx, item in tqdm(
            enumerate(episodes, start=1),
            total=len(episodes),
            desc=f"Downloading Episodes for {date}",
        ):
            entry = item["entry"]
            feed_title = item["feed_title"]
            feed = item["feed"]

            # File setup
            ext = "mp3"
            if entry['links']:
                audio_url = [x for x in entry['links'] if 'audio' in x.get('type')][0].get('href')
            else:
                print("No enclosure found for", entry['title'])
                continue

            base = (
                str(track_idx).zfill(3)
                + "_"
                + sanitize_filename(feed_title[:40])
                + "_"
                + sanitize_filename(entry['title'][:50])
            )
            filename = f"{base}.{ext}"
            outpath = os.path.join(DEST_FOLDER, date, filename)
            all_tracks.append(outpath)

            already_downloaded = os.path.exists(outpath)
            
            # Check if existing file is valid (compare actual duration to expected)
            valid = False
            if already_downloaded:
                # Try to get duration from file itself
                file_duration = get_file_duration(outpath)
                if file_duration:
                    expected_duration = parse_duration(entry.get('itunes_duration'))
                    if expected_duration:
                        # Allow 10% tolerance
                        if file_duration >= expected_duration * 0.9:
                            valid = True
                        else:
                            print(f"File duration {file_duration:.0f}s < expected {expected_duration}s, re-downloading...")
                            os.remove(outpath)
                            already_downloaded = False
                    else:
                        # No expected duration, but file is valid if we can read it
                        valid = True
                else:
                    # Can't read file, likely corrupted - re-download
                    print(f"Cannot read file duration, re-downloading...")
                    os.remove(outpath)
                    already_downloaded = False
            
            if not already_downloaded or not valid:
                max_retries = 3
                for attempt in range(max_retries):
                    result = download(audio_url, outpath)
                    if not result["success"]:
                        print(f"Attempt {attempt + 1}/{max_retries} failed:", audio_url)
                        if attempt < max_retries - 1:
                            time.sleep(2)
                        continue
                    
                    # Validate downloaded size against Content-Length
                    if result["expected_size"] > 0:
                        actual_size = os.path.getsize(outpath)
                        if actual_size < result["expected_size"] * 0.9:
                            print(f"Attempt {attempt + 1}/{max_retries}: size mismatch {actual_size} < {result['expected_size']}, re-downloading...")
                            os.remove(outpath)
                            if attempt < max_retries - 1:
                                time.sleep(2)
                            continue
                    
                    # Success
                    break
                else:
                    print("All download attempts failed for", audio_url)
                    continue

                # Try episode image, then feed image, then fallback
                img_url = get_episode_image(entry)
                cover_path = download_cover_image(img_url)
                if not cover_path:
                    feed_img_url = get_feed_image(feed)
                    cover_path = download_cover_image(feed_img_url)
                if not cover_path:
                    # Use local fallback only if nothing else available
                    cover_path = None
                embed_metadata(
                    outpath,
                    artist=feed_title,
                    title=entry['title'],
                    album=v["album_name"],
                    genre="pods",
                    track=track_idx,
                    cover_path=cover_path,
                    lyrics=entry.get("summary", "")
                    or entry.get("description", ""),
                )
    # Clean up
    if os.path.isfile(TEMP_COVER):
        os.remove(TEMP_COVER)
    for folder in os.listdir(DEST_FOLDER):
        if not folder in windows.keys():
            shutil.rmtree(os.path.join(DEST_FOLDER, folder))

    if args.music:
        source_music_dir = "/Music"
        local_music_folder = (
            "./Music"  # On the device, where you run the script
        )
        os.makedirs(local_music_folder, exist_ok=True)

        print(
            f"Syncing music from {source_music_dir} to {local_music_folder} ..."
        )
        try:
            subprocess.run(
                [
                    "rsync",
                    "-avu",  # archive, verbose, update only
                    "--info=progress2",
                    source_music_dir + "/",  # Always /Music on computer
                    os.path.abspath(local_music_folder) + "/",
                ],
                check=True,
            )
            print("Music sync complete.")
        except subprocess.CalledProcessError as e:
            print("Rsync failed:", e)


if __name__ == "__main__":
    main()
