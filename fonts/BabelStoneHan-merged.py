from pathlib import Path
from fontTools.merge import Merger
from fontTools.feaLib.builder import addOpenTypeFeaturesFromString


pua_map = [line.split(',') for line in Path(
    "./pua-ids.csv").read_text().splitlines()]
pua_characters = [int(ch, 16) for [ch, _] in pua_map]

merger = Merger()
font = merger.merge(["./fonts/BabelStoneHanBasic-subset.ttf", "./fonts/BabelStoneHanExtra-subset.ttf",
                    "./fonts/BabelStoneHanPUA-pua-subset.ttf"])

cmap = font.getBestCmap()
liga_features = []

for [ch, ids] in pua_map:
    pua_glyph_name = cmap.get(int(ch, 16))
    if pua_glyph_name:
        liga_features.append("sub " + " ".join(cmap.get(ord(ch))
                             for ch in ids) + " by " + pua_glyph_name + ";")
    else:
        print(ch + " may not be in pua-ids.csv.")

liga_feature_string = "feature liga {" + "\n".join(liga_features) + "} liga;"

addOpenTypeFeaturesFromString(font=font, features=liga_feature_string)

font.save("./fonts/BabelStoneHan-merged.ttf")
