PHONY=all test

all: conway.wad

conway.wad: conway_nomapinfo.wad mapinfo.txt umapinfo.txt mancubus.bex
	python3 add_lumps.py -i conway_nomapinfo.wad -o $@ -z mapinfo.txt -u umapinfo.txt -d mancubus.bex

# Use ZokumBSP to build nodes, as it can be told to ignore invisible lines.
# And this way we can fit in standard NODES format.
conway_nomapinfo.wad: conway_nobsp.wad
	zokumbsp -ni -bi -rz $< -o $@ | grep -v ^cut$

conway_nobsp.wad: conway.wl
	wadccli -nosrc -o $@ $<

test: conway.wad
	prboom-plus -complevel 9 -warp 1 -file $<
