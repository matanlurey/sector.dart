# Pathfinding Benchmarks: File Formats

See <https://movingai.com/benchmarks/formats.html>, but tl;dr in case taken
offline.

## Map Format

All maps begin with the lines:

```txt
type octile
height y
width x
map
```

The map data is store as an ASCII grid. The upper-left corner of the map is
(0,0). The following characters are possible:

```txt
. - passable terrain
G - passable terrain
@ - out of bounds
O - out of bounds
T - trees (unpassable)
S - swamp (passable from regular terrain)
W - water (traversable, but not passable from terrain)
```

## Scenario Format

The scenario files have the following format.

- The begin with the text "version x.x". This document describes version 1.0.
  The trailing 0 is optional.
- Each line of a scenario has 9 fields:

Bucket | map | map width | map height | start x-coordinate | start y-coordinate | goal x-coordinate | goal y-coordinate | optimal length
--- | --- | --- | --- | --- | --- | --- | --- | ---
0 | maps/dao/arena.map | 49 | 49 | 1 | 11 | 1 | 12 | 1
0 | maps/dao/arena.map | 49 | 49 | 1 | 13 | 4 | 12 | 3.41421

Notes:

- The optimal path length is assuming sqrt(2) diagonal costs
- The optimal path length assumes agents cannot cut corners through walls
- If the map height/width do not match the file, it should be scaled to that size
- (0, 0) is in the upper left corner of the maps
- Technically a single scenario file can have problems from many different maps,
  but currently every scenario only contains problems from a single map
