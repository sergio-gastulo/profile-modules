"""
Handle playlist-related functionality.
"""

from pathlib import Path

from .shared import ABSOLUTE_YOUTUBE_DIR
from .urlparse import parse_yturl, YouTubeVideoID


def read_playlist(name: str | Path) -> list[YouTubeVideoID]:
    """
    Read a playlits' name (or path) and return the YouTube id's of each video 
    in the playlist.
    """

    if isinstance(name, Path) and name.exists() and name.suffix == ".txt":
        path = name
    else:
        path = ABSOLUTE_YOUTUBE_DIR / "playlists" / f"{name}.txt"

    with open(path, 'r') as file:
        urls = file.read().splitlines()
        
    return [parse_yturl(url) for url in urls]


