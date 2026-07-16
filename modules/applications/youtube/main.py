from argparse import ArgumentParser, Namespace
import ast 

from src.backend.playlist import read_playlist
from src.backend.urlparse import (YouTubeVideoID, 
                                  ParseError)
from src.backend.server import (YouTubeServer, 
                                build_server,)


def parse_args() -> Namespace:
    """Read CLI arguments and return parsed arguments."""

    parser = ArgumentParser()
    parser.add_argument('--urls', type=ast.literal_eval)
    parser.add_argument('--playlist', type=str)
    parser.add_argument('--domain', type=str, default="localhost")
    parser.add_argument('--port', type=int, default=8080)
    args = parser.parse_args()
    return args


def args_ytserver(args: Namespace) -> YouTubeServer:
    """Handle parsed arguments and build YouTubeServer from them."""

    # highest priority: playlist arg was passed
    plst: str = args.playlist
    if plst:
        videoids = read_playlist(plst)
        title = f"Playlist: {plst}"

    # a single youtube video was passed
    elif len(args.urls) == 1:
        [any_] = args.urls
        videoids = YouTubeVideoID.from_args(any_)
        title = "Single YouTube video"

    # serve temporary playlist
    else:
        videoids = [YouTubeVideoID.from_url(url) for url in args.urls]
        title = "Temporary Playlist"

    server: YouTubeServer = build_server(videoids, title,
                                         domain=args.domain,
                                         port=args.port)
    return server



def main():
    args = parse_args()
    server = args_ytserver(args)
    server.run()


if __name__ == "__main__":
    main()