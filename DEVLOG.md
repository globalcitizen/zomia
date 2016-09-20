# Development log

 * __2016-09-20__:
    - Default initial character placements at stairs
    - Play downstairs noise at start
    - Fade in at start
    - Stairs remain visible on the map after being seen

 * __2016-09-19__:
    - Fix bug where monsters can move to player's new location if a door is opened by the player
    - Implement some doors randomly being pre-opened when generating `natural_cavern`

 * __2016-09-18__ (D-day, 17 days used):
    - Enable modal dialogs
       - Create/test/debug a generic selection mechanism for modal dialogs
    - Adjust difficulty (remove bears from upper levels)
    - Switch to double-size fonts for readability in response to user feedback
    - Downloaded more samples (mostly female death noises, some others)
    - Reset groundfeatures on map change
    - Linecount 6351
    - Made v0.0.2 (Final ARRP) release (win32, OSX, .love)

 * __2016-09-17__ (1 day remaining / 16 days used):
    - Make character health percentage display bar show depleted portions in darker red
    - Study combat systems and decide on something that can be implemented today
    - Add armour and weapon information to NPCs
    - NPC combat system
    - Permadeath
    - Add NPC health
    - Make battles leave blood pools
    - De-duplicate blood pools
    - Make player structure similar to NPCs
    - Make good messages in combat a different color
    - Notify player when things die
    - Made v0.0.1 release (win32, OSX, .love)

 * __2016-09-16__ (1-2 days remaining / 15 days used):
    - More work on Brogue dungeon generation port (this is eating so much time!)
    - Fixed doors issue
    - Made inter-level fades work and got tweening happening (switched from tween.lua to flux library)
    - Additional audio modifications
    - Impact sounds (identification, processing)
    - Add impact noises for player hits
    - Add new NPC `midnight_jelly`
    - Make wall impact and fighting different arcade-style visual effects
       - Re-adjust these
    - More ambient tracks for `natural_cave` area
    - NPC movement complete-ish (monsters will attack and follow but currently cannot open doors)
    - Fixed bloody footstep bug
    - Monsters make noise when noticing player
    - Some monsters always make noise while moving (`midnight_jelly`)
    - Make monsters not run in to one another
    - Make monster respect closed doors
    - Make monster not spawn on the player, and vice versa
    - Make stuck (shut in) monsters noisy
    - Make seen doors remain visible when out of line of sight
    - Players become 'unseen' by monsters when they re-enter a level they have previously visited
    - Monsters attack players
    - Fix door closing to be impossible if NPC-occupied
    - Shake screen when hit by monsters, semi-randomly
    - Linecount 5924

 * __2016-09-15__ (2-3 days remaining / 14 days used):
    - More work on Brogue dungeon generation port (this is eating so much time!)

 * __2016-09-14__ (3-4 days remaining / 13 days used):
    - Fix bug related to non-halvable tile resolutions from different screen resolutions
    - Update linecount tool
    - Processed and integrated 'pickup' noises (8 bit stuff sounds out of place), 'drop' noises (not yet in use), 'breathing' noises (not yet in use), 'stairs' noises
    - More research (Scythians may have influenced Dian culture: pole worship, Palaung/Karen origins in Mongolia, Pyu city-states thought to have used 'Sak' language family, etc.)
    - Changed quit from escape to shift+Q (preparation for modal menu display)
    - Made icons for future standing with religious factions
    - More work on Brogue dungeon generation port
       - Improved `tilemap_show` function for additional debugging clarity
       - More work on cellular automata based caverns
    - Ordered key list in help output
    - Beginnings of door-spiking
    - Added new `bear` NPC, including locating and processing sounds
    - Half-implemented fade-outs between levels using new `tween` library
    - Linecount 5299

 * __2016-09-13__ (4-5 days remaining / 12 days used):
    - Discolor then slowly color-shift back to normal player footsteps when treading in blood or water
    - Added the `moss` ground feature
    - Some research in to fantasy creature systems
    - Some research in to Buddhist, Chinese, Hindu, and Tai mythology
    - More work on Brogue dungeon generation port (very time consuming)
       - Many additional tilemap functions to support Brogue-style dungeon generation algorithms
       - Most room generators (except cellular automata based cavern type) working
       - Mostly everything else still broken
    - Processed 'pickup' noises (8 bit stuff sounds out of place)
    - Linecount 4857

 * __2016-09-12__ (5-6 days remaining / 11 days used):
    - Began the day by reading some studies of [level generation](http://brogue.wikia.com/wiki/Level_Generation) algorithms in [Brogue](https://www.rockpapershotgun.com/2015/07/28/how-do-roguelikes-generate-levels/), documenting a few more issues and solutions, and brainstorming further about what will be easier/harder to get working in time for ARRP.
    - New RNG from rotLove library
    - Reduced background NPC vocality
    - Footprint alpha variance
    - Move information overlays to edge of screen
    - Create new `natural_cavern` area type as beginning of ARRP 2016 release
       - Port Brogue's C dungeon generation algorithms to Lua for this area type
    - Add new `tilemap.lua` source file for tilemap manipulation related functions
    - Auto-replace depth reading with area name at surface
    - Player spawns at stairs after ascent/descent
    - Normalize world-shift to new area load function
    - Player health display
    - Make seen tiles and footprints properly remembered/retrieved when changing dungeon levels
    - Added [shack](https://github.com/Ulydev/shack) library for screen shaking
    - Added FPS to coordinate overlay
    - Re-enable kills
    - Pools of blood after kills
    - Make pools of blood sound like treading in water
    - Louder liquid footfalls
    - Better blood pools
    - Located, downloaded and processed proper sounds for doors (8 bit noises too out of context)
    - Linecount 3330

 * __2016-09-11__ (6-7 days remaining / 10 days used):
    - Day off, mostly collected and distilled ideas about game direction, features and issues.
    - Made the decision to further circumscribe the [2016 ARRP](http://www.roguebasin.com/index.php?title=2016_ARRP) release's scope to dungeon-only.
        - This was partly on account of available time, partly more exposure to Brogue, and partly listening to the [Roguelike Radio expisode on coffee-break roguelikes](http://www.roguelikeradio.com/2012/05/episode-36-coffeebreak-roguelikes.html).
        - The hope is that by focusing on a smaller game the playability will be higher and the initial release more successful/interesting.
        - This does not circumscribe later releases from working toward the original, larger scope.

 * __2016-09-10__ (7-8 days remaining / 9 days used):
    - Generate `tai_cave_entrance` area
    - Fixed some area generation and transition related bugs
    - Made stairs work
    - Better initial world generation
    - Work on `tai_cave` area generation
    - Lose footprints on area change
    - In `tai_village` made buildings not spawn adjacent
    - Implement random NPC movement
    - Add background NPC noises
    - Stop music and ambient sound when changing areas
    - Make background NPC noises fade with distance
    - Make trees different shades of green
    - Make goblin NPCs vocal
    - Fix handling of moving in to undefined world areas
    - Downloaded and processed many more open licensed footstep noises
    - Support multiple ground types for footfall audio and make that work
    - Add rapid-shimmering water
    - Adjust sounds and graphics
    - Fix subterranean footprints
    - Linecount 2712

 * __2016-09-09__ (8-9 days remaining / 8 days used):
    - Improve tilemap drawing routines to utilize list of currently/ever seen tiles
    - Restore cross-area sounds such as footfalls
    - Fix bounds-checking on new draw routines
    - NPC generation function to structure-generic format
    - Bounds checking on character movement (attempts to leave current play area)
    - Auto-placement of unplaced NPCs in loaded areas
    - Area name display
    - Case study on `tai_village` area regarding procedural generation: potential features vs. time constraints.
       - Decided to currently implement:
          - No day/night delineation
          - No season delineation
          - Add area-specific field of view (eg. day/above-ground = all)
          - Add area-specific ground colours
          - Add area-specific tile types
    - Implemented area-specific ground colours
    - Implemented procedurally generated river in Tai village
    - Implemented procedurally generated bridge over river in Tai village
    - Implemented area-specific field of view
    - Added `chicken`, `rooster` and `water_buffalo` NPCs, including identifying and normalizing lots of freely licensed audio
    - Made bridge look sorta log-constructed
    - Enhanced free space search function to allow arbitrary-size area search
    - Added randomly placed buildings
    - Added randomly placed trees
    - Basic wilderness generation
    - Majority of area-switching logic
    - Linecount 2383

 * __2016-09-08__ (9-10 days remaining / 7 days used):
    - Wasted the whole day on field of view re-implementation
      - Wound up with a half-working implementation that infinite-loop-crashes in large rooms because the algorithm is imperfect, looks like hopscotch (new roguelike? :)
      - Made a simple area shading mode which kinda works (ignores tile geometry)
    - Finally got the rotLove precise version working ... even though its callback arguments were wacky. Phew!
    - Convert all display functions to LOS/POV only
    - Added partial visibility fog to peripheral vision squares
    - Remember and display seen tiles
    - Basic (simplified) world generation
    - Beginnings of area-specific tile and name generation
    - Lots of work on world area loading (properly dynamic)
    - Linecount 1971

 * __2016-09-07__ (10-11 days remaining / 6 days used):
    - Further logo design work
    - Add further structure to NPCs (different sound types, etc.)
    - Alter directory tree and code structure to support segregated NPC metadata (one NPC per source file)
    - Created central function to insert NPCs to map
    - Created OO class-like setup() function to instantiate NPCs with unique properties
    - Added `goblin` NPC
    - Sliced up and normalized goblin sounds
    - Moved villagers to `tai_villager_male` and `tai_villager_female` NPC definitions with appropriate name generation
    - Added `akha_villager`, `hmong_villager`, `tibetan_villager`, `yi_villager` NPCs
    - Added eyes and tails to mice and dogs
    - Created generic areas structure including a `tai_village` area type with appropriate name generation
    - Ascii-normalized input text due to UTF-8 errors with Hmong villager name generation
    - Shortened list of town music for moodier first impression
    - Reported [occasional crash](https://github.com/paulofmandown/rotLove/issues/10) in rotLove
    - Integrated alternate dungeon generator Astray, tested various options
    - Made music restart (new background track) when 'ascending' / 'descending' (not yet functional)
    - Decided to go for ARRL 2016 ... 9 days remaining!
    - Restructured the project to a new repository and moved it to Github
    - Linecount 1302

 * __2016-09-06__ (11-12 days remaining / 5 days used):
    - Added help popup to display key commands
    - Added escape key to quit
    - Added up and down stair graphics, ascend/descend commands, relevant messages
    - Fixed small bug in beautify routine
    - Colorized messages
    - Added hostile NPC ("Dog"), different display and killing
    - Added NPC-specific sounds
    - Generated many more sound effects
    - Added diagonal movement support
    - Downloaded many ambient sounds
    - Downloaded many dog sounds
    - Added ambient sounds
    - More legible log message display latency
    - Downloaded Audacity
    - Sliced up many new sounds (dog)
    - Reorganized sound directories
    - Fixed bug in NPC killing
    - Reviewed rotLove demos
    - Began some design work on logo
    - Linecount is 977

 * __2016-09-05__ (12-13 days remaining / 4 days used):
    - Broke drawing routines in to disparate functions, performed timing analysis
    - Removed significant debug output
    - Added limitation to footprint trail length
    - Added equipment popup and data structure extensions, enabled display of weapon stats in inventory
    - Integrated SLAM audio manager
    - Simplified rotLove/SLAM library require to same directory

 * __2016-09-04__ (13-14 days remaining / 3 days used):
    - Downloaded more music and categorized music in to place genres
    - Language-based name generation
    - Began overall world generation
    - Pixel font evaluation + selection for clarity
    - Shadow-based labels
    - Acquired Bfxr 8-bit sound generator
       - Created first few sound effects
    - Brainstormed ethnic class system
    - New generation algorithm (cellular -> brogue)
    - Implemented doors (generation, display, opening, closing)
    - Implemented autopickup and inventory system
    - Implemented inventory display when 'i' is pressed
    - Began NPC movement
    - Linecount is 659

 * __2016-09-03__ (14-15 days remaining / 2 days used):
    - Tile decorations
    - Footprints
    - Selected and downloaded appropriately licensed music 
 
 * __2016-09-02__ (15-16 days remaining / 1 day used):
    - Basic movement
