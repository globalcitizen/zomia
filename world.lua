-- holds world structure
--  - initially generate a 20x20 grid at ground level
world_radius=20
world = {}
for z=-math.floor(world_radius/2),math.floor(world_radius/2),1 do
	world[z] = {}
	for x=1,world_radius*2,1 do
		world[z][x] = {}
		for y=1,world_radius*2,1 do 
			world[z][x][y] = {}
		end
	end
end
	
-- holds location in world
world_location = {z=0,x=10,y=10}
last_world_location = world_location

-- generates world at start of game
function generate_world()
	-- simplified world generation for early release for ARRP2016
	-- 
	--  general plan was:
	--   - tai village
	--      - contains buildings, people, trees, animals, water (later)
	--      - surrounded by four directions
	--      - each direction has one or more paths
	-- 	- directions may lead to forest/wilderness/water/whatever.
        --         - right now to keep things simple its all wilderness
	--      - one direction leads to a tai_cave_entrance
	--   - tai_cave_entrance leads down in to tai_cave
        --   - tai_cave is multi-level, and may be natural, or a salt, iron, tin or silver mine
	--	- player is directed to cave somehow
	--         - cave has subterranean levels, player can kill stuff and return to the town
	--
	--  general plan is now start in the cave, and instead of 'tai_cave' use 'natural_cavern'
	--
	--  therefore, world areas can be identified with xyz coordinates.
	--
	--  we make Z,X,Y instead because it's neater
	world[0][10][10] = {type='tai_village'}
	local cave_location = rng:random(1,4)
	if cave_location == 1 then
		world[-1][10][9] = {type='natural_cavern'}
		world_location = {z=-1,x=10,y=9}
		world[0][10][9] = {type='tai_cave_entrance'}
--		world_location = {z=0,x=10,y=9}
		world[0][10][11] = {type='wilderness'}
		world[0][9][10] = {type='wilderness'}
		world[0][11][10] = {type='wilderness'}
	elseif cave_location == 2 then
		world[0][10][9] = {type='wilderness'}
		world[-1][10][11] = {type='natural_cavern'}
		world_location = {z=-1,x=10,y=11}
		world[0][10][11] = {type='tai_cave_entrance'}
--		world_location = {z=0,x=10,y=11}
		world[0][9][10] = {type='wilderness'}
		world[0][11][10] = {type='wilderness'}
	elseif cave_location == 3 then
		world[0][10][9] = {type='wilderness'}
		world[0][10][11] = {type='wilderness'}
		world[-1][9][10] = {type='natural_cavern'}
		world_location = {z=-1,x=9,y=10}
		world[0][9][10] = {type='tai_cave_entrance'}
--		world_location = {z=0,x=9,y=10}
		world[0][11][10] = {type='wilderness'}
	elseif cave_location == 4 then
		world[0][10][9] = {type='wilderness'}
		world[0][10][11] = {type='wilderness'}
		world[0][9][10] = {type='wilderness'}
		world[-1][11][10] = {type='natural_cavern'}
		world_location = {z=-1,x=11,y=10}
		world[0][11][10] = {type='tai_cave_entrance'}
--		world_location = {z=0,x=11,y=10}
	end
end

