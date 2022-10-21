PHONY=all test

all: conway.wad

conway.wad: conway_nomapinfo.wad mapinfo.txt umapinfo.txt mancubus.bex
	python3 add_lumps.py -i conway_nomapinfo.wad -o $@ -z mapinfo.txt -u umapinfo.txt -d mancubus.bex

conway_zokumbsp.wad: conway_nobsp.wad
	zokumbsp -ni -bi $< -o $@ | grep -v ^cut$

conway_nomapinfo.wad: conway_nobsp.wad
	bsp $< -w -R -o $@

conway_nobsp.wad: conway.wl
	wadccli -nosrc -o $@ $<

test: conway.wad
	prboom-plus -complevel 9 -warp 1 -file $<
