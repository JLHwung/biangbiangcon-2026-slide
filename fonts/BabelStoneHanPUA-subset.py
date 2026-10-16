from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options
import sys

pua_map = [line.split(',') for line in Path(
    "./pua-ids.csv").read_text().splitlines()]
pua_characters = [int(ch, 16) for [ch, _] in pua_map if int(
    ch, 16) >= 0xE000 and int(ch, 16) <= 0xF8FF]

font_path = sys.argv[1]
font_bsh_pua = TTFont(font_path)
options = Options(glyph_names=True)
subsetter = Subsetter(options)
subsetter.populate(unicodes=pua_characters)
subsetter.subset(font_bsh_pua)

output_font_path = font_path.replace(".ttf", "-pua-subset.ttf")
font_bsh_pua.save(output_font_path)
