# NPCs

This directory contains all of the information for NPC characters.

The general structure is that a `npc_code.lua` file will be established in this directory, and that will reference other files in a subdirectory of the same name.

So for example, `dog.lua` references various media files in the `dog/` subdirectory.

These files are loaded by `npcs.lua` in the parent directory.
