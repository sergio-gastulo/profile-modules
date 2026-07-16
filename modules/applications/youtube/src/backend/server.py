"""
Core HTTPHandler and StoppableServer. This module should not provide any 
parsing. The behavior of the classes should rely entirely on whether a single
videoid, or a collections of videoids have been passed as arguments.
"""

import threading
from http import HTTPStatus
from http.server import (ThreadingHTTPServer, 
                         BaseHTTPRequestHandler)

from .urlparse import (YouTubeVideoID, 
                       ParseError)
from .render import render, load_css


def yt_http_handler(
        videoids: list[YouTubeVideoID],
        title: str,
) -> BaseHTTPRequestHandler:
    
    lock = threading.Lock()
    state = dict(index=0)

    class YouTubeHTTPHandler(BaseHTTPRequestHandler):

        def fail(self):
            self.send_response(HTTPStatus.NOT_FOUND)
            self.end_headers()
            self.wfile.write("Not Found!".encode())

        def send_css(self):
            self.send_response(HTTPStatus.OK)
            self.send_header('Content-Type', "text/css")
            self.end_headers()
            css_bytes = load_css()
            self.wfile.write(css_bytes)

        def do_GET(self):

            videoid = None
            match self.path.strip("/").split("/"):
                case [""]:
                    increment = 0
                case ["prev"]:
                    increment = -1
                case ["next"]:
                    increment = 1
                case ["favicon" | "favicon.ico"]:
                    self.fail()
                    return None
                case ["style.css"]:
                    self.send_css()
                    return None
                case [videoid]:
                    pass
                case _:
                    self.fail()
                    return None
            if not videoid:  # prev / next case
                with lock:  # update state
                    idx = state["index"] + increment
                    idx %= len(videoids)
                    state["index"] = idx
                # redirect
                videoid = videoids[idx]
                self.send_response(HTTPStatus.FOUND)
                self.send_header('Location', f"/{videoid}")
                self.end_headers()
                return None

            videoid = YouTubeVideoID.from_args(videoid)
            try:
                content = render(videoid, title=title)
            except Exception as e:
                content = f"Not Found!\nError:{e}"
                status = HTTPStatus.NOT_FOUND
            else:
                status = HTTPStatus.OK

            self.send_response(status)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(content.encode())

    return YouTubeHTTPHandler


def yt_http_wrapper(
        arg: YouTubeVideoID | list[YouTubeVideoID],
        title: str | None = None
) -> BaseHTTPRequestHandler:
    """
    Create YouTubeHTTPHandler depending on whether the passed argument is a 
    list of videoids or a singleton.
    """
    if isinstance(arg, YouTubeVideoID):
        videoid = [arg]
        title = "Single YouTube video" if not title else title
    elif isinstance(arg, list):
        videoid = arg
        title = "Playlist" if not title else title
    else:
        raise ValueError(f"Argument {arg!r} is not a list or YouTubeVideoID.")
    
    return yt_http_handler(videoid, title)


class YouTubeServer(ThreadingHTTPServer):
    """Create ThreadingHTTPServer for YoutubeHTTPHandler."""
    
    def run(self):
        domain, port = self.server_address
        print(f"Launching on http://{domain}:{port}.")
        try:
            self.serve_forever()
        except KeyboardInterrupt:
            print("Shutting down.")
        finally:
            self.server_close()


def build_server(
        videoid: YouTubeVideoID | list[YouTubeVideoID],
        /,
        title: str,
        *,
        domain: str = "localhost",
        port: int = 8080,
) -> YouTubeServer:
    """Build YouTube server pased on videoids and title."""

    handler = yt_http_wrapper(videoid, title)
    return YouTubeServer((domain, port), handler)