function world_load_area(z,x,y)
	-- remember last location
	last_world_location = {z=world_location.z,y=world_location.y,x=world_location.x}
	-- remember seenTiles
	world[world_location.z][world_location.x][world_location.y].seenTiles = seenTiles
	seenTiles={}

	-- set new location
	world_location.z = z
	world_location.y = y
	world_location.x = x

	-- YOU. CANT. Stop the music
	for i,m in pairs(current_area_music) do
		m:stop()
                --table.insert(tweens,flux.to(m,2,{volume=0}))		-- doesn't work
	end
	current_area_music = {}

	-- Say hello
	print("Loading world area @ " .. z .. "," .. x .. "," .. y .. " ...")

	-- if there is no tilemap yet generated, it means the world area still needs to be instantiated
	if world[z] == nil then
		print("Z-index not defined in world at: Z=" .. z)
		os.exit()
	elseif world[z][x] == nil then
		print("X-index not defined in world at: Z=" .. z .. "/X=" .. x)
		os.exit()
	elseif world[z][x][y] == nil then
		print("X-index not defined in world at: Z=" .. z .. "/X=" .. x .. "/Y=" .. y)
		os.exit()
	end
	if world[z][x][y].map == nil then
		print(" - Area tilemap not found, generating...")
		world[z][x][y] = area_generate(z,x,y)
	else
		print(" - Area tilemap already exists.")
	end

	-- if there is no seenTiles table, create it now
	if world[z][x][y].seenTiles == nil then
		world[z][x][y].seenTiles = {}
	end

	-- if there is no footprints table, create it now
	if world[z][x][y].footprints == nil then
		world[z][x][y].footprints = {}
	end

	-- if there is no groundfeatures table, create it now
	if world[z][x][y].groundfeatures == nil then
		world[z][x][y].groundfeatures = {}
	end

	-- clean tilemap in case of nonsense
	world[z][x][y].map = map_sanitize(world[z][x][y].map)

	-- assign maptiles and related from area
	tilemap = world[z][x][y].map
	seenTiles = world[z][x][y].seenTiles
	footprints = world[z][x][y].footprints

	-- if any NPCs are not placed, place them randomly now. also set seen_player to false and initialize health
	if world[z][x][y].npcs ~= nil then
		for i,npc in ipairs(world[z][x][y].npcs) do
			npc.seen_player = false
			if npc.location == nil then
				npc.location = {}
				npcx,npcy = randomStandingLocation(tilemap)
				npc.location['x'] = npcx
				npc.location['y'] = npcy
			end
			if npc.health == nil then
				npc.health = npc.max_health
			end
		end
	end

	-- load npcs
	npcs = world[z][x][y].npcs

	-- load groundfeatures
	groundfeatures = world[z][x][y].groundfeatures

	-- start music
	if world[z][x][y].music ~= nil then
		print("Starting music...")
		music = love.audio.newSource(world[z][x][y].music)
		music:setLooping(true)
		music:play()
		music:setVolume(0)
		local desired_volume = 0.5
		if world[z][x][y].music_volume ~= nil then
			desired_volume = world[z][x][y].music_volume
		end
		music:setVolume(desired_volume)
                --table.insert(tweens,flux.to(music,2,{volume=desired_volume}))		-- deosn't work
		table.insert(current_area_music,music)
	end

	-- start ambience
	if world[z][x][y].ambient ~= nil then
		print("Starting ambience...")
		ambience = love.audio.newSource(world[z][x][y].ambient)
		ambience:setLooping(true)
		ambience:play()
		ambience:setVolume(0)
		local desired_volume = 1
		if world[z][x][y].ambience_volume ~= nil then
			desired_volume = world[z][x][y].ambience_volume
		end
		ambience:setVolume(desired_volume)
                --table.insert(tweens,flux.to(ambience,2,{volume=desired_volume}))	-- doesn't work
		table.insert(current_area_music,ambience)
	end

	-- load colors
	if world[z][x][y].colors ~= nil then
		if world[z][x][y].colors.groundColor ~= nil then
			groundColor = world[z][x][y].colors.groundColor
		end
	end

	-- load fov
	if world[z][x][y].fov ~= nil then
		fov = world[z][x][y].fov
	end

	-- place character intelligently as appropriate
	--  if we just came from below...
	if last_world_location.z == z-1 and last_world_location.y == y and last_world_location.x == x then
	 -- place the player at the '>' (ie. down stairs)
	 upstairs = tilemap_find_maptiletype(tilemap,'>')
	 characterX = upstairs[1].x
	 characterY = upstairs[1].y
	elseif last_world_location.z == z+1 and last_world_location.y == y and last_world_location.x == x then
	 -- place the player at the '<' (ie. up stairs)
	 upstairs = tilemap_find_maptiletype(tilemap,'<')
	 characterX = upstairs[1].x
	 characterY = upstairs[1].y
	end

	-- update visibility
        update_draw_visibility_new()

end


function map_sanitize(map)
	for x=1,#map,1 do
		for y=1,#map,1 do
			-- if the tile is a closed or open door
			if map[x][y] == 2 or map[x][y] == 3 then
				-- count the wall tiles around the this tile
				local wallcount = 0
				for i=1,4,1 do
					dir = directions[i]
					if map[x+dir[1]][y+dir[2]] == 0 then
						wallcount = wallcount + 1
					end
				end
				-- if there are not exactly two walls next to this tile
				if wallcount ~= 2 then
					-- remove the door by setting it to 1 (floor)
					map[x][y] = 1
				else
                                	-- the door still exists. check there are no diagonally adjacent doors, which causes graphical issues
					local found_a_diagonal = false
					for i=5,8,1 do
						dir = directions[i]
						if map[x+dir[1]][y+dir[2]] == 2 or map[x+dir[1]][y+dir[2]] == 3 then
							found_a_diagonal = true
							break
						end
					end
					if found_a_diagonal == true then
						-- remove the door by setting it to 1 (floor)
						map[x][y] = 1
					end
				end
			end
		end
	end
	return map
end

