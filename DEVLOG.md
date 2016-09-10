# Development log

 * __2016-09-10__:
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

 * __2016-09-09__:
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

 * __2016-09-08__:
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

 * __2016-09-07__:
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

 * __2016-09-06__:
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

 * __2016-09-05__:
    - Broke drawing routines in to disparate functions, performed timing analysis
    - Removed significant debug output
    - Added limitation to footprint trail length
    - Added equipment popup and data structure extensions, enabled display of weapon stats in inventory
    - Integrated SLAM audio manager
    - Simplified rotLove/SLAM library require to same directory

 * __2016-09-04__:
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

 * __2016-09-03__:
    - Tile decorations
    - Footprints
    - Selected and downloaded appropriately licensed music 
 
 * __2016-09-02__:
    - Basic movement
