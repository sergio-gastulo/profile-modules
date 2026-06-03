import sys
from pathlib import Path
import re
from http.server import (
    ThreadingHTTPServer, 
    BaseHTTPRequestHandler
)

from jinja2 import Template

class ParseError(Exception):
    pass


def parse_args(arg: list[str] | str) -> list[str] | str:
    if isinstance(arg, list) and isinstance(arg[0], str):
        return list(map(parse_args, arg))

    # ignore url arguments
    url = arg.split("&")[0]

    idpattern = re.compile(r"[0-9a-zA-Z_\-]{11}")
    m: list[str] = idpattern.findall(url)

    if len(m) != 1:
        raise ParseError(f"Several matches found with {url=}, aborting.")
    if not m:
        raise ParseError(f"No YouTube video id matches found for {url=}.")

    return m[0]


def get_static_content(videoids : list[str]) -> str:
    file = Path(__file__).parent / "index.html"
    content = file.read_text(encoding='utf-8')
    template : Template = Template(content)
    text = template.render(videoids=videoids)
    return text


def yt_server(videoids: list[str]):
    class YoutubeServer(BaseHTTPRequestHandler):
        def do_GET(self):
            try:
                content = get_static_content(videoids)
                self.send_response(200)
            except Exception:
                content = "File not found"
                self.send_response(404)
            self.end_headers()
            self.wfile.write(bytes(content, 'utf-8'))
    return YoutubeServer


def handler(port: int, server: BaseHTTPRequestHandler):
    domain = "localhost"
    class StoppableHTTPServer(ThreadingHTTPServer):
        def run(self):
            try:
                launch = f"Launching on http://{domain}:{port}."
                print(launch)
                self.serve_forever()
            except KeyboardInterrupt:
                print("Shutting down.")
            finally:
                self.server_close()
    return StoppableHTTPServer((domain, port), server)


def main():
    port = int(sys.argv.pop(1))
    urls = sys.argv[1:]
    videoids = parse_args(urls)
    ytserver = yt_server(videoids)

    server = handler(port, ytserver)
    server.run()


if __name__ == "__main__":
    main()