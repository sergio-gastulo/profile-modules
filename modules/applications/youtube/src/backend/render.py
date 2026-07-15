"""
Core renderer. Selects the appropriate html page based on whether only a 
singleton is needed to be rendered or a playlist instead.
"""

from jinja2 import Template
from .shared import ABSOLUTE_YOUTUBE_DIR


def render(
        videoid: str, 
        /,
        isplaylist: bool = False,
        title: str | None = None
) -> str:
    """Render content as string from frontend."""

    name = "ytplaylist.html" if isplaylist else "ytvideo.html"
    file = ABSOLUTE_YOUTUBE_DIR / "frontend" / name
    content = file.read_text(encoding='utf-8')
    template: Template = Template(content)
    
    if isplaylist and title is None:
        title = "Temporary Playlist"

    text = template.render(videoid=videoid, title=title)

    return text