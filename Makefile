PHONY=all test

all: conway.wad

#conway.wad: conway_nonoptimized.wad
#	wadptr -c $< -o $@onway.wad
 
conway.wad: conway_nobsp.wad
	bsp $< -R -z -o $@

conway_nobsp.wad: conway.wl
	wadccli -nosrc -o $@ $<

test: conway.wad
	prboom-plus -complevel 9 -warp 1 -file $<
