"""
Core renderer. Selects the appropriate html page based on whether only a 
singleton is needed to be rendered or a playlist instead.
"""

from jinja2 import Template
from .shared import ABSOLUTE_YOUTUBE_DIR
from .urlparse import YouTubeVideoID

FRONTEND_DIR = ABSOLUTE_YOUTUBE_DIR / "src" / "frontend"


def render(
        videoid: YouTubeVideoID, 
        /,
        title: str | None = None
) -> str:
    """Render content as string from frontend."""

    name = "index.html.jinja"
    file = FRONTEND_DIR / name
    content = file.read_text(encoding='utf-8')
    template: Template = Template(content)
    
    showbuttons = not videoid.playlist
    if title is None and videoid.playlist:
        title = "Playlist fetched"

    vid = videoid.build_url()
    text = template.render(videoid=vid, 
                           title=title,
                           showbuttons=showbuttons)
    return text


def load_css() -> bytes:
    csspath = FRONTEND_DIR / "style.css"
    return csspath.read_bytes()
