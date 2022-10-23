# conway.wad
Boom-compatible WAD for playing [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
Tested a bit in PrBoom+ and GzDoom.

Right now requires a hacked version of WadC to be built (http://github.com/pwiecz/wadc).

# How to play
Pick a [Boom-compatible](https://doomwiki.org/wiki/Comparison_of_source_ports#Comparison_by_compatibility) Doom source port,
such us [PrBoom+](https://github.com/coelckers/prboom-plus/releases), [GzDoom](https://zdoom.org/downloads), [DSDA-Doom](https://github.com/kraflab/dsda-doom), [Woof](https://github.com/fabiangreffrath/woof/releases) or one of many others.

Install Doom II e.g. from [GOG](https://www.gog.com/en/game/doom_ii) or [Steam](https://store.steampowered.com/app/2300/DOOM_II/).

Download `conway.wad` file from this repository.

Load the `conway.wad` into the Doom source port - e.g. to use PrBoom+ from you can run:

```prboom-plus -complevel 9 -warp 1 -file conway.wad```

Run over raised pedestals to make corresponding cells alive. Pull the switch to start the simulation.
