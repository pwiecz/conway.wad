PHONY=all test

all: conway.wad

conway.wad: conway_nomapinfo.wad mapinfo.txt
	python3 add_mapinfo.py -i conway_nomapinfo.wad -o $@ -m mapinfo.txt -u umapinfo.txt

#conway_nomapinfo.wad: conway_nonoptimized.wad
#	wadptr -c $< -o $@

conway_nomapinfo.wad: conway_nobsp.wad
	bsp $< -R -z -o $@

conway_nobsp.wad: conway.wl
	wadccli -nosrc -o $@ $<

test: conway.wad
	prboom-plus -complevel 9 -warp 1 -file $<
