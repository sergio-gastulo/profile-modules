"""
Url-parsing related utils.
"""

import re
from urllib.parse import urlparse, parse_qs
from dataclasses import dataclass


class ParseError(ValueError):
    pass


def parse_yturl(youtubeurl: str) -> tuple[str, str | None]:
    """Map YouTube url to its id and playlist id, if existent.
    
    Arguments
    ---------
    youtubeurl
        Gets the videoid from the following patterns:
        * [ytdomain]/embed/[videoid][...]
        * [ytdomain]/watch/?v=[videoid][...]
        * [videoid]
        * /[videoid][...]
        * /[domain]/watch
    """

    parsed = urlparse(youtubeurl)
    playlist = None
    match parsed.path.strip("/").split("/"):

        case *_, "watch":
            if not hasattr(parsed, "query"):
                raise ParseError(
                    f"Url {youtubeurl!r} does not have 'query' attribute.")
            pquery = parse_qs(parsed.query)
            if "v" not in pquery:
                raise ParseError(f"No 'v' key on {pquery!r}.")
            if "list" in pquery:
                playlist = pquery["list"][0]
            videoid = pquery["v"][0]
        
        case "embed", videoid:
            pass
        case [videoid]:
            if hasattr(parsed, "query"):
                pquery = parse_qs(parsed.query)
                if "list" in pquery:
                    playlist = pquery["list"][0]

    pattern = re.compile(r"[0-9a-zA-Z_\-]{11}")
    if not pattern.match(videoid):
        raise ParseError(f"String {videoid!r} does not match pattern.")

    return videoid, playlist


@dataclass
class YouTubeVideoID:
    videoid: str | None = None
    playlist: str | None = None

    @classmethod
    def from_url(cls, url: str):
        videoid, playlist = parse_yturl(url)
        return cls(videoid=videoid, playlist=playlist)

    @classmethod
    def from_tuple(cls, videoid: str = None, playlist: str = None):
        return cls(videoid=videoid, playlist=playlist)

    @classmethod
    def from_args(cls, *args):
        match args:
            case [singlearg]:
                try:
                    return cls.from_url(singlearg)
                except ParseError:
                    cls.from_tuple(singlearg)
            case [vid, playlist]:
                cls.from_tuple(vid, playlist)
            case _:
                raise ParseError(f"Could not parse: {args!r}.")

    def build_url(self) -> str:
        if self.playlist:
            return f"{self.videoid}?list={self.playlist}"
        return self.videoid

    __repr__ = __str__ = build_url
