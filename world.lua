-- holds world structure
--  - initially generate a 20x20 grid at ground level
world = {}
world[0] = {}
for i=0,20,1 do
	world[0][i] = {}
	for j=0,20,1 do
		world[0][i][j] = ''
	end
end
	
-- holds location in world
world_location={0,10,10}

-- generates world at start of game
function generate_world()
	-- simplified world generation for early release for ARRP2016
	-- 
	--  general plan is:
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
	--  therefore, world areas can be identified with xyz coordinates.
	--
	--  we make Z,X,Y instead because it's neater
	world[0][10][10] = {type='tai_village'}
	math.randomseed(os.time())
	local cave_location = math.random(1,4)
	if cave_location == 1 then
		world[0][10][9] = {type='tai_cave_entrance'}
		world[0][10][11] = {type='wilderness'}
		world[0][9][10] = {type='wilderness'}
		world[0][11][10] = {type='wilderness'}
	elseif cave_location == 2 then
		world[0][10][9] = {type='wilderness'}
		world[0][10][11] = {type='tai_cave_entrance'}
		world[0][9][10] = {type='wilderness'}
		world[0][11][10] = {type='wilderness'}
	elseif cave_location == 3 then
		world[0][10][9] = {type='wilderness'}
		world[0][10][11] = {type='wilderness'}
		world[0][9][10] = {type='tai_cave_entrance'}
		world[0][11][10] = {type='wilderness'}
	elseif cave_location == 4 then
		world[0][10][9] = {type='wilderness'}
		world[0][10][11] = {type='wilderness'}
		world[0][9][10] = {type='wilderness'}
		world[0][11][10] = {type='tai_cave_entrance'}
	end
end

function world_load_area(z,x,y)
	-- if there is no tilemap yet generated, it means the world area still needs to be instantiated
	if world[z][x][y].tilemap == nil then
		area_generate(z,x,y])
	end

	-- assign maptiles from area
	tilemap = randomStandingLocation(world[z][x][y].tilemap)

        -- correctly place character
        print "Placing character..."
        characterX, characterY = randomStandingLocation(tilemap)

	-- start music
	print("Starting music...")
	music = love.audio.newSource(world[z][x][y].music)
	music:setLooping(true)
	music:play()
	music:setVolume(world[z][x][y].music_volume)

	-- start ambience
	print("Starting ambience...")
	ambience = love.audio.newSource(world[z][x][y].ambient)
	ambience:setLooping(true)
	music:setVolume(world[z][x][y].ambient_volume)
	ambience:play()

end
