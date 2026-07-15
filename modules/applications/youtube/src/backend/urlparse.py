"""
Url-parsing related utils.
"""

import re
from urllib.parse import urlparse, parse_qs


class ParseError(ValueError):
    pass


def parse_yturl(youtubeurl: str) -> str:
    """Map YouTube url to its id.
    
    Arguments
    ---------
    youtubeurl
        Gets the videoid from the following patterns:
        * [domain]/embed/[videoid][...]
        * [domain]/watch/?v=[videoid][...]
        * [videoid]
    """

    parsed = urlparse(youtubeurl)
    match parsed.path.split("/"):
        
        case "", "watch":
            if not hasattr(parsed, "query"):
                raise ParseError(
                    f"Url {youtubeurl!r} does not have query attr.")
            pquery = parse_qs(parsed.query)
            if "v" not in pquery:
                raise ParseError(f"No 'v' key on url {youtubeurl!r}.")
            videoids = pquery["v"]
            if len(videoids) != 1:
                raise ParseError("More than one 'v' match.")
            videoid = videoids[0]

        case "", "embed", videoid:
            pass
        case videoid:
            pass

    pattern = re.compile(r"[0-9a-zA-Z_\-]{11}")
    if not pattern.match(videoid):
        raise ParseError(f"String {videoid!r} does not match pattern.")

    return videoid