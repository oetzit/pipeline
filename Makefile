#==[ Convenience targets ]======================================================

all: source target

clean:
	rm -rf source

clobber: clean
	rm -rf target

#==[ Python environment setup ]=================================================

venv:
	python3 -m venv --prompt oetzit-pipeline $@
	. $@/bin/activate && pip install -r requirements.txt

#==[ Source data retrieval ]====================================================

source/words.csv \
source/games.csv \
source/clues.csv \
source/shots.csv \
source/devices.csv:
	mkdir -p $(dir $@)
	bash scripts/k8s-psql-copy.sh $(notdir $(basename $@)) $@

source: \
	source/words.csv \
	source/games.csv \
	source/clues.csv \
	source/shots.csv \
	source/devices.csv

#==[ Target data production ]===================================================

target/%.csv: source/%.csv
	mkdir -p $(dir $@)
	python3 scripts/prepare-data.py $< $@

target: \
	target/words.csv \
	target/games.csv \
	target/clues.csv \
	target/shots.csv \
	target/devices.csv
