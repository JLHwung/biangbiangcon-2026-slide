from glob import glob
from pathlib import Path

source_globs = ['*.tex', 'main.bib', 'pua-ids.csv']

source_characters = "".join(sorted(list(set(ch for _glob in source_globs for path in glob(
    _glob, recursive=True) for line in Path(path).read_text().splitlines() if not line.startswith("%") for ch in line))))

cached_source_characters_path = Path('./fonts/source-subset.txt')
cached_source_characters = ''
if not cached_source_characters_path.exists():
    with open(cached_source_characters_path, 'w') as f:
        pass
cached_source_characters = cached_source_characters_path.read_text()
if source_characters != cached_source_characters:
    cached_source_characters_path.write_text(source_characters)
