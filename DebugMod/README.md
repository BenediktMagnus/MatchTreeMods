# Debug Mod for Match Tree

## Things This Mod Does

- Allows map editing.
- Enables the build-in cheat buttons for the world map and the level maps.
- Enables the build-in debugging visualisation for the level maps.
- Disables encryption for save games.

## How to Map Edit

When a level/map is loaded, right click on a tile with on of the following key combinations held results in:

- **C** + (**1** to **4**): Changes the tile to a carrot of size 1 to 4.
- **F** + (**1** to **4**): Changes the tile to a flower of size 1 to 4.
- **T** + (**1** to **4**): Changes the tile to a tree of size 1 to 4.
- **H** + (**1** to **2**): Changes the tile to a house of size 1 to 2.
- **0**: Removes the tile.

<br>

- **A** + (**1** to **4**): Moves the 1st to 4th fairy to the tile.
- **G** + (**1** to **4**): Moves the 1st to 4th gnome to the tile.
- **S** + (**1** to **4**): Moves the 1st to 4th sheep to the tile.
- **W** + (**1** to **4**): Moves the 1st to 4th witch to the tile.

## Addional Recommendations

For easier debugging, I recommend to add the following configs to the ModLoader's `override.cfg`:
```
run/flush_stdout_on_print=true
boot_splash/minimum_display_time=0
```
