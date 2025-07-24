import os
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
import feedparser
import pytz
import requests
from mutagen.easyid3 import EasyID3
from mutagen.mp3 import MP3
from mutagen.id3 import APIC
from mutagen.id3 import ID3, ID3NoHeaderError, APIC
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
    for outline in tree.findall('.//outline'):
        url = outline.attrib.get('xmlUrl')
        title = outline.attrib.get('title', outline.attrib.get('text', url))
        if url:
            feeds.append({'url': url, 'title': title})
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
        r = requests.get(url, stream=True, timeout=30)
        r.raise_for_status()
        with open(outpath, 'wb') as f:
            for chunk in r.iter_content(1024*128):
                f.write(chunk)
        return True
    except Exception as e:
        print("Failed:", url, str(e))
        return False

def ensure_jpeg(img_bytes):
    img = Image.open(BytesIO(img_bytes))
    if img.format != 'JPEG':
        out = BytesIO()
        img.convert("RGB").save(out, format="JPEG")
        return out.getvalue()
    return img_bytes

def download_cover_image(url):
    if not url: return None
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
    if 'image' in entry:
        if isinstance(entry.image, dict):
            img_url = entry.image.get('href')
        elif isinstance(entry.image, str):
            img_url = entry.image
    if not img_url:
        if 'media_thumbnail' in entry and entry.media_thumbnail:
            img_url = entry.media_thumbnail[0].get('url')
        elif 'media_content' in entry and entry.media_content:
            img_url = entry.media_content[0].get('url')
    # It is possible entry has itunes_image
    if not img_url and hasattr(entry, 'itunes_image'):
        img_url = entry.itunes_image
    return img_url

def get_feed_image(feed):
    img_url = None
    # Try feed-level <image> (RSS)
    if hasattr(feed, 'image'):
        img = feed.image
        if isinstance(img, dict):
            img_url = img.get('href') or img.get('url')
        elif hasattr(img, 'href'):
            img_url = img.href
        elif hasattr(img, 'url'):
            img_url = img.url
    # Try feed-level <itunes:image href="..."/>
    if not img_url and hasattr(feed, 'itunes_image'):
        img_url = feed.itunes_image
    return img_url

def embed_metadata(mp3_path, artist, title, album, genre, track, total_tracks,cover_path):
    # Ensure EasyID3 header exists
    try:
        audio = MP3(mp3_path, ID3=EasyID3)
    except ID3NoHeaderError:
        # Create ID3 tag if not present
        EasyID3.register_text_key('albumartist', 'TPE2')
        audio = MP3(mp3_path)
        audio.add_tags(ID3=EasyID3)
        audio = MP3(mp3_path, ID3=EasyID3)
    
    audio["artist"] = artist
    audio["album"] = album
    audio["title"] = title
    audio["genre"] = genre
    audio["tracknumber"] = "{}/{}".format(track, total_tracks)
    audio["albumartist"] = 'Various Podcasters'
    audio.save()

    # Now work with the full ID3 tag for APIC etc.
    try:
        id3 = ID3(mp3_path)
    except ID3NoHeaderError:
        id3 = ID3()
    
    for frame in list(id3.getall('TXXX')):
        if 'podcast' in (frame.desc or '').lower():
            id3.delall('TXXX:' + frame.desc)

    if cover_path:
        with open(cover_path, "rb") as img:
            id3.delall('APIC')
            id3.add(
                APIC(
                    encoding=3,  # 3 is for utf-8  
                    mime='image/jpeg',
                    type=3,  # Front cover
                    desc=u'Cover',
                    data=img.read()
                )
            )
    id3.save(mp3_path, v2_version=3)

def main():
    parser = argparse.ArgumentParser(description="Podcast downloader and tagger")
    parser.add_argument('-m', '--music', action='store_true', help='Sync /Music from computer to ./Music on this device')
    args = parser.parse_args()
    # Time window: 9AM YESTERDAY to 9AM TODAY (Sydney)
    now = datetime.now(AUS_TZ)
    today_9am = now.replace(hour=9, minute=0, second=0, microsecond=0)
    if now < today_9am:
        today_9am -= timedelta(days=1)
    window_start = today_9am - timedelta(days=1)
    window_end = today_9am

    album_date = (today_9am - timedelta(days=0)).date()  # window_end's date
    album_name = f"{album_date} Podcasts"

    feeds = parse_opml(OPML_FILE)
    os.makedirs(DEST_FOLDER, exist_ok=True)

    episodes = []

    # Collect episodes
    for feed_idx, feed in tqdm(enumerate(feeds),total=len(feeds), desc="Fetching Episode Data"):
        parsed = feedparser.parse(feed['url'])
        for entry in parsed.entries:
            if is_episode_in_window(entry, window_start, window_end):
                episodes.append({
                    'feed_pos': feed_idx,
                    'feed_title': feed['title'],
                    'feed': parsed.feed,
                    'entry': entry
                })

    print(f"{len(episodes)} episodes to process ({window_start} to {window_end}).")

    episodes.sort(key=lambda e: (e['feed_pos'], getattr(e['entry'],"published_parsed", (0,0,0,0,0,0))))

    for track_idx, item in tqdm(enumerate(episodes, start=1),total=len(episodes), desc='Downloading Episodes'):
        entry = item['entry']
        feed_title = item['feed_title']
        feed = item['feed']

        # File setup
        ext = "mp3"
        if 'enclosures' in entry and entry.enclosures:
            audio_url = entry.enclosures[0].get('url')
            if audio_url and '.' in audio_url.split("?")[0]:
                ext = audio_url.split('.')[-1].split('?')[0]
        else:
            print("No enclosure found for", entry.title)
            continue

        base = sanitize_filename(feed_title[:40]) + "_" + sanitize_filename(entry.title[:50])
        filename = f"{base}.{ext}"
        outpath = os.path.join(DEST_FOLDER, filename)
        print(f"[{track_idx}/{len(episodes)}] Downloading: {feed_title} - {entry.title}")

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
            artist = feed_title,
            title= entry.title,
            album = album_name,
            genre = "pods",
            track = track_idx,
            total_tracks = len(episodes),
            cover_path = cover_path
        )
        print("Done:", filename)
    # Clean up
    if os.path.isfile(TEMP_COVER):
        os.remove(TEMP_COVER)
    print(f"Downloaded and tagged {len(episodes)} episode(s). Saved in {os.path.abspath(DEST_FOLDER)}")

    if args.music:
        source_music_dir = "/Music"
        local_music_folder = "./Music"           # On the device, where you run the script
        os.makedirs(local_music_folder, exist_ok=True)

        print(f"Syncing music from {source_music_dir} to {local_music_folder} ...")
        try:
            subprocess.run([
                "rsync",
                "-avu",           # archive, verbose, update only
                "--progress",
                "--include=*.mp3", "--include=*/", "--exclude=*",
                source_music_dir + "/",            # Always /Music on computer
                os.path.abspath(local_music_folder) + "/"
            ], check=True)
            print("Music sync complete.")
        except subprocess.CalledProcessError as e:
            print("Rsync failed:", e)

if __name__ == "__main__":
    main()
