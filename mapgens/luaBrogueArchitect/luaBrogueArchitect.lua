---------------------------------------------------------------------------------------------
--
--  LuaBrogueArchitect (GPLv3)
--
--  An attempted, approximate port of Brogue's wonderful dungeon generation from C to Lua
--  for the Zomia project @ https://github.com/globalcitizen/zomia
--
--  The original author was Brian Walker (Pender), and the code was licensed GNU AGPLv3.
--
--  In this GPLv3 port we include his text from a 2015 interview at Rock, Paper, Shotgun
--  discussing the processes underway (useful as the original is barely commented):
--   https://www.rockpapershotgun.com/2015/07/28/how-do-roguelikes-generate-levels/
-- 
--  Feel free to hack it to pieces, fork it, improve it, whatever. However, be aware
--  that the code currently relies on a few external functions: tilemap_new() and
--  tilemap_show() for example; as well as the rotLove library for cellular automata
--  support (critical for the frequently used 'cavern' type room generator).
--
--  Note of caution:
--    As I am not really comfortable in C *and* I am new to Lua there are probably
--    lots of big issues hiding in the code. You have been warned!
-- 
---------------------------------------------------------------------------------------------

-- Generate a Brogue-style level map of the supplied dimensions.
function mapgen_broguestyle(width,height)

	-- Verify input
	print("mapgen_broguestyle() called to create " .. width .. "x" .. height .. " tilemap")
	if width < 10 or height < 10 or width > 200 or height > 200 then
		print("FATAL: mapgen_broguestyle() called to create tilemap with invalid dimensions. (Per-axis limit 10-200)")
		os.exit()
	end

	-- Begin with blank (rock/wall) tiles
	local new_tilemap = tilemap_new(width,height,0)

	-- First, place a room.
	new_tilemap = mapgen_broguestyle_design_random_room(new_tilemap)
	tilemap_show(new_tilemap,"First room")
	os.exit()

	if new_tilemap == nil then
		print("ERROR: tilemap is nil after randomroom.")
		os.exit()
	end

--[[ 
Then, it draws another room on another grid, which it slides like a piece of cellophane over the level until the new room fits snugly against an existing room without touching or overlapping. When there’s a fit, it transfers the room from the cellophane to the master grid and punches out a door. It does that repeatedly until it can’t fit any more rooms.

That first room can sometimes be a “cavern” — a large, winding, organic shape that fills a lot of the space of the level. Those are made by filling the level randomly with 55% floor and 45% wall, and then running five rounds of smoothing. In every round of smoothing, every floor cell with fewer than four adjacent floor cells becomes a wall, and every wall cell with six or more adjacent floor cells becomes a floor. This process forces the random noise to coalesce and contract into a meandering blob shape. The algorithm picks the biggest blob that is fully connected and calls that the first room.

There are a bunch of different techniques for drawing a room, chosen at random each time — for example, two large rectangles overlaid on each other, a large donut shape, a circle or a “blob” produced like the cavern described above but with smaller dimensions. Sometimes, we’ll generate the room with a hallway sticking off of it at a random point, and require that the end of the hallway connect to an existing room.
--]]

	-- Second, attach additional rooms
	max_attempts = 35
	max_roomcount = 35
	new_tilemap = mapgen_broguestyle_attach_rooms(new_tilemap, max_attempts, max_roomcount)

	if new_tilemap == nil then
		print("ERROR: tilemap is nil after attach_rooms.")
		os.exit()
	end

--[[
At this point we have a simply connected network of differently shaped rooms. The problem is that there are no loops in the geometry; the entire map is a single tree, where each room after the first has exactly one “parent” room (that it grew off from) and any number of “child” rooms (that grew off from it). It turns out it’s not much fun to explore that kind of level, because it requires a lot of backtracking and it’s easy to get cornered by monsters. So, we start inspecting the walls of the level. If we can find a wall that has a passable cell on both sides of it, where the two cells are at least certain distance apart in terms of pathfinding, we punch out a door (or a secret door). Do that a bunch of times and you get a level that’s nicely connected.
--]]

	-- Third, add loops
	local minimum_pathing_distance = 20
	new_tilemap = mapgen_broguestyle_add_loops(new_tilemap, minimum_pathing_distance)

	if new_tilemap == nil then
		print("ERROR: tilemap is nil after add_loops.")
		os.exit()
	end

--[[
    for (i=0; i<DCOLS; i++) {
        for (j=0; j<DROWS; j++) {
            if (grid[i][j] == 1) {
                pmap[i][j].layers[DUNGEON] = FLOOR;
            } else if (grid[i][j] == 2) {
                pmap[i][j].layers[DUNGEON] = (rand_percent(60) && rogue.depthLevel < DEEPEST_LEVEL ? DOOR : FLOOR);
            }
        }
    }
--]]

--[[
	for i=0, width, 1 do
		for j=0, height, 1 do
			if tilemap[i][j] == 1 then
				pmap[i][j].layers[DUNGEON] = FLOOR
			else if tilemap[i][j] == 2 then
				if rng:random(1,100) <= 60 then
					pmap[i][j].layers[DUNGEON] = DOOR
				else
					pmap[i][j].layers[DUNGEON] = FLOOR
				end
			end
		end
	end
--]]

	-- Now finish any exposed granite with walls and revert any unexposed walls to granite
	local including_diagonals = false
	new_tilemap = mapgen_broguestyle_finish_walls(new_tilemap, including_diagonals)
	if new_tilemap == nil then
		print("ERROR: tilemap is nil after finish_walls.")
		os.exit()
	end

--[[
Then we move onto lakes. Lakes are masses of a particular terrain type — water, lava, chasm or brimstone — that can span almost the entire level. They’re atmospheric, they enable long-distance attacks, and they impose structure on the level at a large scale to prevent it from feeling like a homogenous maze of twisty passages. We pull out the cellophane and draw a lake on it using the cellular automata method, and then we slide the cellophane around to random locations until we find a place that works — where all of the passable parts of the level that aren’t covered by lake are still fully connected, so the player is never required to cross the lake. If twenty random tries fails to find a qualifying location, we draw a smaller lake and try again. If we can find a qualifying location, we drop the lake onto the map there and overwrite the terrain underneath it. Some lakes have wreaths — shallow water surrounds deep water, and “chasm edge” terrain surrounds chasms — and we draw that in at this stage.
--]]

	-- Time to add lakes and chasms. Strategy is to generate a series of blob lakes of decreasing size. For each lake,
        -- propose a position, and then check via a flood fill that the level would remain connected with that placement (i.e. that
        -- each passable tile can still be reached). If not, make 9 more placement attempts before abandoning that lake
        -- and proceeding to generate the next smaller one.
        -- Canvas sizes start at 30x15 and decrease by 2x1 at a time down to a minimum of 20x10. Min generated size is always 4x4.

        -- Now design the lakes and then fill them with various liquids (lava, water, chasm, brimstone).
