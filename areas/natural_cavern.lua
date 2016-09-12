area_types['natural_cavern'] = {
				 name  = 'Natural Cavern',
				 setup = function(instance) 
                                        instance.name='Cavern'
                                        instance.prefix='Natural '

					-- Generate an appropriate map
					local new_tilemap
					new_tilemap = tilemap_new()

					-- OLD generate tilemap
					--[[
					        cl=ROT.Map.Cellular:new(resolutionTilesX, resolutionTilesY) -- , {connected=true})
					        cl:randomize(.50)  -- .50 is the probability any given tile is a floor
					        cl=ROT.Map.Rogue:new(resolutionTilesX, resolutionTilesY)
					        cl:create(tile_callback)
					--]]

					-- NEW generate tilemap
        				--  width,
        				--  height,
        				--  changeDirectionModifier,    (10 = super straight, 90 = wiggly as hell)   = "wiggliness"
        				--  sparsenessModifier,         (10 = full of corridors, 90 = full of rock)  = "rockiness"
        				--  deadEndRemovalModifier,     (10 = lots of dead ends, 100 = no dead ends) = "connectedness"
        				--  roomGenerator
        				--    - noOfRoomsToPlace
        				--    - minRoomWidth
        				--    - maxRoomWidth
        				--    - minRoomHeight
        				--    - maxRoomHeight
        				local symbols = {Wall=0, Empty=1, DoorN=2, DoorS=2, DoorE=2, DoorW=2}
        				--local generator = astray.Astray:new( math.floor(resolutionTilesX/2), math.floor(resolutionTilesY/2), 30, 20, 90, astray.RoomGenerator:new(10,1,5,1,5) )
        				--local generator = astray.Astray:new( resolutionTilesY-1, math.floor(resolutionTilesY/2)-1, 30, 20, 90, astray.RoomGenerator:new(10,1,5,1,5) )
        				--local generator = astray.Astray:new( resolutionTilesX/2-1, resolutionTilesY/2-1, 30, 20, 90, astray.RoomGenerator:new(10,1,5,1,5) )
				        local generator = astray.Astray:new( resolutionTilesX/2-1, resolutionTilesY/2-1, 25, 90, 80, astray.RoomGenerator:new(22,2,5,2,5) )
				        local dungeon = generator:Generate()
				        local tmp_tilemap = generator:CellToTiles(dungeon, symbols )
  				      	-- the astray generator begins its tilemap at row 0 and column 0 instead of row 1 and column 1, which does not match other lua code
 				       	for y = 1, #tmp_tilemap[1] do
						local line = ''
                				for x = 1, #tmp_tilemap do
                        				local nx=x-1
                        				local ny=y-1
                        				if tmp_tilemap[nx] ~= nil and tmp_tilemap[nx][ny] ~= nil then
                                				new_tilemap[x][y] = tmp_tilemap[nx][ny]
                        				end
                				end
        				end
					-- assign new map
					instance.map=new_tilemap

					-- Populate with NPCs
					instance.npcs = {}
				        add_npcs(instance.npcs,'goblin',5)
				        add_npcs(instance.npcs,'mouse',1)
			
				        -- ground features
				        for i=1,120,1 do
				                groundfeatures[i] = {}
				                groundfeatures[i]['x'],groundfeatures[i]['y'] = randomStandingLocation(new_tilemap)
				                if i < 3 then
				                        groundfeatures[i]['type'] = 'shrub'
				                elseif i < 10 then
				                        groundfeatures[i]['type'] = 'puddle'
				                elseif i < 20 then
				                        groundfeatures[i]['type'] = 'moss'
						else
				                        groundfeatures[i]['type'] = 'stone'
				                end
				        end

				        -- place stairs
				        print "Randomly placing stairs..."
				        stairsX, stairsY = randomStandingLocation(instance.map)
				        instance.map[stairsX][stairsY] = '>'
				        stairsX, stairsY = randomStandingLocation(instance.map)
				        instance.map[stairsX][stairsY] = '<'
