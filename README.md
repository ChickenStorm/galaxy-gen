
# Galaxy generator in godot

Generation of spiral (Sa-Sb) galaxy in godot.  
Example using configuration 
```python
const NUMBER_OF_ARM = 5
const SCALE = 10.0 # scale for the drawing
#this is not the Node2D.scale
const NUMBER_OF_LONER_PER_ARM = 10
const NUMBER_OF_RANDOM_NODE = 10
const NUMBER_OF_SYSTEM_PER_NODE = 2
const MAX_ARM_DEPTH = 15
const ARM_EXTENTION_SCALE = 4.0 * pow(MAX_ARM_DEPTH/15.0,2.0)
const FINAL_ARM_ANGLE = 2.0 * PI
const MAX_DIST_NODE = SCALE * 4.0 # maximum distance between node in arm for interpolation
const NUMBER_OF_CORE_NODE = 30
const CORE_RANGE = 8.0 # max distance to create core node in units of SCALE 
```

![](https://cdn.discordapp.com/attachments/379029209156157441/723210090542399548/unknown.png)

Generation of galaxies for the project [Kalaxia](https://github.com/Kalaxia).

The generator is also being
[ported in rust](https://github.com/ablanleuil/galaxy-rs) and it generates `.las` file.
