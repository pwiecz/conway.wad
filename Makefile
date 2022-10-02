PHONY=all test

all: conway.wad

conway.wad: conway.wl
	wadccli conway.wl
	bsp conway.wad -z -o conway_bsp.wad
	mv conway_bsp.wad conway.wad
	wadptr -c conway.wad -o conway_compressed.wad
	mv conway_compressed.wad conway.wad

test: conway.wad
	prboom-plus -complevel 9 -warp 1 -file conway.wad