--[[
				
				        -- music
					--[[
					instance.music = {
				                                        "music/Greg_Reinfeld_-_02_-_Canon_in_D_ni_nonaC_Pachelbels_Canon.mp3",
				                                        "music/Kevin MacLeod - Sardana.mp3",
				                                        "music/Kevin MacLeod - Suonatore di Liuto.mp3",
				                                        "music/Kevin MacLeod - Teller of the Tales.mp3",
				                                        "music/Komiku_-_03_-_Champ_de_tournesol.mp3",
				                                        "music/Komiku_-_05_-_La_Citadelle.mp3",
				                                        "music/Komiku_-_06_-_La_ville_aux_ponts_suspendus.mp3"
				                         }
					instance.music_volume=0.05
					--]]
					-- ambient noise
					instance.ambient = {
				                                                "sounds/ambient/cave-drips.mp3"
				                           }
					instance.ambient_volume = 2

					-- colors
                                        instance.colors={}
                                        instance.colors['groundColor'] = {25,25,25}

					-- FOV
					instance.fov = 15
				 end
		       	    }


-- An implementation of map generation loosley inspired by the description of Brogue's wonderful dungeon generation
-- by its author Brian Walker (Pender) in his 2015 interview at Rock, Paper, Shotgun...
--  https://www.rockpapershotgun.com/2015/07/28/how-do-roguelikes-generate-levels/
function mapgen_broguestyle(width,height)

	-- Begin with blank (rock/wall) tiles
	local new_tilemap = tilemap_new(width,height,0)

	-- First, place a room.
	new_tilemap = mapgen_broguestyle_design_random_room(new_tilemap)

--[[ Then, it draws another room on another grid, which it slides like a piece of cellophane over the level until the new room fits snugly against an existing room without touching or overlapping. When there’s a fit, it transfers the room from the cellophane to the master grid and punches out a door. It does that repeatedly until it can’t fit any more rooms.

That first room can sometimes be a “cavern” — a large, winding, organic shape that fills a lot of the space of the level. Those are made by filling the level randomly with 55% floor and 45% wall, and then running five rounds of smoothing. In every round of smoothing, every floor cell with fewer than four adjacent floor cells becomes a wall, and every wall cell with six or more adjacent floor cells becomes a floor. This process forces the random noise to coalesce and contract into a meandering blob shape. The algorithm picks the biggest blob that is fully connected and calls that the first room.

There are a bunch of different techniques for drawing a room, chosen at random each time — for example, two large rectangles overlaid on each other, a large donut shape, a circle or a “blob” produced like the cavern described above but with smaller dimensions. Sometimes, we’ll generate the room with a hallway sticking off of it at a random point, and require that the end of the hallway connect to an existing room.
--]]

	-- Second, attach additional rooms
	new_tilemap = mapgen_broguestyle_attach_rooms(new_tilemap)

--[[
At this point we have a simply connected network of differently shaped rooms. The problem is that there are no loops in the geometry; the entire map is a single tree, where each room after the first has exactly one “parent” room (that it grew off from) and any number of “child” rooms (that grew off from it). It turns out it’s not much fun to explore that kind of level, because it requires a lot of backtracking and it’s easy to get cornered by monsters. So, we start inspecting the walls of the level. If we can find a wall that has a passable cell on both sides of it, where the two cells are at least certain distance apart in terms of pathfinding, we punch out a door (or a secret door). Do that a bunch of times and you get a level that’s nicely connected.

Then we move onto lakes. Lakes are masses of a particular terrain type — water, lava, chasm or brimstone — that can span almost the entire level. They’re atmospheric, they enable long-distance attacks, and they impose structure on the level at a large scale to prevent it from feeling like a homogenous maze of twisty passages. We pull out the cellophane and draw a lake on it using the cellular automata method, and then we slide the cellophane around to random locations until we find a place that works — where all of the passable parts of the level that aren’t covered by lake are still fully connected, so the player is never required to cross the lake. If twenty random tries fails to find a qualifying location, we draw a smaller lake and try again. If we can find a qualifying location, we drop the lake onto the map there and overwrite the terrain underneath it. Some lakes have wreaths — shallow water surrounds deep water, and “chasm edge” terrain surrounds chasms — and we draw that in at this stage.

Next up are the flavorful local features of terrain — tufts of grass, outgrowths of crystal, mud pits, hidden traps, statues, torches and more. These are defined in a giant table of “autogenerators” that specifies the range of depths in which each feature can appear, how likely it is and how many copies to make. For each one, we pick a random location and spawn it. A lot of them spawn in patches. Those are generated by picking an initial location and letting it randomly expand outward from there, with the probability of further expansion lowering with each expansion — like pouring some paint on an uneven floor and letting it flow outward into a puddle.

The next major step in level generation is what I call the machines. This is the most complicated part of the level generation by far. Machines are clusters of terrain features that relate to one another. Any time you see an altar, or an instance where interacting with terrain at one point causes terrain at a distant point to do something, you’re looking at a machine. There’s a hand-designed table of machines — 71 of them at the moment — that guides where and why each machine should spawn and what features it should create. Each machine feature further specifies whether it should only spawn near the doorway of the room, or far away from it, or in view of it, or never in a hallway, or only in the walls surrounding the machine, and so on.

There are three types of machines — room machines that occupy the interior of an area with a single chokepoint, door machines that are spawned by room machines to guard the door, and area machines that can spawn anywhere and spread outward until they are the appropriate size. Some machines will bulldoze a portion of the level and run a new level generation algorithm with different parameters on that specific region; that is how you get goblin warrens as dense networks of cramped mud-lined rooms, and sentinel temples as crystalline palaces of circular and cross-shaped rooms. Sometimes a machine will generate an item such as a key and pass it to another machine to adopt the item; that is how you get locked doors with the key guarded by a trap elsewhere on the level. Sometimes the machine that holds the key is guarded by its own locked door, and the key for that door is somewhere else — there’s no limit to how many layers of nesting are allowed, and the hope is that nested rooms will lend a kind of narrative consistency to the level through interlocking challenges. The game keeps track of which portions of the level belong to which machines, and certain types of terrain activations will trigger activations elsewhere in the machine; that is how lifting a key off of an altar can cause a torch on the other side of the room to ignite the grass in the room. The machine architecture is a hodge-podge of features intended to translate entries of a table into self-contained adventures with hooks to link them to other adventures.

After the machines are built, we place the staircases. The upstairs tries to get as close as possible to the location of the downstairs location from the floor above, and the downstairs picks a random qualifying location that’s a decent distance away from the upstairs. Stairs are used automatically when the player walks into them, and they’re recessed into the wall so that there’s no other reason to walk into them. That limits the number of locations in which they can spawn, but they’re generally able to connect pretty closely to the locations on adjacent levels.

Then we do some clean-up. If there’s a diagonal opening between two walls, we knock down one of the walls. If a door has fewer than two adjacent walls, we knock down the door. If a wall is surrounded by similar impassable terrain on both sides — think of a wall running down the middle of a lava lake, or across a chasm — we knock it down. This is also where bridges are built across chasms where it makes sense — where both sides connect and shorten the pathing distance between the two endpoints significantly.

Items are next, beyond what was already placed by machines. There’s a cute trick to decide where to place items. Imagine a raffle, in which each empty cell of the map enters a certain number of tickets into the raffle. A cell starts with one ticket. For every door that the player has to pass to reach the cell, starting from the upstairs, the cell gets an extra ten tickets. For every secret door that the player has to pass to reach the cell, the cell gets an extra 3,000 tickets. If the cell is in a hallway or on unfriendly terrain, it loses all of its tickets. Before placing an item, we do a raffle draw — so caches of treasure are more likely in well hidden areas, off the beaten path. When we place an item, we take away some of the tickets from the nearby areas to avoid placing all of the items in a single clump. (Food and strength potions are exceptions; they’re placed without a bias for hidden rooms, because they are carefully metered, and missing them can set the player back significantly.) There are also more items on the very early levels, to hasten the point at which the player can start cobbling together a build.

Last are monster hordes. They get placed randomly and uniformly — but not in view of the upstairs, so the player isn’t ambushed the first time she sets foot on the level. Sometimes the monsters are drawn from a deeper level or spawned with a random mutation to keep the player on her toes.

And that finishes the level!

Many of the probabilities throughout this process vary by depth. Levels become more organic and cavern-like as you go deeper, you’ll start to see more lava and brimstone, secret doors become more common, grass and healing plants will become rarer and traps and crystal formations will become more frequent. It’s gradual, but if you manage to grab the Amulet of Yendor on the 26th level, the difference is noticeable during the rapid ascent.
--]]

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
		4. Chunky room :: designChunkyRoom()
		5. Cave :: designCavern()
		6. Cavern :: designCavern() with different arguments
		7. Entrance room (the big upside-down T room at the start of depth 1) :: designEntranceRoom()
	]]--

	-- currently we have only implemented room types 0-4 and 7.
	roomtype = rng:random(0,5)
	if roomtype == 0 then
		tilemap = mapgen_broguestyle_room_cross(tilemap)
	elseif roomtype == 1 then
		tilemap = mapgen_broguestyle_room_sym(tilemap)
	elseif roomtype == 2 then
		tilemap = mapgen_broguestyle_room_small(tilemap)
	elseif roomtype == 3 then
		tilemap = mapgen_broguestyle_room_circular(tilemap)
	elseif roomtype == 4 then
		tilemap = mapgen_broguestyle_room_chunky(tilemap)
	elseif roomtype == 5 then
		tilemap = mapgen_broguestyle_room_entrance(tilemap)
	end
	
	if doorsites ~= nil then
		mapgen_broguestyle_choose_random_doorsites(tilemap,doorsites)
		if attach_hallway then
			dir = rng:random(0,3)
			for i=0, 3, 1 do
				if doorSites[dir][0] ~= -1 then 
					i = 3
				else
					dir = (dir + 1) % 4 -- each room will have at least 2 valid directions for doors.
				end
			end
			mapgen_broguestyle_attach_hallway_to(tilemap, doorsites);
		end
	end

	return tilemap
