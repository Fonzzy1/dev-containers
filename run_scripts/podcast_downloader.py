import os
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
import feedparser
import shutil
import pytz
import requests
from mutagen.id3 import (
    ID3,
    APIC,
    TIT2,
    TPE1,
    TALB,
    TCON,
    TRCK,
    TPE2,
    ID3NoHeaderError,
)
import argparse
import subprocess
from PIL import Image
from io import BytesIO
from tqdm import tqdm
from mutagen.id3 import ID3

# Configuration
OPML_FILE = "/root/.pods.opml"
DEST_FOLDER = "./Podcasts"
AUS_TZ = pytz.timezone("Australia/Sydney")
TEMP_COVER = "_temp_cover.jpg"


def parse_opml(file):
    feeds = []
    tree = ET.parse(file)
    for outline in tree.findall(".//outline"):
        url = outline.attrib.get("xmlUrl")
        title = outline.attrib.get("title", outline.attrib.get("text", url))
        if url:
            feeds.append({"url": url, "title": title})
    return feeds


def sanitize_filename(name):
    return "".join(c for c in name if c.isalnum() or c in " ._-").rstrip()


def is_episode_in_window(entry, window_start, window_end):
    dt = None
    if hasattr(entry, "published_parsed") and entry.published_parsed:
        dt = datetime(*entry.published_parsed[:6])
    if dt:
        dt = pytz.utc.localize(dt).astimezone(AUS_TZ)
        return window_start <= dt < window_end
    return False


def download(url, outpath):
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
        with open(outpath, "wb") as f:
            for chunk in r.iter_content(1024 * 128):
                f.write(chunk)
        return True
    except Exception as e:
        print("Failed:", url, str(e))
        return False


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
        if isinstance(entry.image, dict):
            img_url = entry.image.get("href")
        elif isinstance(entry.image, str):
            img_url = entry.image
    if not img_url:
        if "media_thumbnail" in entry and entry.media_thumbnail:
            img_url = entry.media_thumbnail[0].get("url")
        elif "media_content" in entry and entry.media_content:
            img_url = entry.media_content[0].get("url")
    # It is possible entry has itunes_image
    if not img_url and hasattr(entry, "itunes_image"):
        img_url = entry.itunes_image
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
    mp3_path, artist, title, album, genre, track, total_tracks, cover_path
):
    try:
        id3 = ID3(mp3_path)
    except ID3NoHeaderError:
        id3 = ID3()

    id3.delall("APIC")

    id3.add(TIT2(encoding=3, text=str(title)))
    id3.add(TPE1(encoding=3, text=str(artist)))
    id3.add(TALB(encoding=3, text=str(album)))
    id3.add(TCON(encoding=3, text=str(genre)))
    id3.add(TRCK(encoding=3, text=f"{track}/{total_tracks}"))
    id3.add(TPE2(encoding=3, text="Various Podcasters"))

    if cover_path:
        ext = cover_path.lower().split(".")[-1]
        mime = "image/jpeg" if ext in ("jpg", "jpeg") else "image/png"

        # Open and resize the image
        with Image.open(cover_path) as img:
            img.thumbnail(
                (600, 600), Image.LANCZOS
            )  # Resize while maintaining aspect ratio
            # Save to a buffer in the original format
            img_buffer = BytesIO()
            pil_format = "JPEG" if mime == "image/jpeg" else "PNG"
            img.save(img_buffer, format=pil_format)
            img_data = img_buffer.getvalue()

        # Embed image
        id3.add(
            APIC(
                encoding=3,
                mime=mime,
                type=3,  # front cover
                desc="Cover",
                data=img_data,
            )
        )

    id3.save(mp3_path, v2_version=3)


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
    # Time window: 9AM YESTERDAY to 9AM TODAY (Sydney)
    now = datetime.now(AUS_TZ)

    windows = {}
    today_9am = now.replace(hour=9, minute=0, second=0, microsecond=0)
    if now < today_9am:
        today_9am -= timedelta(days=1)
    for i in range(0, 6):
        date = today_9am - timedelta(days=i)
        windows[date.strftime("%Y-%m-%d")] = {
            "start": date - timedelta(days=1),
            "end": date,
            "episodes": [],
            "album_name": f"{date.strftime('%Y-%m-%d')} Podcasts",
        }

    feeds = parse_opml(OPML_FILE)
    os.makedirs(DEST_FOLDER, exist_ok=True)

    # Collect episodes
    for feed_idx, feed in tqdm(
        enumerate(feeds), total=len(feeds), desc="Fetching Episode Data"
    ):
        parsed = feedparser.parse(feed["url"])
        for entry in parsed.entries:
            for k, v in windows.items():
                if is_episode_in_window(entry, v["start"], v["end"]):
                    windows[k]["episodes"].append(
                        {
                            "feed_pos": feed_idx,
                            "feed_title": feed["title"],
                            "feed": parsed.feed,
                            "entry": entry,
                        }
                    )

    all_tracks = []
    for date, v in windows.items():
        os.makedirs(os.path.join(DEST_FOLDER, date), exist_ok=True)
        windows[date]["episodes"].sort(
            key=lambda e: (
                e["feed_pos"],
                getattr(e["entry"], "published_parsed", (0, 0, 0, 0, 0, 0)),
            )
        )
        for track_idx, item in tqdm(
            enumerate(v["episodes"], start=1),
            total=len(v["episodes"]),
            desc=f"Downloading Episodes for {date}",
        ):
            entry = item["entry"]
            feed_title = item["feed_title"]
            feed = item["feed"]

            # File setup
            ext = "mp3"
            if "enclosures" in entry and entry.enclosures:
                audio_url = entry.enclosures[0].get("url")
                if audio_url and "." in audio_url.split("?")[0]:
                    ext = audio_url.split(".")[-1].split("?")[0]
            else:
                print("No enclosure found for", entry.title)
                continue

            base = (
                sanitize_filename(feed_title[:40])
                + "_"
                + sanitize_filename(entry.title[:50])
            )
            filename = f"{base}.{ext}"
            outpath = os.path.join(DEST_FOLDER, date, filename)
            all_tracks.append(outpath)

            already_downloaded = os.path.exists(outpath)
            if not already_downloaded:
                if not download(audio_url, outpath):
                    print("Failed to download", audio_url)
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
                title=entry.title,
                album=v["album_name"],
                genre="pods",
                track=track_idx,
                total_tracks=len(v["episodes"]),
                cover_path=cover_path,
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
