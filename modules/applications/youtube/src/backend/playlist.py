"""
Handle playlist-related functionality.
"""

import csv
from pathlib import Path

from .shared import ABSOLUTE_YOUTUBE_DIR
from .urlparse import parse_yturl


def read_playlist(name: str | Path) -> list[str]:
    """
    Read a playlits' name (or path) and return the YouTube id's of each video 
    in the playlist.
    """

    if isinstance(name, Path) and name.exists() and name.suffix == ".txt":
        path = name
    else:
        path = ABSOLUTE_YOUTUBE_DIR / "playlists" / f"{name}.txt"

    with open(path, 'r') as csvfile:
        videoids = [
            parse_yturl(url) 
            for url in csv.reader(csvfile)
        ]

    return videoids