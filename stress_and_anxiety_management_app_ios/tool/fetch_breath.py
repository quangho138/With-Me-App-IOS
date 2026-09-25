import urllib.request,re
from pathlib import Path
page=urllib.request.urlopen('https://freesound.org/people/rrehl/sounds/717167/').read().decode()
Path('tool/breath-source.html').write_text(page,encoding='utf-8')
print('\n'.join(re.findall(r'https[^\s\"<>]+(?:mp3|ogg)',page)))
