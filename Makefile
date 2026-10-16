VENV = .venv/bin

all: font
	latexmk -lualatex -synctex=1 -interaction=nonstopmode -file-line-error slide

$(VENV)/python: requirements.txt
	python3 -m venv .venv
	$(VENV)/pip install -r requirements.txt
	touch $@

ifndef CI
# Only rewritten when the set of characters changes, so the fonts below are
# rebuilt only when needed.
fonts/source-subset.txt: $(wildcard *.tex) main.bib pua-ids.csv | $(VENV)/python
	$(VENV)/python ./fonts/generate-source-subset.py

fonts/BabelStoneHanBasic-subset.ttf: fonts/BabelStoneHan-subset.py fonts/source-subset.txt fonts/BabelStoneHanBasic.ttf
	$(VENV)/python ./fonts/BabelStoneHan-subset.py ./fonts/BabelStoneHanBasic.ttf

fonts/BabelStoneHanExtra-subset.ttf: fonts/BabelStoneHan-subset.py fonts/source-subset.txt fonts/BabelStoneHanExtra.ttf pua-ids.csv
	$(VENV)/python ./fonts/BabelStoneHan-subset.py ./fonts/BabelStoneHanExtra.ttf

fonts/BabelStoneHanPUA-pua-subset.ttf: fonts/BabelStoneHanPUA-subset.py pua-ids.csv fonts/BabelStoneHanPUA.ttf
	$(VENV)/python ./fonts/BabelStoneHanPUA-subset.py ./fonts/BabelStoneHanPUA.ttf

fonts/BabelStoneHan-merged.ttf: pua-ids.csv fonts/BabelStoneHanBasic-subset.ttf fonts/BabelStoneHanExtra-subset.ttf fonts/BabelStoneHanPUA-pua-subset.ttf fonts/BabelStoneHan-merged.py
	$(VENV)/python ./fonts/BabelStoneHan-merged.py

# The source fonts are not in the repository, so the merged font is tracked as
# a UFO for CI; commit it whenever it changes.
fonts/BabelStoneHan-merged.ttf.ufo: fonts/BabelStoneHan-merged.ttf | $(VENV)/python
	rm -rf $@
	$(VENV)/extractufo $<

font: fonts/BabelStoneHan-merged.ttf fonts/BabelStoneHan-merged.ttf.ufo
endif

# Build font from the tracked UFO in CI mode
ifdef CI
fonts/BabelStoneHan-merged.ttf: fonts/BabelStoneHan-merged.ttf.ufo
	fontmake -u "./fonts/BabelStoneHan-merged.ttf.ufo" -o ttf --keep-overlaps --ttf-curves keep-quad --output-path ./fonts/BabelStoneHan-merged.ttf

font: fonts/BabelStoneHan-merged.ttf
endif

clean-tex:
	-rm -f $(addprefix slide.,aux log bbl blg bcf fls toc nav snm out run.xml fdb_latexmk synctex.gz)

clean-font:
	-rm -f fonts/*-subset.ttf fonts/*-merged.ttf fonts/source-subset.txt

clean: clean-tex clean-font

.PHONY: all font clean clean-tex clean-font