end

function mapgen_broguestyle_room_cross(tilemap)
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

	--[[
	    drawRectangleOnGrid(grid, roomX - 5, roomY + 5, roomWidth, roomHeight, 1);
	    drawRectangleOnGrid(grid, roomX2 - 5, roomY2 + 5, roomWidth2, roomHeight2, 1);
	--]]
	tilemap_draw_recangle(tilemap,x-5,y+5,roomwidth,roomheight,1)
	tilemap_draw_recangle(tilemap,x2-5,y2+5,roomwidth2,roomheight2,1)

	return tilemap
end

function mapgen_broguestyle_room_symcross(tilemap)
	--[[
		majorWidth = rand_range(4, 8);
		majorHeight = rand_range(4, 5);
    		minorWidth = rand_range(3, 4);
	--]]
	majorwidth = rng:random(4,8)
	majorheight = rng:random(4,5)
	minorwidth = rng:random(3,4)

	--[[
	    if (majorHeight % 2 == 0) {
	        minorWidth -= 1;
	    }
	    minorHeight = 3;//rand_range(2, 3);
	    if (majorWidth % 2 == 0) {
	        minorHeight -= 1;
	    }
	--]]
	if majorheight % 2 == 0 then
		minorwidth = minorwidth - 1
	end
	minorheight = 3
	if majorwidth % 2 == 0 then
		minorheight = minorheight - 1
	end

	--[[
	    drawRectangleOnGrid(grid, (DCOLS - majorWidth)/2, (DROWS - minorHeight)/2, majorWidth, minorHeight, 1);
	    drawRectangleOnGrid(grid, (DCOLS - minorWidth)/2, (DROWS - majorHeight)/2, minorWidth, majorHeight, 1);
	--]]
	tilemap_draw_recangle(tilemap, (#tilemap - majorwidth)/2, (#tilemap[1] - minorheight)/2, majorwidth, minorheight, 1)
	tilemap_draw_recangle(tilemap, (#tilemap - minorwidth)/2, (#tilemap[1] - majorheight)/2, minorwidth, majorheight, 1)

	return tilemap
end

function mapgen_broguestyle_room_small(tilemap)
	--[[
    		width = rand_range(3, 6);
    		height = rand_range(2, 4);
    		drawRectangleOnGrid(grid, (DCOLS - width) / 2, (DROWS - height) / 2, width, height, 1);
	--]]
	width = rng:random(3,6)
	height = rng:random(2,4)
	tilemap_draw_rectangle(tilemap, (#tilemap - width) / 2, (#tilemap[1] - height) / 2, width, height, 1)
	return tilemap
end

function mapgen_broguestyle_room_circular(tilemap)
	--[[
		if (rand_percent(5)) {
		    radius = rand_range(4, 10);
		} else {
		    radius = rand_range(2, 4);
		}
	--]]
	if rng:random(5,100) <= 5 then
		radius = rng:random(4,10)
	else
		radius = rng:random(2,4)
	end

	--[[
		drawCircleOnGrid(grid, DCOLS/2, DROWS/2, radius, 1);
	--]]
	tilemap_draw_circle(tilemap, #tilemap/2, #tilemap[1]/2, radius, 1)

	--[[
		if (radius > 6
		    && rand_percent(50)) {
		    drawCircleOnGrid(grid, DCOLS/2, DROWS/2, rand_range(3, radius - 3), 0);
		}
	--]]
	if radius > 6 and rng:random(1,100)<=50 then
		tilemap_draw_circle(tilemap, #tilemap/2, #tilemap[1]/2, rng:random(3,radius-3), 0)
	end

	return tilemap
end

function mapgen_broguestyle_room_chunky(tilemap)
	--[[
		short chunkCount = rand_range(2, 8);
		drawCircleOnGrid(grid, DCOLS/2, DROWS/2, 2, 1);
	--]]
	chunkcount = rng:random(2,8)
	tilemap_draw_circle(tilemap, #tilemap/2, #tilemap[1]/2, 2, 1)

	--[[
		minX = DCOLS/2 - 3;
		maxX = DCOLS/2 + 3;
		minY = DROWS/2 - 3;
		maxY = DROWS/2 + 3;
	--]]
	minx = #tilemap/2 - 3
	maxx = #tilemap/2 + 3
	miny = #tilemap[1]/2 - 3
	maxy = #tilemap[1]/2 + 3

	--[[
		    for (i=0; i<chunkCount;) {
		        x = rand_range(minX, maxX);
		        y = rand_range(minY, maxY);
		        if (grid[x][y]) {
		            drawCircleOnGrid(grid, x, y, 2, 1);
		            i++;
		            minX = max(1, min(x - 3, minX));
		            maxX = min(DCOLS - 2, max(x + 3, maxX));
		            minY = max(1, min(y - 3, minY));
		            maxY = min(DROWS - 2, max(y + 3, maxY));
		        }
		    }
	--]]
	for i=0,chunkcount,0 do
		x = rng:random(minx,maxx)
		y = rng:random(miny,maxy)
		if tilemap[x][y] == 0 then
			tilemap_draw_circle(tilemap,x,y,2,1)
			i = i + 1
			minx = math.max(1, math.min(x - 3, minx))
			maxx = math.min(#tilemap - 2, math.max(x + 3, maxx))
			miny = math.max(1, math.min(y - 3, miny))
			maxy = math.min(#tilemap[1] - 2, math.max(y + 3, maxy))
		end
	end
	return tilemap
end

-- this one requires rotLove cellular automata library integration
function mapgen_broguestyle_room_cavern(tilemap,minwidth,maxwidth,minheight,maxheight)

	local foundfillpoint = false
	--[[
	    createBlobOnGrid(blobGrid, &caveX, &caveY, &caveWidth, &caveHeight, 5, minWidth, minHeight, maxWidth, maxHeight, 55, "ffffffttt", "ffffttttt");
	--]]
	--blobgrid = tilemap_newblob(#tilemap,#tilemap[1],minwidth,minheight,maxwidth,maxheight,percentseeded))
	blobgrid = ROT.Map.Cellular:new(minwidth,maxwidth,{topology=8,minimumZoneArea=math.max(minheight,minwidth)})

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
end

function mapgen_broguestyle_room_entrance(tilemap)
	--[[
    roomWidth = 8;
    roomHeight = 10;
    roomWidth2 = 20;
    roomHeight2 = 5;
    roomX = DCOLS/2 - roomWidth/2 - 1;
    roomY = DROWS - roomHeight - 2;
    roomX2 = DCOLS/2 - roomWidth2/2 - 1;
    roomY2 = DROWS - roomHeight2 - 2;
    drawRectangleOnGrid(grid, roomX, roomY, roomWidth, roomHeight, 1);
    drawRectangleOnGrid(grid, roomX2, roomY2, roomWidth2, roomHeight2, 1);
	--]]
	roomwidth=8
	roomheight=10
	roomwidth2=20
	roomheight2=5
	roomx = #tilemap/2 - roomwidth/2 - 1
	roomy = #tilemap[1] - roomheight - 2
	roomx2 = #tilemap/2 - roomwidth2/2 - 1
	roomy2 = #tilemap[1] - roomheight2 - 2
	tilemap_draw_rectangle(tilemap,roomx,roomy,roomwidth,roomheight,1)
	tilemap_draw_rectangle(tilemap,roomx2,roomy2,roomwidth2,roomheight2,1)
end

function mapgen_broguestyle_attach_rooms(tilemap,max_attempts,max_roomcount)
--[[
    fillSequentialList(sCoord, DCOLS*DROWS);
    shuffleList(sCoord, DCOLS*DROWS);
--]]
	-- First we shuffle a per-axis ordered matrix the size of our map
	-- FIXTHIS: TODO

--[[
    roomMap = allocGrid();
--]]
	-- Then we get a new map structure the same size
	local roommap = tilemap_new(#tilemap,#tilemap[1],0)

--[[
    for (roomsBuilt = roomsAttempted = 0; roomsBuilt < maxRoomCount && roomsAttempted < attempts; roomsAttempted++) {
--]]

	local roomsbuilt = 0
	local roomsattempted=0

	for roomsattempted=0, max_attempts, 1 do
		if roomsbuild >= max_roomcount then
			break
		end

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

		for i=0, (#tilemap * #tilemap[1]), 1 do
			x = scoord[i] / #tilemap[1]
			y = scoord[i] % #tilemap[1]
			dir = tilemap_door_direction(tilemap,x,y)
			oppdir = tilemap_opposite_direction(dir)
	
--[[
            if (dir != NO_DIRECTION
                && doorSites[oppDir][0] != -1
                && roomFitsAt(grid, roomMap, x - doorSites[oppDir][0], y - doorSites[oppDir][1])) {
]]--

			if dir ~= nil and doorsites[oppdir][0] != -1 and tilemap_room_fits_at(tilemap,roommap,x-doorsites[oppdir][0],y-doorsites[oppdir][1]) then

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
	end
end