--[[
	lakemap = new_tilemap(#new_tilemap,#new_tilemap[1],0)
        lakemap = mapgen_broguestyle_design_lakes(lakemap)
        lakemap = mapgen_broguestyle_fill_lakes(lakemap)
--]]

--[[
Next up are the flavorful local features of terrain — tufts of grass, outgrowths of crystal, mud pits, hidden traps, statues, torches and more. These are defined in a giant table of “autogenerators” that specifies the range of depths in which each feature can appear, how likely it is and how many copies to make. For each one, we pick a random location and spawn it. A lot of them spawn in patches. Those are generated by picking an initial location and letting it randomly expand outward from there, with the probability of further expansion lowering with each expansion — like pouring some paint on an uneven floor and letting it flow outward into a puddle.
--]]

        -- Run the non-machine autoGenerators
	local build_area_machines = false
        new_tilemap = mapgen_broguestyle_run_autogenerators(new_tilemap,build_area_machines)

        -- Remove diagonal openings
        --new_tilemap = mapgen_broguestyle_remove_diagonal_openings(new_tilemap)

--[[
The next major step in level generation is what I call the machines. This is the most complicated part of the level generation by far. Machines are clusters of terrain features that relate to one another. Any time you see an altar, or an instance where interacting with terrain at one point causes terrain at a distant point to do something, you’re looking at a machine. There’s a hand-designed table of machines — 71 of them at the moment — that guides where and why each machine should spawn and what features it should create. Each machine feature further specifies whether it should only spawn near the doorway of the room, or far away from it, or in view of it, or never in a hallway, or only in the walls surrounding the machine, and so on.
--]]

	-- Now add some treasure machines
        --new_tilemap = mapgen_broguestyle_add_machines(new_tilemap)

        -- Run the machine autoGenerators
	local build_area_machines = true
        new_tilemap = mapgen_broguestyle_run_autogenerators(new_tilemap, build_area_machines)

--[[
There are three types of machines — room machines that occupy the interior of an area with a single chokepoint, door machines that are spawned by room machines to guard the door, and area machines that can spawn anywhere and spread outward until they are the appropriate size. Some machines will bulldoze a portion of the level and run a new level generation algorithm with different parameters on that specific region; that is how you get goblin warrens as dense networks of cramped mud-lined rooms, and sentinel temples as crystalline palaces of circular and cross-shaped rooms. Sometimes a machine will generate an item such as a key and pass it to another machine to adopt the item; that is how you get locked doors with the key guarded by a trap elsewhere on the level. Sometimes the machine that holds the key is guarded by its own locked door, and the key for that door is somewhere else — there’s no limit to how many layers of nesting are allowed, and the hope is that nested rooms will lend a kind of narrative consistency to the level through interlocking challenges. The game keeps track of which portions of the level belong to which machines, and certain types of terrain activations will trigger activations elsewhere in the machine; that is how lifting a key off of an altar can cause a torch on the other side of the room to ignite the grass in the room. The machine architecture is a hodge-podge of features intended to translate entries of a table into self-contained adventures with hooks to link them to other adventures.

After the machines are built, we place the staircases. The upstairs tries to get as close as possible to the location of the downstairs location from the floor above, and the downstairs picks a random qualifying location that’s a decent distance away from the upstairs. Stairs are used automatically when the player walks into them, and they’re recessed into the wall so that there’s no other reason to walk into them. That limits the number of locations in which they can spawn, but they’re generally able to connect pretty closely to the locations on adjacent levels.  [NB: This seems to have changed between the interview and the current (late 2016) Brogue codebase.]

Then we do some clean-up. If there’s a diagonal opening between two walls, we knock down one of the walls. If a door has fewer than two adjacent walls, we knock down the door. If a wall is surrounded by similar impassable terrain on both sides — think of a wall running down the middle of a lava lake, or across a chasm — we knock it down. This is also where bridges are built across chasms where it makes sense — where both sides connect and shorten the pathing distance between the two endpoints significantly.
--]]

        -- Now knock down the boundaries between similar lakes where possible.
        --new_tilemap = mapgen_broguestyle_cleanup_lake_boundaries(new_tilemap)

	-- Now add some bridges
	--new_tilemap = mapgen_broguestyle_build_a_bridge(new_tilemap)

        -- Now remove orphaned doors and upgrade some doors to secret doors
	--new_tilemap = mapgen_broguestyle_finish_doors(new_tilemap)

        -- Now finish any exposed granite with walls and revert any unexposed walls to granite
        --local including_diagonals = true
        -- new_tilemap = mapgen_broguestyle_finish_walls(new_tilemap,including_diagonals)

--[[
Items are next, beyond what was already placed by machines. There’s a cute trick to decide where to place items. Imagine a raffle, in which each empty cell of the map enters a certain number of tickets into the raffle. A cell starts with one ticket. For every door that the player has to pass to reach the cell, starting from the upstairs, the cell gets an extra ten tickets. For every secret door that the player has to pass to reach the cell, the cell gets an extra 3,000 tickets. If the cell is in a hallway or on unfriendly terrain, it loses all of its tickets. Before placing an item, we do a raffle draw — so caches of treasure are more likely in well hidden areas, off the beaten path. When we place an item, we take away some of the tickets from the nearby areas to avoid placing all of the items in a single clump. (Food and strength potions are exceptions; they’re placed without a bias for hidden rooms, because they are carefully metered, and missing them can set the player back significantly.) There are also more items on the very early levels, to hasten the point at which the player can start cobbling together a build.

Last are monster hordes. They get placed randomly and uniformly — but not in view of the upstairs, so the player isn’t ambushed the first time she sets foot on the level. Sometimes the monsters are drawn from a deeper level or spawned with a random mutation to keep the player on her toes.

[NB: Currently both of the above functions are in initializeLevel()]
--]]

	new_tilemap = mapgen_broguestyle_initialize_level(new_tilemap)

--[[
And that finishes the level!

Many of the probabilities throughout this process vary by depth. Levels become more organic and cavern-like as you go deeper, you’ll start to see more lava and brimstone, secret doors become more common, grass and healing plants will become rarer and traps and crystal formations will become more frequent. It’s gradual, but if you manage to grab the Amulet of Yendor on the 26th level, the difference is noticeable during the rapid ascent.
--]]

	return new_tilemap

end


-- Add a random room to the supplied tilemap
function mapgen_broguestyle_design_random_room(tilemap,attach_hallway,doorsites,roomtype_frequencies)

	-- defaults
	attach_hallway = attach_hallway or false
	doorsites = doorsites or nil
	roomtype_frequencies = roomtype_frequencies or nil

	--[[ Brogue itself includes the following room types:
		0. Cross room :: designCrossRoom()
		1. Small symmetrical cross room :: designSymmetricalCrossRoom()
		2. Small room :: designSmallRoom()
		3. Circular room :: designCircularRoom()
		4. Entrance room (the big upside-down T room at the start of depth 1) :: designEntranceRoom()
		5. Chunky room :: designChunkyRoom()
		6. Cave :: designCavern()
		7. Cavern :: designCavern() with different arguments
	]]--

	-- currently we have only implemented room types 0-5 and 7.
	roomtype = 6
	--roomtype = rng:random(0,4)
	if roomtype == 0 then							-- OK, works (but half off top of map)
		room = mapgen_broguestyle_room_cross(tilemap)
	elseif roomtype == 1 then						-- OK, works (but flattened east (south) edge)
		room = mapgen_broguestyle_room_symcross(tilemap)
	elseif roomtype == 2 then						-- OK
		room = mapgen_broguestyle_room_small(tilemap) 
	elseif roomtype == 3 then						-- OK
		room = mapgen_broguestyle_room_circular(tilemap)
	elseif roomtype == 4 then						-- OK
		room = mapgen_broguestyle_room_entrance(tilemap)
	elseif roomtype == 5 then						-- OK
		room = mapgen_broguestyle_room_chunky(tilemap)
	elseif roomtype == 6 then						-- WAITING FOR INTEGRATION WITH ROTLOVE
		-- Cave, one of three types...
		--  Note that the resolution of the axes in the default code (against which the magic values below
		--  were defined) is significant, and that resolution is 79x29 (see Rogue.h in Brogue source)
		--  Arguments to mapgen_broguestyle_room_cavern() are:
		--    tilemap, iterations, min_width, min_height, max_width, max_height, percent_seeded
		local iterations = 0
		local min_width = 0
		local min_height = 0
		local max_width = 0
		local max_height = 0
		-- First, we decide which type of room to generate
		local type = rng:random(0,2)
		if type == 0 then
			-- Compact cave room.
			print("DEBUG: compact cave room")
			iterations	= 3
			min_width	= 12
			min_height	= 4
			max_height	= 8
			max_width	= #tilemap-2
		elseif type == 1 then
			-- Large north-south cave room.
			print("DEBUG: large north-south cave room")
			iterations	= 3
			min_width	= 12
			min_height	= 15
			max_width	= #tilemap-2
			max_height	= #tilemap[1]-2
		elseif type == 2 then
			-- Large east-west cave room.
			print("DEBUG: large east-west cave room")
			iterations	= 20
			min_width	= 8
			min_height	= 4
			max_width	= #tilemap-2
			max_height	= #tilemap[1]-2		-- NOTE: original source code excludes this argument
		end
		-- Finally, we generate the room
		print("mapgen_broguestyle_design_random_room() calling with " .. #tilemap .. "x" .. #tilemap[1] .. " tilemap, iterations=" .. iterations .. ", width=" .. min_width .. "-" .. max_width .. ", height=" .. min_height .. "-" .. max_height)
		room = mapgen_broguestyle_room_cavern(tilemap, iterations, min_width, min_height, max_width, max_height)
	elseif roomtype == 7 then						-- WAITING FOR INTEGRATION WITH ROTLOVE
		-- Cavern (the kind that fills a level)
            	--room = mapgen_broguestyle_room_cavern(tilemap, CAVE_MIN_WIDTH, DCOLS - 2, CAVE_MIN_HEIGHT, DROWS - 2);
	end

	-- ok, now we have it
	tilemap_show(room,"Temporary Room (type = " .. roomtype .. ")")

	-- time to copy it in to the tilemap
	
	if doorsites ~= nil then
		mapgen_broguestyle_choose_random_doorsites(tilemap,doorsites)
		if attach_hallway then
			dir = rng:random(0,3)
			for i=1, 3, 1 do
				if doorSites[dir][0] ~= -1 then 
					i = 3
				else
					dir = (dir + 1) % 4 -- each room will have at least 2 valid directions for doors.
				end
			end
			tilemap = mapgen_broguestyle_attach_hallway_to(tilemap, doorsites);
		end
	end

	if tilemap == nil then
		print("ERROR: randomroom returning nil tilemap.")
		os.exit()
	end

	return tilemap
end

-- Cross ('+')-shaped room
--  BUG: Often produces rooms that exceed 0 on the Y-axis, ie. are half off the top of the map. Not critical, fix later.
function mapgen_broguestyle_room_cross(tilemap)

	-- new tilemap workspace
	grid = tilemap_new(#tilemap,#tilemap[1],0)

	-- determine dimensions
	--[[
	    roomWidth = rand_range(3, 12);
	    roomX = rand_range(max(0, DCOLS/2 - (roomWidth - 1)), min(DCOLS, DCOLS/2));
	    roomWidth2 = rand_range(4, 20);
	    roomX2 = (roomX + (roomWidth / 2) + rand_range(0, 2) + rand_range(0, 2) - 3) - (roomWidth2 / 2);
	--]]
	roomwidth = rng:random(3,12)
	x = rng:random(1,math.max(0, #tilemap/2-(roomwidth-1), math.min(#tilemap, #tilemap/2)))
	roomwidth2 = rng:random(4,20)
	x2 = (x + (roomwidth/2) + rng:random(0,2) + rng:random(0,2) - 3) - (roomwidth2 / 2)
	--[[
	    roomHeight = rand_range(3, 7);
	    roomY = (DROWS/2 - roomHeight);

	    roomHeight2 = rand_range(2, 5);
	    roomY2 = (DROWS/2 - roomHeight2 - (rand_range(0, 2) + rand_range(0, 1)));
	--]]
	roomheight = rng:random(3,7)
	y = (#tilemap[1]/2 - roomheight)
	roomheight2 = rng:random(2,5)
	y2 = (#tilemap[1]/2 - roomheight2 - (rng:random(0,2) + rng:random(0,1)))

	-- draw
	--[[
	    drawRectangleOnGrid(grid, roomX - 5, roomY + 5, roomWidth, roomHeight, 1);
	    drawRectangleOnGrid(grid, roomX2 - 5, roomY2 + 5, roomWidth2, roomHeight2, 1);
	--]]
	grid = tilemap_draw_rectangle(grid,x-5,y+5,roomwidth,roomheight,1)
	grid = tilemap_draw_rectangle(grid,x2-5,y2+5,roomwidth2,roomheight2,1)

	-- return room
	tilemap_show(grid,"room_cross")
	return grid
end


-- Symmetrical cross ('+')-shaped room
--  BUG: Appears to produce a flattened eastern edge. Not critical, fix later.
function mapgen_broguestyle_room_symcross(tilemap)

	-- new tilemap workspace
	grid = tilemap_new(#tilemap,#tilemap[1],0)

	-- determine dimensions
	majorwidth = rng:random(4,8)
	majorheight = rng:random(4,5)
	minorwidth = rng:random(3,4)
	if majorheight % 2 == 0 then
		minorwidth = minorwidth - 1
	end
	minorheight = 3
	if majorwidth % 2 == 0 then
		minorheight = minorheight - 1
	end

	-- draw
	grid = tilemap_draw_rectangle(grid, (#tilemap - majorwidth)/2, (#tilemap[1] - minorheight)/2, majorwidth, minorheight, 1)
	gird = tilemap_draw_rectangle(grid, (#tilemap - minorwidth)/2, (#tilemap[1] - majorheight)/2, minorwidth, majorheight, 1)

	-- return room
	tilemap_show(grid,"room_symcross")
	return grid
end


-- Small room (single rectangle)
function mapgen_broguestyle_room_small(tilemap)

	-- new tilemap workspace
	grid = tilemap_new(#tilemap,#tilemap[1],0)

	-- determine dimensions
	width = rng:random(3,6)
	height = rng:random(2,4)

	-- draw
	grid = tilemap_draw_rectangle(grid, (#tilemap - width) / 2, (#tilemap[1] - height) / 2, width, height, 1)

	-- return room
	tilemap_show(grid,"room_small")
	return grid
end


-- Circular room
function mapgen_broguestyle_room_circular(tilemap)

	-- new tilemap workspace
	grid = tilemap_new(#tilemap,#tilemap[1],0)

	-- 5% of the time, the radius is 4-10 squares
	if rng:random(5,100) <= 5 then
		radius = rng:random(4,10)
	else
		-- normally it's 2-4 squares
		radius = rng:random(2,4)
	end

	-- draw the circle in the center of the new grid
	grid = tilemap_draw_circle(grid, #grid/2, #grid[1]/2, radius, 1)
	tilemap_show(grid,"First Circle")

	-- if the radius was over 6, half the time we then fill in a circle in the middle
	if radius > 6 and rng:random(1,100)<=50 then
		grid = tilemap_draw_circle(grid, #grid/2, #grid[1]/2, rng:random(3,radius-3), 0)
		tilemap_show(grid,"Second Circle")
	end

	-- return room
	tilemap_show(grid,"room_circular")
	return grid
end


-- 'Chunky'-style room, constructed of multiple circular 'chunks'
function mapgen_broguestyle_room_chunky(tilemap)

        -- new tilemap workspace
        grid = tilemap_new(#tilemap,#tilemap[1],0)

	-- random chunk count
	chunkcount = rng:random(2,8)

	-- start with a circle
	tilemap_draw_circle(grid, #grid/2, #grid[1]/2, 2, 1)

	-- constraints
	minx = #tilemap[1]/2 - 3
	maxx = #tilemap[1]/2 + 3
	miny = #tilemap/2 - 3
	maxy = #tilemap/2 + 3

	-- perform chunkcount iterations of adding a circle-chunk
	local i=0
	while i < chunkcount do
		x = rng:random(minx,maxx)
		y = rng:random(miny,maxy)
		if grid[x][y] == 0 then
			grid = tilemap_draw_circle(grid,x,y,2,1)
			i = i + 1
			minx = math.max(1, math.min(x - 3, minx))
			maxx = math.min(#tilemap[1] - 2, math.max(x + 3, maxx))
			miny = math.max(1, math.min(y - 3, miny))
			maxy = math.min(#tilemap - 2, math.max(y + 3, maxy))
		end
	end

	-- return room
	tilemap_show(grid,"room_chunky")
	return grid
end


-- Helper for mapgen_broguestyle_room_cavern()'s use of rotLove cellular automata library.
function mapgen_broguestyle_room_cavern_tile_callback_helper(x,y,z)
	--print(x .. " / " .. y .. " / " .. z)
	mapgen_broguestyle_room_cavern_callback_tilemap[x][y] = z
end


-- Helper function to fill and dimension a contiguous region within a tilemap
function mapgen_broguestyle_room_cavern_fill_and_count_contiguous_region_helper(x, y, fill_value)

	-- setup
	local number_of_cells = 1

	-- fill
	mapgen_broguestyle_room_cavern_callback_tilemap[x][y] = fill_value

	-- iterate through the four cardinal neighbors
	for dir=1, 4, 1 do
		new_x = x + directions[dir][1]
		new_y = y + directions[dir][2]
		-- discard out of bounds coordinates
		if tilemap_coordinates_valid(mapgen_broguestyle_room_cavern_callback_tilemap,new_x,new_y) then
			-- if floor
			if mapgen_broguestyle_room_cavern_callback_tilemap[new_x][new_y] == 1 then
				-- fill and recurse
				number_of_cells = number_of_cells + mapgen_broguestyle_room_cavern_fill_and_count_contiguous_region_helper(new_x,new_y,fill_value)
			end
		end
	end
	
	-- return the result
	return number_of_cells

end


-- Generate a 'blob' (cellular automata based random shape result) that meets the required specifications
function mapgen_broguestyle_room_cavern_create_blob_helper(tilemap, iterations, min_width, min_height, max_width, max_height, percent_seeded)

	-- verify input
	print("mapgen_broguestyle_room_cavern_create_blob_helper() passed " .. #tilemap[1] .. "x" .. #tilemap .. " tilemap, iterations=" .. iterations .. ", width=" .. min_width .. "-" .. max_width .. ", height=" .. min_height .. "-" .. max_height .. ", percent_seeded=" .. percent_seeded)
	if iterations < 1 or iterations > 100 then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed bad number of iterations (wanted 0-100, got " .. iterations)
		os.exit()
	elseif min_width < 1 then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed zero or negative minimum width.")
		os.exit()
	elseif max_width > #tilemap then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed maximum width " .. max_width .. " exceeding tilemap width " .. #tilemap .. ".")
		os.exit()
	elseif max_width < min_width then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed maximum width " .. max_width .. " which is less than the minimum width " .. min_width)
		os.exit()
	elseif min_height < 1 then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed zero or negative minimum height.")
		os.exit()
	elseif max_height > #tilemap[1] then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed maximum height " .. max_height .. " exceeding tilemap height " .. #tilemap[1] .. ".")
		os.exit()
	elseif max_height < min_height then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed maximum height " .. max_height .. " which is less than the minimum height " .. min_height)
		os.exit()
	elseif percent_seeded < 0 or percent_seeded > 100 then
		print("FATAL: mapgen_broguestyle_room_cavern_create_blob_helper() passed invalid percent_seeded (received " .. percent_seeded .. ", expected 0-100")
		os.exit()
	end

	-- continue generating until success or timeout
	local success = false
	local max_attempts = 30
	local attempt = 1
	local top_blob_number = 0
	while attempt <= max_attempts do

		-- reset inter-function global
		mapgen_broguestyle_room_cavern_callback_tilemap = tilemap_new(#tilemap,#tilemap[1])

		-- perform cellular automata based blob generation
		--  NOTE: previously tilemap dimensions * 0.7 were used for width/height
		--  NOTE: could try 'minimumZoneArea: 10'
		local minimum_blob_area = math.max(min_width,min_height)*3
        	cl = ROT.Map.Cellular:new(math.floor(#tilemap[1]*0.7),math.floor(#tilemap*0.7),{survive={4,5,6,7,8},minimumZoneArea=minimum_blob_area})
        	cl:randomize(percent_seeded/100)
        	for i=1,iterations,1 do
        	        cl:create(mapgen_broguestyle_room_cavern_tile_callback_helper)
        	        --tilemap_show_cute(mapgen_broguestyle_room_cavern_callback_tilemap,"Attempt #" .. attempt .. " / Generation #" .. i)
        	        mapgen_broguestyle_room_cavern_callback_tilemap=tilemap_new(#tilemap[1],#tilemap)
        	end
        	cl:create(mapgen_broguestyle_room_cavern_tile_callback_helper)
        	cl:_completeMaze()

		-- measure results
		--  (these are best-of variables; we begin with worst-case values)
                local top_blob		= 0
                local top_blob_size	= 0
                local top_blob_min_x	= max_width
                local top_blob_max_x	= 0
                local top_blob_min_y	= max_height
                local top_blob_max_y	= 0

		-- fill each blob with its own number, starting with 2 (since 1 means floor), and keeping track of the biggest
                blob_number = 2
		for x=1, #mapgen_broguestyle_room_cavern_callback_tilemap, 1 do
			for y=1, #mapgen_broguestyle_room_cavern_callback_tilemap[1], 1 do
				-- an unmarked blob-tile?
				if mapgen_broguestyle_room_cavern_callback_tilemap[x][y] == 1 then
					-- call helper function to mark all the cells and return the total size
					blob_size = mapgen_broguestyle_room_cavern_fill_and_count_contiguous_region_helper(x, y, blob_number)
					print("mapgen_broguestyle_room_cavern_fill_and_count_contiguous_region_helper() returned blob_size " .. blob_size .. " for blob number " .. blob_number)
					-- if this blob's size is the largest seen so far
					if blob_size > top_blob_size then
						top_blob_size = blob_size
						top_blob_number = blob_number
					end
					blob_number = blob_number + 1
				end
			end
		end

		-- DEBUG
		tilemap_show(mapgen_broguestyle_room_cavern_callback_tilemap,"NUMBERED BLOBS")

		-- determine the top blob's dimensions
		--  first, min and max x
		local last_x = nil
		local last_y = nil
		for x=1, #mapgen_broguestyle_room_cavern_callback_tilemap, 1 do
			local found_a_cell_this_line = false
			for y=1, #mapgen_broguestyle_room_cavern_callback_tilemap[1], 1 do
				if mapgen_broguestyle_room_cavern_callback_tilemap[x][y] == top_blob_number then
					found_a_cell_this_line = true
					last_x = x
					last_y = y
					break
				end
			end
			if found_a_cell_this_line then
				if last_x < top_blob_min_x then
					top_blob_min_x = last_x
				end
				if last_x > top_blob_max_x then
					top_blob_max_x = last_x
				end
			end
		end

		--  now, min and max y
		for x=1, #mapgen_broguestyle_room_cavern_callback_tilemap, 1 do
			local found_a_cell_this_line = false
			for y=1, #mapgen_broguestyle_room_cavern_callback_tilemap[1], 1 do
				if mapgen_broguestyle_room_cavern_callback_tilemap[x][y] == top_blob_number then
					found_a_cell_this_line = true
					last_x = x
					last_y = y
					break
				end
			end
			if found_a_cell_this_line then
				if last_y < top_blob_min_y then
					top_blob_min_y = last_y
				end
				if last_y > top_blob_max_y then
					top_blob_max_y = last_y
				end
			end
		end

		-- finally, compute dimensions
		top_blob_width = top_blob_max_x - top_blob_min_x
		top_blob_height = top_blob_max_y - top_blob_min_y

		-- end of round summary (DEBUG)
		print("-- end of round summary --")
		print("tilemap size    = " .. #mapgen_broguestyle_room_cavern_callback_tilemap[1] .. "x" .. #mapgen_broguestyle_room_cavern_callback_tilemap)
		print("top_blob_number = " .. top_blob_number)
		print("top_blob_size   = " .. top_blob_size)
		print("top_blob_min_x  = " .. top_blob_min_x)
		print("top_blob_min_y  = " .. top_blob_min_y)
		print("top_blob_max_x  = " .. top_blob_max_x)
		print("top_blob_max_y  = " .. top_blob_max_y)
		print("top_blob_width  = " .. top_blob_width .. "  (ie. " .. top_blob_max_x .. "-" .. top_blob_min_x .. " / want " .. min_width .. "-" .. max_width .. ")")
		print("top_blob_height = " .. top_blob_height .. " (ie. " .. top_blob_max_y .. "-" .. top_blob_min_y .. "/ want " .. min_height .. "-" .. max_height .. ")")

		-- note that we can have a perfectly good blob where rotating 90 degrees
		-- (ie. flipping the X and Y dimensions) resolves a mismatch, and delivers success
		--  we should therefore probably implement flipping here (TODO)

		-- first, check we have a blob
		if top_blob_number ~= 0 then
			-- first, detemine whether the dimensions are already appropriate
			local width_ok = false
			local height_ok = false
			if top_blob_width >= min_width and top_blob_width <= max_width then
				width_ok = true
			end
			if top_blob_height >= min_height and top_blob_height <= max_height then
				height_ok = true
			end

			-- if so...
			if width_ok and height_ok then
				tilemap_show(mapgen_broguestyle_room_cavern_callback_tilemap,"OK blob")
				print("NOTICE: Blob #" .. top_blob_number .. " is OK!")
				-- success
				success = true
				break
			-- otherwise, if flipping get us what we want...
			elseif top_blob_height > min_width and top_blob_height < max_width and
			       top_blob_width > min_height and top_blob_width < max_height then
				print("NOTICE: Blob needs axial flip.")
				-- go ahead and flip it
				local tmp_blob = tilemap_new(#mapgen_broguestyle_room_cavern_callback_tilemap[1],#mapgen_broguestyle_room_cavern_callback_tilemap,0)
				for x=1,#mapgen_broguestyle_room_cavern_callback_tilemap,1 do
					for y=1,#mapgen_broguestyle_room_cavern_callback_tilemap[1],1 do
						print("Flipping " .. x .. "/" .. y .. " to " .. (x-top_blob_min_x) .. "/" .. (y-top_blob_min_y) .. ".")
						tmp_blob[x-top_blob_min_x][y-top_blob_min_y] = mapgen_broguestyle_room_cavern_callback_tilemap[x][y]
					end
				end
				-- finally, set the flipped version as the result
				mapgen_broguestyle_room_cavern_callback_tilemap = tmp_blob
				-- success
				success = true
				break
			else
				-- our blob is unworkable
				print("WARNING: Blob " .. top_blob_width .. "x" .. top_blob_height .. " did not match requisite dimensions (ie. (" .. min_width .. "-" .. max_width .. ")x(" .. min_height .. "-" .. max_height .. ") tiles).")
			end
		else
			print("WARNING: No blob at all!")
		end
		attempt = attempt + 1
		--os.exit()
	end

	-- failure?
	if not success then
		-- really bad
		print("FATAL: Failed to generate blob with required specifications (after " .. attempt .. " attempts). Cowardly dying.")
		os.exit()
	end

	-- isolate the successful result by replacing the winning blob with 1, everything else with 0
	for x=1, #mapgen_broguestyle_room_cavern_callback_tilemap, 1 do
		for y=1, #mapgen_broguestyle_room_cavern_callback_tilemap[1], 1 do
			if mapgen_broguestyle_room_cavern_callback_tilemap[x][y] == top_blob_number then
				mapgen_broguestyle_room_cavern_callback_tilemap[x][y] = 1
			else
				mapgen_broguestyle_room_cavern_callback_tilemap[x][y] = 0
			end
		end
	end

	-- return the result
        return mapgen_broguestyle_room_cavern_callback_tilemap

end


-- This one requires rotLove cellular automata library integration.
--  For this reason there is an additional function mapgen_broguestyle_room_cavern_tile_callback_helper() and
--  a global variable to share data:
mapgen_broguestyle_room_cavern_callback_tilemap = {}
function mapgen_broguestyle_room_cavern(tilemap,iterations,minwidth,minheight,maxwidth,maxheight)

	-- validate input
	print("mapgen_broguestyle_room_cavern() supplied " .. #tilemap[1] .. "x" .. #tilemap .. " tilemap, iterations=" .. iterations .. ", width=" .. minwidth .. "-" .. maxwidth .. ", height=" .. minheight .. "-" .. maxheight)
	local iterations = iterations or 6

        -- new tilemap workspace
        grid = tilemap_new(#tilemap,#tilemap[1],0)

	-- local variable
	local foundfillpoint = false

	-- generate a 'blob' (cellular automata result)
	local percent_seeded = 45
	grid = mapgen_broguestyle_room_cavern_create_blob_helper(tilemap, iterations, minwidth, minheight, maxwidth, maxheight, percent_seeded)
	tilemap_show_cute(grid,"Raw blobgrid")

	os.exit()

	--[[
        // Position the new cave in the middle of the grid...
        destX = (DCOLS - caveWidth) / 2;
        destY = (DROWS - caveHeight) / 2;
    // ...pick a floodfill insertion point...
    for (fillX = 0; fillX < DCOLS && !foundFillPoint; fillX++) {
        for (fillY = 0; fillY < DROWS && !foundFillPoint; fillY++) {
            if (blobGrid[fillX][fillY]) {
                foundFillPoint = true;
            }
        }
    }
        // ...and copy it to the master grid.
    insertRoomAt(grid, blobGrid, destX - caveX, destY - caveY, fillX, fillY);
	--]]

	--tilemap = tilemap_overwrite(tilemap,blobgrid,(#tilemap-#blobgrid)/2 - #blobgrid, (#tilemap[1]-#blobgrid[1],

	-- return room
	tilemap_show(grid,"room_cavern")
	return grid
end


-- 'Entrance'-style room
function mapgen_broguestyle_room_entrance(tilemap)

	--print("mapgen_broguestyle_room_entrance(): Passed tilemap: " .. table.show(tilemap))

        -- new tilemap workspace
        grid = tilemap_new(#tilemap,#tilemap[1],0)

	print("mapgen_broguestyle_room_entrance(): Generated grid tilemap.")

	-- set dimensions
	roomwidth=8
	roomheight=10
	roomwidth2=20
	roomheight2=5
	roomx = #tilemap/2 - roomwidth/2
	roomy = #tilemap[1] - roomheight
	roomx2 = #tilemap/2 - roomwidth2/2
	roomy2 = #tilemap[1] - roomheight2

	-- draw
	grid = tilemap_draw_rectangle(grid,roomx,roomy,roomwidth,roomheight,1)
	grid = tilemap_draw_rectangle(grid,roomx2,roomy2,roomwidth2,roomheight2,1)

	-- return room
	tilemap_show(grid,"room_entrance")
	return grid
end


-- Attach additional rooms to the first room (supplied)
function mapgen_broguestyle_attach_rooms(tilemap,max_attempts,max_roomcount)
	print("mapgen_broguestyle_attach_rooms() passed max_attempts=" .. max_attempts .. " and max_roomcount=" .. max_roomcount)

	-- First we build a unidimensional, shuffled list of tiles
	scoord = mapgen_broguestyle_fill_sequential_list(#tilemap * #tilemap[1])
	scoord = table.randomize(scoord)

	-- Then we get a new map structure the same size
	print("Build room map.")
	local roommap = tilemap_new(#tilemap,#tilemap[1],0)

--[[
    for (roomsBuilt = roomsAttempted = 0; roomsBuilt < maxRoomCount && roomsAttempted < attempts; roomsAttempted++) {
--]]

	local roomsbuilt = 0
	local roomsattempted=0

	while roomsattempted < max_attempts and roomsbuilt <= max_roomcount do

--[[
        // Build a room in hyperspace.
        designRandomRoom(roomMap, roomsAttempted <= attempts - 5 && rand_percent(theDP->corridorChance),
                         doorSites, theDP->roomFrequencies);
--]]

		local attach_hallway = false
		corridor_chance = 5		-- in % (should be in dungeon profile)
		if roomsattempted <= (max_attempts -5) then
			attach_hallway = true
			if rng:random(1,100) < corridor_chance then
				attach_hallway = false		
			end
		else
			attach_hallway = false
			if rng:random(1,100) < corridor_chance then
				attach_hallway = true
			end
		end

		roommap = mapgen_broguestyle_design_random_room(roommap, attach_hallway, doorsites)

--[[
        // Slide hyperspace across real space, in a random but predetermined order, until the room matches up with a wall.
        for (i = 0; i < DCOLS*DROWS; i++) {
            x = sCoord[i] / DROWS;
            y = sCoord[i] % DROWS;
            dir = directionOfDoorSite(grid, x, y);
            oppDir = oppositeDirection(dir);
--]]

		for i=1, (#tilemap * #tilemap[1]), 1 do
			x = scoord[i] / #tilemap[1]
			y = scoord[i] % #tilemap[1]
			--print("x = " .. x .. " / y = " .. y)
			dir = tilemap_door_direction(tilemap,x,y)
			oppdir = tilemap_opposite_direction(dir)
	
--[[
            if (dir != NO_DIRECTION
                && doorSites[oppDir][0] != -1
                && roomFitsAt(grid, roomMap, x - doorSites[oppDir][0], y - doorSites[oppDir][1])) {
]]--

			if dir ~= nil and doorsites[oppdir][0] ~= -1 and tilemap_room_fits_at(tilemap,roommap,x-doorsites[oppdir][0],y-doorsites[oppdir][1]) then

--[[
                // Room fits here.
                insertRoomAt(grid, roomMap, x - doorSites[oppDir][0], y - doorSites[oppDir][1], doorSites[oppDir][0], doorSites[oppDir][1]);
                grid[x][y] = 2; // Door site.
                roomsBuilt++;
                break;
--]]
				tilemap_insert_room_at(tilemap, roommap, x-doorsites[oppdir][0], y-doorsites[oppdir][1], doorsites[oppdir][0], doorsites[oppdir][1])
				tilemap[x][y] = 2	-- door site
				roomsbuilt = roomsbuilt + 1
				break
			end
		end
		roomsattempted = roomsattempted + 1
	end

	-- return full result
	tilemap_show(tilemap,"attach_room")
	return tilemap
end


-- Add loops (connections) between rooms
function mapgen_broguestyle_add_loops(tilemap, minimum_pathing_distance)

	-- verify input
	if tilemap == nil then
		print("ERROR: mapgen_broguestyle_add_loops() passed nil tilemap.")
		os.exit()
	end

	if minimum_pathing_distance<0 or minimum_pathing_distance ~= math.floor(minimum_pathing_distance) then
		print("ERROR: mapgen_broguestyle_add_loops() passed invalid pathing distance:" .. minimum_pathing_distance)
		os.exit()
	end

	local dir_coords = {{1,0},{0,1}}

        -- First we build a unidimensional, shuffled list of tiles
        scoord = mapgen_broguestyle_fill_sequential_list(#tilemap * #tilemap[1])
        scoord = table.randomize(scoord)
	pathmap = tilemap_new(#tilemap,#tilemap[1],0)
	costmap = tilemap_new(#tilemap,#tilemap[1],0)

--[[
    copyGrid(costMap, grid);
    findReplaceGrid(costMap, 0, 0, PDS_OBSTRUCTION);
    findReplaceGrid(costMap, 1, 30000, 1);
--]]

--[[
    for (i = 0; i < DCOLS*DROWS; i++) {
--]]

	for i=1, (#tilemap * #tilemap[1]), 1 do

--[[
        x = sCoord[i]/DROWS;
        y = sCoord[i] % DROWS;
--]]

		--print("about to try scoord index, i=" .. i)

		x = math.floor(scoord[i] / #tilemap[1])
		y = scoord[i] % #tilemap[1]

		--print("about to try tilemap index, x=" .. x .. " / y=" .. y)
--[[
        if (!grid[x][y]) {
--]]
		-- if the tile is rock
		if x ~= 0 and y ~=0 and tilemap[x][y] == 0 then

--[[
            for (d=0; d <= 1; d++) { // Try a horizontal door, and then a vertical door.
--]]

			local dirs_to_try = {0,1}
			for d in pairs(dirs_to_try) do 	-- try a horizontal door, then a vertical door

--[[
                newX = x + dirCoords[d][0];
                oppX = x - dirCoords[d][0];
                newY = y + dirCoords[d][1];
                oppY = y - dirCoords[d][1];
--]]

				newx = x + dir_coords[d][1]
				oppx = x - dir_coords[d][1]
				newy = y + dir_coords[d][2]
				oppy = y - dir_coords[d][2]

--[[
                if (coordinatesAreInMap(newX, newY)
                    && coordinatesAreInMap(oppX, oppY)
                    && grid[newX][newY] > 0
                    && grid[oppX][oppY] > 0) { // If the tile being inspected has floor on both sides,
--]]

				-- if the tile being inspected has floor on both sides
				if tilemap_coordinates_valid(tilemap,newx,newy) and 
				   tilemap_coordinates_valid(tilemap,oppx,oppy) and
				   tilemap[newx][newy] == 1 and
				   tilemap[oppx][oppy] == 1 then

--[[
                    fillGrid(pathMap, 30000);
                    pathMap[newX][newY] = 0;
                    dijkstraScan(pathMap, costMap, false);
--]]

					pathmap = tilemap_fill(pathmap,30000)
					pathmap[newx][newy] = 0
					pathmap = mapgen_broguestyle_dijkstrascan(pathmap,costmap,false)

--[[
                    if (pathMap[oppX][oppY] > minimumPathingDistance) { // and if the pathing distance between the two flanking floor tiles exceeds minimumPathingDistance,
                        grid[x][y] = 2;             // then turn the tile into a doorway.
                        costMap[x][y] = 1;          // (Cost map also needs updating.)
                        break;
                    }
--]]
					-- if the pathing distance between the two flanking floor tiles exceeds the minimum
					if pathmap[oppx][oppy] > minimum_pathing_distance then
						-- turn the tile in to a doorway
						tilemap[x][y] = 2
						-- then update the cost map
						costmap[x][y] = 1
						break
					end
				end
			end
		end
	end

	-- return result
	tilemap_show(tilemap,"add_loops")
	return tilemap
end


-- TODO: fix some_boolean
function mapgen_broguestyle_dijkstrascan(pathmap,costmap,some_boolean)
	local costmap = tilemap_new(#pathmap,#pathmap[1])
	-- TODO ...
	return pathmap
end


-- Now finish any exposed granite with walls and revert any unexposed walls to granite
function mapgen_broguestyle_finish_walls(tilemap,including_diagonals)
--[[
    short i, j, x1, y1;
    boolean foundExposure;
    enum directions dir;
--]]
	local found_exposure

--[[
    for (i=0; i<DCOLS; i++) {
--]]

	for i=1, #tilemap, 1 do

--[[
                for (j=0; j<DROWS; j++) {
--]]

		for j=1, #tilemap[1], 1 do

--[[
                        if (pmap[i][j].layers[DUNGEON] == GRANITE) {
--]]


			-- granite
			if tilemap[i][j] == 0 then
--[[
                                foundExposure = false;
                                for (dir = 0; dir < (includingDiagonals ? 8 : 4) && !foundExposure; dir++) {
                                        x1 = i + nbDirs[dir][0];
                                        y1 = j + nbDirs[dir][1];
                                        if (coordinatesAreInMap(x1, y1)
                                                && (!cellHasTerrainFlag(x1, y1, T_OBSTRUCTS_VISION) || !cellHasTerrainFlag(x1, y1, T_OBSTRUCTS_PASSABILITY))) {

                                                pmap[i][j].layers[DUNGEON] = WALL;
                                                foundExposure = true;
                                        }
                                }
--]]

				found_exposure = false
				local dir_max = 4
				if including_diagonals then dir_max = 8 end
				for dir=1, dir_max, 1 do
					x1 = i + directions[dir][1]
					y1 = j + directions[dir][2]
					if tilemap_coordinates_valid(tilemap,x1,y1) -- and
						-- and x1,y1 is not obstructing vision
						-- and x1,y1 is not obstructing passability
					      then
						tilemap[i][j] = 0
						found_exposure = true
						break
					end
				end

--[[
                        } else if (pmap[i][j].layers[DUNGEON] == WALL) {
--]]

			-- wall
			elseif tilemap[i][j] == 0 then

--[[
                                foundExposure = false;
                                for (dir = 0; dir < (includingDiagonals ? 8 : 4) && !foundExposure; dir++) {
                                        x1 = i + nbDirs[dir][0];
                                        y1 = j + nbDirs[dir][1];
                                        if (coordinatesAreInMap(x1, y1)
                                                && (!cellHasTerrainFlag(x1, y1, T_OBSTRUCTS_VISION) || !cellHasTerrainFlag(x1, y1, T_OBSTRUCTS_PASSABILITY))) {

                                                foundExposure = true;
                                        }
                                }
                                if (foundExposure == false) {
                                        pmap[i][j].layers[DUNGEON] = GRANITE;
                                }
--]]

				found_exposure = false
				local dir_max = 4
				if including_diagonals then dir_max = 8 end
				for dir=0, dir_max, 1 do
					x1 = i + directions[dir][0]
					y1 = j + dirextions[dir][1]
					if tilemap_coordinates_valid(tilemap,x1,y1) -- and
						-- and x1,y1 is not obstructing vision
						-- and x1,y1 is not obstructing passability
					      then
						found_exposure = true
					end
				end
				if found_exposure == false then
					tilemap[i][j] = 0
				end

			end
		end
	end

	-- return result
	tilemap_show(tilemap,"finish_walls")
	return tilemap
end


-- Add lakes
function mapgen_broguestyle_design_lakes(lakemap)

--[[
    short **grid; // Holds the current lake.
    grid = allocGrid();
    fillGrid(lakeMap, 0);
--]]

	grid = tilemap_new(#lakemap,#lakemap[1],0)

--[[
        for (lakeMaxHeight = 15, lakeMaxWidth = 30; lakeMaxHeight >=10; lakeMaxHeight--, lakeMaxWidth -= 2) { // lake generations
--]]

	local lake_max_height = 15
	local lake_max_width = 30
	while lake_max_height >= 10 do

--[[
        fillGrid(grid, 0);
--]]

		grid = tilemap_fill(grid,0)

--[[
        createBlobOnGrid(grid, &lakeX, &lakeY, &lakeWidth, &lakeHeight, 5, 4, 4, lakeMaxWidth, lakeMaxHeight, 55, "ffffftttt", "ffffttttt");
--]]

		-- FIXTHIS: need to either custom implement, or link across to the cellular automata implementation of rotLove!

--[[
                for (k=0; k<20; k++) { // placement attempts
--]]

		for k=0, 20, 1 do
--[[
                        // propose a position for the top-left of the grid in the dungeon
                        x = rand_range(1 - lakeX, DCOLS - lakeWidth - lakeX - 2);
                        y = rand_range(1 - lakeY, DROWS - lakeHeight - lakeY - 2);
--]]

			x = rng:random(1 - lake_x, #tilemap - lake_width - lake_x - 2)
			y = rng:random(1 - lake_y, #tilemap[1] - lake_height - lake_y - 2)

--[[
            if (!lakeDisruptsPassability(grid, lakeMap, -x, -y)) { // level with lake is completely connected
--]]

			if not mapgen_broguestyle_lake_disrupts_passability(grid, lakemap, -x -y) then

--[[
                                // copy in lake
                                for (i = 0; i < lakeWidth; i++) {
                                        for (j = 0; j < lakeHeight; j++) {
                        			if (grid[i + lakeX][j + lakeY]) {
             	     		 			lakeMap[i + lakeX + x][j + lakeY + y] = true;
            				                pmap[i + lakeX + x][j + lakeY + y].layers[DUNGEON] = FLOOR;
                        			}
                                        }
                                }

                                break;
--]]
				-- copy in lake
				for i=0, lake_width, 1 do
					for j=0, lake_height, 1 do
						if grid[i+lake_x][j+lake_y] ~= 0 then
							lakemap[i+lake_x+x][j+lake_y+y] = true
							tilemap[i+lake_x+x][j+lake_y+y] = 'W'		-- set to water for now
						end
					end
				end
				break

			end
		end

		lake_max_height = lake_max_height - 1
		lake_max_width = lake_max_width - 2
	end

	-- return results
	tilemap_show(tilemap,"design_lakes")
	return tilemap
end

-- Fill lakes
function mapgen_broguestyle_fill_lakes(tilemap,lakemap)
	-- TODO

	-- return results
	tilemap_show(tilemap,"fill_lakes")
	return tilemap
end


-- Add terrain, DFs and flavor machines. Includes traps, torches, funguses, flavor machines, etc.
-- If build_area_machines is true, build ONLY the autogenerators that include machines.
-- If false, build all EXCEPT the autogenerators that include machines.
function mapgen_broguestyle_run_autogenerators(tilemap,build_area_machines)
--[[
        short AG, count, x, y, i;
        const autoGenerator *gen;
        char grid[DCOLS][DROWS];

        // Cycle through the autoGenerators.
        for (AG=1; AG<NUMBER_AUTOGENERATORS; AG++) {

                // Shortcut:
                gen = &(autoGeneratorCatalog[AG]);

        if (gen->machine > 0 == buildAreaMachines) {

            // Enforce depth constraints.
            if (rogue.depthLevel < gen->minDepth || rogue.depthLevel > gen->maxDepth) {
                continue;
            }

            // Decide how many of this AG to build.
            count = min((gen->minNumberIntercept + rogue.depthLevel * gen->minNumberSlope) / 100, gen->maxNumber);
            while (rand_percent(gen->frequency) && count < gen->maxNumber) {
                count++;
            }

            // Build that many instances.
            for (i = 0; i < count; i++) {

                // Find a location for DFs and terrain generations.
                //if (randomMatchingLocation(&x, &y, gen->requiredDungeonFoundationType, NOTHING, -1)) {
                //if (randomMatchingLocation(&x, &y, -1, -1, gen->requiredDungeonFoundationType)) {
                if (randomMatchingLocation(&x, &y, gen->requiredDungeonFoundationType, gen->requiredLiquidFoundationType, -1)) {

                    // Spawn the DF.
                    if (gen->DFType) {
                        spawnDungeonFeature(x, y, &(dungeonFeatureCatalog[gen->DFType]), false, true);

                        if (D_INSPECT_LEVELGEN) {
                            dumpLevelToScreen();
                            hiliteCell(x, y, &yellow, 50, true);
                            temporaryMessage("Dungeon feature added.", true);
                        }
                    }

                    // Spawn the terrain if it's got the priority to spawn there and won't disrupt connectivity.
                    if (gen->terrain
                        && tileCatalog[pmap[x][y].layers[gen->layer] ].drawPriority >= tileCatalog[gen->terrain].drawPriority) {

                        // Check connectivity.
                        zeroOutGrid(grid);
                        grid[x][y] = true;
                        if (!(tileCatalog[gen->terrain].flags & T_PATHING_BLOCKER)
                            || !levelIsDisconnectedWithBlockingMap(grid, false)) {

                            // Build!
                            pmap[x][y].layers[gen->layer] = gen->terrain;

                            if (D_INSPECT_LEVELGEN) {
                                dumpLevelToScreen();
                                hiliteCell(x, y, &yellow, 50, true);
                                temporaryMessage("Terrain added.", true);
                            }
                        }
                    }
                }

                // Attempt to build the machine if requested.
                // Machines will find their own locations, so it will not be at the same place as terrain and DF.
                if (gen->machine > 0) {
                    buildAMachine(gen->machine, -1, -1, 0, NULL, NULL, NULL);
                }
            }
        }
        }
--]]
	return tilemap
end


-- Places the player, monsters, items and stairs.
function mapgen_broguestyle_initialize_level(tilemap)

--[[
	char grid[DCOLS][DROWS];
	short n = rogue.depthLevel - 1;
--]]

	if current_world_location ~= nil then
		n = current_world_location.z + 1
	else
		n = 1
	end
	grid = tilemap_new(#tilemap,#tilemap[1],0)

--[[
        for (i=0; i < DCOLS; i++) {
                for (j=0; j < DROWS; j++) {
                        grid[i][j] = validStairLoc(i, j);
                }
        }
--]]

        -- Place the stairs.
	for i=1, #tilemap, 1 do
		for j=1, #tilemap[1], 1 do
			grid[i][j] = mapgen_broguestyle_valid_stair_loc(tilemap,i,j)
		end
	end

--[[
    if (getQualifyingGridLocNear(downLoc, levels[n].downStairsLoc[0], levels[n].downStairsLoc[1], grid, false)) {
        prepareForStairs(downLoc[0], downLoc[1], grid);
    } else {
        getQualifyingLocNear(downLoc, levels[n].downStairsLoc[0], levels[n].downStairsLoc[1], false, 0,
                             (T_OBSTRUCTS_PASSABILITY | T_OBSTRUCTS_ITEMS | T_AUTO_DESCENT | T_IS_DEEP_WATER | T_LAVA_INSTA_DEATH | T_IS_DF_TRAP),
                             (HAS_MONSTER | HAS_ITEM | HAS_UP_STAIRS | HAS_DOWN_STAIRS | IS_IN_MACHINE), true, false);
    }
--]]

--[[
	if mapgen_broguesetyle_get_qualifying_grid_loc_near(downloc, levels[n].downstairsloc[0], levels[n].downstairsloc[1], grid, false) then
		grid = prepare_for_stairs(tilemap,downloc[0], downloc[1], grid)
	else
		mapgen_broguesetyle_get_qualifying_loc_near(downloc, levels[n].downstairsloc[0], levels[n].downstairsloc[1], false, 0,
									{
										'obstructs_passability',
										'obstructs_items',
										'auto_descent',
										'is_deep_water',
										'lava_insta_death',
										'is_df_trap',
										'has_monster',
										'has_item',
										'has_up_stairs',
										'has_down_stairs',
										'is_in_machine'
									}, true, false)
	end
--]]

--[[
    if (rogue.depthLevel == DEEPEST_LEVEL) {
        pmap[downLoc[0] ][downLoc[1] ].layers[DUNGEON] = DUNGEON_PORTAL;
    } else {
        pmap[downLoc[0] ][downLoc[1] ].layers[DUNGEON] = DOWN_STAIRS;
    }
    pmap[downLoc[0] ][downLoc[1] ].layers[LIQUID]     = NOTHING;
    pmap[downLoc[0] ][downLoc[1] ].layers[SURFACE]    = NOTHING;
--]]

	-- this stuff seems too rogue-like specific to bother with.
	--  it seems to essentially be saying:
	--    - "portal not stairs on the dungeon's lowest floor", and
	--    - "initialize liquid and surface map layers to empty"
	--  since we cannot assume fixed-depth dungeons, portals or
	--  particular map layers, we leave this code out.

--[[
    if (!levels[n+1].visited) {
        levels[n+1].upStairsLoc[0] = downLoc[0];
        levels[n+1].upStairsLoc[1] = downLoc[1];
    }
    levels[n].downStairsLoc[0] = downLoc[0];
    levels[n].downStairsLoc[1] = downLoc[1];
--]]

	-- if the player has visited a vertically adjacent level,
	-- then the stair location should be fixed identically.
	-- FIXTHIS: sort it out with a native structure

--[[
        if (getQualifyingGridLocNear(upLoc, levels[n].upStairsLoc[0], levels[n].upStairsLoc[1], grid, false)) {
                prepareForStairs(upLoc[0], upLoc[1], grid);
        } else { // Hopefully this never happens.
                getQualifyingLocNear(upLoc, levels[n].upStairsLoc[0], levels[n].upStairsLoc[1], false, 0,
                                                         (T_OBSTRUCTS_PASSABILITY | T_OBSTRUCTS_ITEMS | T_AUTO_DESCENT | T_IS_DEEP_WATER | T_LAVA_INSTA_DEATH | T_IS_DF_TRAP),
                                                         (HAS_MONSTER | HAS_ITEM | HAS_UP_STAIRS | HAS_DOWN_STAIRS | IS_IN_MACHINE), true, false);
        }
        levels[n].upStairsLoc[0] = upLoc[0];
        levels[n].upStairsLoc[1] = upLoc[1];
--]]

--[[
        if (rogue.depthLevel == 1) {
                pmap[upLoc[0] ][upLoc[1] ].layers[DUNGEON] = DUNGEON_EXIT;
        } else {
                pmap[upLoc[0] ][upLoc[1] ].layers[DUNGEON] = UP_STAIRS;
        }
    pmap[upLoc[0] ][upLoc[1] ].layers[LIQUID] = NOTHING;
    pmap[upLoc[0] ][upLoc[1] ].layers[SURFACE] = NOTHING;
--]]

--[[
        rogue.downLoc[0] = downLoc[0];
        rogue.downLoc[1] = downLoc[1];
        pmap[downLoc[0] ][downLoc[1] ].flags |= HAS_DOWN_STAIRS;
        rogue.upLoc[0] = upLoc[0];
        rogue.upLoc[1] = upLoc[1];
        pmap[upLoc[0] ][upLoc[1] ].flags |= HAS_UP_STAIRS;
--]]

--[[
        if (!levels[rogue.depthLevel-1].visited) {
        	// Run a field of view check from up stairs so that monsters do not spawn within sight of it.
        	for (dir=0; dir<4; dir++) {
        	    if (coordinatesAreInMap(upLoc[0] + nbDirs[dir][0], upLoc[1] + nbDirs[dir][1])
        	        && !cellHasTerrainFlag(upLoc[0] + nbDirs[dir][0], upLoc[1] + nbDirs[dir][1], T_OBSTRUCTS_PASSABILITY)) {

        	        upLoc[0] += nbDirs[dir][0];
        	        upLoc[1] += nbDirs[dir][1];
               		break;
            		}
       		}
                zeroOutGrid(grid);
                getFOVMask(grid, upLoc[0], upLoc[1], max(DCOLS, DROWS), (T_OBSTRUCTS_VISION), 0, false);
                for (i=0; i<DCOLS; i++) {
                        for (j=0; j<DROWS; j++) {
                                if (grid[i][j]) {
                                        pmap[i][j].flags |= IN_FIELD_OF_VIEW;
                                }
                        }
                }
                populateItems(upLoc[0], upLoc[1]);
                populateMonsters();
        }
--]]

	-- the important part here is populateItems() and populateMonsters()
	-- for now, we will assume this is done elsewhere
	-- TODO: later

--[[
    for (theItem = floorItems->nextItem; theItem != NULL; theItem = theItem->nextItem) {
                restoreItem(theItem);
        }
--]]

	-- restore items that fell from the previous depth.
	-- TODO: later

--[[
        mapToStairs = allocGrid();
        fillGrid(mapToStairs, 0);
        mapToPit = allocGrid();
        fillGrid(mapToPit, 0);
        calculateDistances(mapToStairs, player.xLoc, player.yLoc, T_PATHING_BLOCKER, NULL, true, true);
        calculateDistances(mapToPit,
                                           levels[rogue.depthLevel - 1].playerExitedVia[0],
                                           levels[rogue.depthLevel - 1].playerExitedVia[1],
                                           T_PATHING_BLOCKER,
                                           NULL,
                                           true,
                                           true);
        for (monst = monsters->nextCreature; monst != NULL; monst = monst->nextCreature) {
                restoreMonster(monst, mapToStairs, mapToPit);
        }
--]]
	-- restore creatures that fell from the previous depth or that have been pathing toward the stairs.
	-- TODO: later
	return tilemap
end

-- generate and return an arbitrary-length ordered list of integers
function mapgen_broguestyle_fill_sequential_list(size)
	print("mapgen_broguestyle_fill_sequential_list() passed size=" .. size)
	result = {}
	for i=1,size,1 do
		result[i] = i
	end
	return result
end

-- Remove diagonal openings
function mapgen_broguestyle_remove_diagonal_openings(tilemap)
	local diagonal_corner_removed = true
        while diagonal_corner_removed == true do
                diagonal_corner_removed = false
--[[
                for (i=0; i<DCOLS-1; i++) {
                        for (j=0; j<DROWS-1; j++) {
--]]

		for i=1, #tilemap-1, 1 do
			for j=1, #tilemap[1]-1, 1 do

--[[
                                for (k=0; k<=1; k++) {
--]]
				
				for k=0, 1, 1 do

--[[
                                        if (!(tileCatalog[pmap[i + k][j].layers[DUNGEON] ].flags & T_OBSTRUCTS_PASSABILITY)
                                                && (tileCatalog[pmap[i + (1-k)][j].layers[DUNGEON] ].flags & T_OBSTRUCTS_PASSABILITY)
                                                && (tileCatalog[pmap[i + (1-k)][j].layers[DUNGEON] ].flags & T_OBSTRUCTS_DIAGONAL_MOVEMENT)
                                                && (tileCatalog[pmap[i + k][j+1].layers[DUNGEON] ].flags & T_OBSTRUCTS_PASSABILITY)
                                                && (tileCatalog[pmap[i + k][j+1].layers[DUNGEON] ].flags & T_OBSTRUCTS_DIAGONAL_MOVEMENT)
                                                && !(tileCatalog[pmap[i + (1-k)][j+1].layers[DUNGEON] ].flags & T_OBSTRUCTS_PASSABILITY)) {
--]]

--[[
					-- check that these various tiles are all impassable
					if not(
						tilemap[i+(1-k)][j] == 0 and
						tilemap[i+(1-k)][j] == 0 and
						tilemap[i+k][j+1] == 0 and
						tilemap[i+k][j+1] == 0 ) then
--]]
						

--[[

                                                if (rand_percent(50)) {
                                                        x1 = i + (1-k);
                                                        x2 = i + k;
                                                        y1 = j;
                                                } else {
                                                        x1 = i + k;
                                                        x2 = i + (1-k);
                                                        y1 = j + 1;
                                                }
                                                if (!(pmap[x1][y1].flags & HAS_MONSTER) && pmap[x1][y1].machineNumber == 0) {
                            diagonalCornerRemoved = true;
                            for (layer = 0; layer < NUMBER_TERRAIN_LAYERS; layer++) {
                                pmap[x1][y1].layers[layer] = pmap[x2][y1].layers[layer];
                            }
                                                }
                                        }
                                }
                        }
                }
--]]
				end
			end
		end
	end
	return tilemap
end

function mapgen_broguestyle_valid_stair_loc(tilemap,x,y)
	if not tilemap_coordinates_valid(tilemap,x,y) then
		return false
	end
	if tilemap[x][y] == 1 then
		return true
	end
	return false
end

