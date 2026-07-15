"""
Core HTTPHandler and StoppableServer. This module should not provide any 
parsing. The behavior of the classes should rely entirely on whether a single
videoid, or a collections of videoids have been passed as arguments.
"""

from http import HTTPStatus
from http.server import (ThreadingHTTPServer, 
                         BaseHTTPRequestHandler)
import threading

from .render import render


def _singleton_ythttp_handler(
        videoid: str,
        title: str = "Single Video"
) -> BaseHTTPRequestHandler:
    """Handle single YouTube Server HTTP Request."""

    class YouTubeHTTPHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            try:
                content = render(videoid, title=title)
            except Exception as e:
                content = f"Not Found!\nError: {e}."
                status = HTTPStatus.NOT_FOUND
            else:
                status = HTTPStatus.OK
            self.send_response(status)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(content.encode())
    
    return YouTubeHTTPHandler


def _list_ythttp_handler(
        videoids: list[str],
        title: str,
) -> BaseHTTPRequestHandler:
    
    lock = threading.Lock()
    state = dict(index=0)

    class YouTubeHTTPHandler(BaseHTTPRequestHandler):
        def do_GET(self):

            videoid = None
            match self.path.split("/"):
                case ["", ""]:
                    increment = 0
                case ["", "prev"]:
                    increment = -1
                case ["", "next-color"]:
                    increment = 1
                case ["", arg]:
                    videoid = arg
                case _:
                    self.send_response(HTTPStatus.NOT_FOUND)
                    self.end_headers()
                    self.wfile.write("Not Found!".encode())
                    return None

            if not videoid:
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

            try:
                content = render(videoid, isplaylist=True, title=title)
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


def yt_http_handler(
        videoids: str | list[str],
        title: str | None = None
) -> BaseHTTPRequestHandler:
    """
    Create YouTubeHTTPHandler depending on whether the passed argument is a 
    list of videoids or a singleton.
    """
    if isinstance(videoids, str):
        return _singleton_ythttp_handler(videoids, title)
    if isinstance(videoids, list):
        return _list_ythttp_handler(videoids, title)
    raise ValueError(f"Argument {videoids!r} is not a list or str.")


class YouTubeServer(ThreadingHTTPServer):
    """Create ThreadingHTTPServer for YoutubeHTTPHandler."""
    
    def run(self):
        domain, port = self.server_address
        launch = f"Launching on http://{domain}:{port}."
        print(launch)
        try:
            self.serve_forever()
        except KeyboardInterrupt:
            print("Shutting down.")
        finally:
            self.server_close()
