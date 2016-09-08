# Hacking

## Architecture

While evolving the architecture is basically as follows.

### World and areas

Area types are stored in the `areas` subdirectory. These are assigned to world locations by the world generator that runs when the game starts. The world generator is in `world.lua`.

#### world Table

This holds the general relationship between areas in the world, in XYZ coordinates, ordered Z,X,Y. Z=0 means surface-level. Yes, this is overly simplistic but it will do for now. Within each location is held all of the other information that is relevant for a generated area, including music and sound information, name information, map tiles and NPCs. This is what is used to populate the current area variables when the user changes areas within the game.

#### Current area variables

Variables at play at any given time in the current area include:

 * `maptiles` table: Holds data about map tile surface including walls, floor, stairs, and doors.
 * `characterX` integer: Player X location.
 * `characterY` integer: Player Y location.
 * `npcs` table: All NPC information including location, identity, status.
 * `groundobjects` table: All stuff lying on the ground.
