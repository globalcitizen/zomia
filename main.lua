-- libraries
ROT=require 'libs/rotLove/rotLove/rotLove'
astray=require 'libs/astray/astray'
require 'libs/slam/slam'

-- game portions
require 'npcs'
require 'areas'
require 'world'

-- utilities
require 'tableshow'
require 'split'

-- keyboard
love.keyboard.setKeyRepeat(true)

-- sound
music = 0
sounds={}

-- basics
inventory = {sword={qty=1,attack={qty=1,faces=6,bonus=3},name="A'Long the deathbringer"},['edible moss']={qty=5},['dry mushrooms']={qty=30}}
equipment = {left_hand='sword'}
beautify=true
experimentalFov=true
simpleAreaShade=false
--beautify=false
characterX=1
characterY=1
tilePixelsX=16
tilePixelsY=16
tilemap = {}
visibleTiles = {}
seenTiles = {}
logMessages = {}

-- colors
characterSmallness=4
notifyMessageColor={128,128,128}
failMessageColor={195,50,50}
vegetableMessageColor={50,115,50}
waterMessageColor={50,50,195}
rockColor={0,0,0}
groundColor={25,25,25}
doorColor={88,6,8}
circleColor={0,128,128}
characterColor={205,205,0}
defaultNpcColor={255,255,255}
defaultNpcLabelColor={255,255,255}
npcLabelShadowColor={0,0,0,128}
logMessageColor={200,200,200,255}
popupShadeColor={0,0,0,70}
popupBorderColor={128,128,128}
popupBackgroundColor={28,28,28}
popupTitleColor={255,255,255}
popupBlingTextColor={255,255,255}
popupBrightTextColor={188,188,188}
popupNormalTextColor={128,128,128}
popupDarkTextColor={75,75,75}

-- footprints
footprints = {}
max_footprints=130

-- ground features
groundfeatures = {}

-- determine available fullscreen modes
print('Querying available fullscreen modes...')
modes = love.window.getFullscreenModes()
-- sort from smallest to largest
table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)
-- get largest
v = modes[#modes]
-- report
print(' - Reported maximum full screen resolution: ' .. v.width .. ' x ' .. v.height .. ' pixels')
resolutionPixelsX=v.width
resolutionPixelsY=v.height
screenModeFlags = {fullscreen=true, fullscreentype='desktop', vsync=true, msaa=0}
-- screenModeFlags = {fullscreen=true}

function love.load()


	-- load font
	print('Loading fonts')
        heavy_font = love.graphics.newFont("fonts/pf_tempesta_five_extended_bold.ttf",8)
        medium_font = love.graphics.newFont("fonts/pf_tempesta_five_bold.ttf",8)
        light_font = love.graphics.newFont("fonts/pf_tempesta_five.ttf",8)
	love.graphics.setFont(light_font)

	-- hide mouse
	print('Hiding mouse')
	love.mouse.setVisible(false)

	-- set up graphics mode
	print('Attempting to switch to fullscreen resolution.')
	love.window.setMode(resolutionPixelsX, resolutionPixelsY, screenModeFlags)
	resolutionPixelsX = love.graphics.getWidth()
	resolutionPixelsY = love.graphics.getHeight()
	print(' - Resolution obtained: ' .. resolutionPixelsX .. ' x ' .. resolutionPixelsY .. ' pixels')

	-- now determine tile resolution
	print('     - Tile size: ' .. tilePixelsX .. ' x ' .. tilePixelsY .. ' pixels')
	resolutionTilesX=math.floor(resolutionPixelsX/tilePixelsX)
	resolutionTilesY=math.floor(resolutionPixelsY/tilePixelsY)
	print('     - Displayable tilemap size: ' .. resolutionTilesX .. ' x ' .. resolutionTilesY .. ' tiles')

	-- generate world
	print('Generating world.')
	generate_world()

	-- load initial world location
	world_load_area(0,10,10)

	-- update visibility
	if experimentalFov then
		update_draw_visibility_new()
		--update_draw_visibility()
	end

	print('--------------------------- OK! Here we go! ---------------------------------')
end

function love.keypressed(key)
        if key == "left" or key == "4" then
                moveCharacterRelatively(-1,0)
        elseif key == "right" or key == "6" then
                moveCharacterRelatively(1,0)
        elseif key == "up" or key == "8" then
                moveCharacterRelatively(0,-1)
        elseif key == "down" or key == "2" then
                moveCharacterRelatively(0,1)
	elseif key == "1" then
		moveCharacterRelatively(-1,1)
	elseif key == "3" then
		moveCharacterRelatively(1,1)
	elseif key == "7" then
		moveCharacterRelatively(-1,-1)
	elseif key == "9" then
		moveCharacterRelatively(1,-1)
        elseif key == "c" then
		-- attempt to close nearby doors
		closedoors()
        elseif key == "o" then
		-- attempt to open nearby doors
		opendoors()
        elseif key == "escape" then
		love.event.quit()
	-- '>'
	elseif key == "." and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
		descend()
	-- '<'
	elseif key == "," and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
		ascend()
        end
	-- redetermine visibility of all squares
	if experimentalFov then
		update_draw_visibility_new()
		--update_draw_visibility()
	end
end

function love.draw()
	--local start_time = love.timer.getTime()
	if experimentalFov then
		draw_tilemap_visibilitylimited()
	else
		draw_tilemap()			-- rare changes (~4-5ms or so)
	end
        --draw_tilemap_beautification()           -- rare changes (costs ~1ms or so)
	--local draw_tilemap_time = love.timer.getTime()-start_time
	--print( string.format( "Time to draw tilemap: %.3f ms", draw_tilemap_time*1000))

	-- currently these are all redrawn every frame... could optimize this later
	--local start_time = love.timer.getTime()
	if experimentalFov then
		draw_footprints_visibilitylimited()
		draw_groundfeatures_visibilitylimited()
		draw_doors_visibilitylimited()
		draw_stairs_visibilitylimited()
		draw_character()
		draw_npcs_visibilitylimited()
		draw_poorvisibility_overlay()
	else
		draw_footprints()			-- frequent changes
		draw_groundfeatures()			-- occasional changes
		draw_doors()				-- occasional changes
		draw_stairs()				-- never changes
		draw_character()			-- frequent changes
		draw_npcs()				-- frequent changes
	end
	--local draw_dynamics_time = love.timer.getTime()-start_time
	--print( string.format( "Time to draw dynamics: %.3f ms", draw_dynamics_time*1000))

	-- highly dynamic, usually no drawing at all
	draw_logmessages()
	draw_popups()

	if experimentalFov then
		-- draw_visibility_overlay()
	end
	draw_coordinates_overlay()

	if simpleAreaShade then
		draw_simpleareashade()
	end
end

function draw_tilemap()
	-- draw tilemap
	local x, y = 1
	for x=1,resolutionTilesX,1 do
		for y=1,resolutionTilesY,1 do
			-- 1 = floor, 2 = closed door, 3 = open door, '<' = upward stairs, '>' = downward stairs
			if tilemap[x][y] == 1 or tilemap[x][y] == 2 or tilemap[x][y] == 3 or tilemap[x][y] == '<' or tilemap[x][y] == '>' then
				love.graphics.setColor(groundColor)
				love.graphics.rectangle("fill", (x-1)*tilePixelsX, (y-1)*tilePixelsX, tilePixelsX, tilePixelsY)
			end
		end
	end
end

function draw_footprints()
	-- draw footprints
	love.graphics.setColor(50,50,50,50)
	for i,footprint in ipairs(footprints) do
		love.graphics.rectangle('line',(footprint['x']-1)*tilePixelsX+2,(footprint['y']-1)*tilePixelsY+2,3,3)
		love.graphics.rectangle('line',(footprint['x']-1)*tilePixelsX+8,(footprint['y']-1)*tilePixelsY+8,3,3)
	end
end

function draw_footprints_visibilitylimited()
	-- draw footprints
        for i=1,#visibleTiles,1 do
                local tile = visibleTiles[i]
                x=tile.x
                y=tile.y
		for j,footprint in ipairs(footprints) do
			if footprint['x']==x and footprint['y']==y then
				love.graphics.rectangle('line',(footprint['x']-1)*tilePixelsX+2,(footprint['y']-1)*tilePixelsY+2,3,3)
				love.graphics.rectangle('line',(footprint['x']-1)*tilePixelsX+8,(footprint['y']-1)*tilePixelsY+8,3,3)
			end
		end
	end
end

function draw_groundfeatures()
	-- draw groundfeatures
	for i,feature in ipairs(groundfeatures) do
		if feature['type'] == 'shrub' then
			love.graphics.setColor(20,85,30,90)
			love.graphics.line(
						(feature['x']-1)*tilePixelsX+4, (feature['y']-1)*tilePixelsY+2,
						(feature['x']-1)*tilePixelsX+6, (feature['y']-1)*tilePixelsY+13,
						(feature['x']-1)*tilePixelsX+12, (feature['y']-1)*tilePixelsY+4
					  )
			love.graphics.line(
						(feature['x']-1)*tilePixelsX+6, (feature['y']-1)*tilePixelsY+13,
						(feature['x']-1)*tilePixelsX+8, (feature['y']-1)*tilePixelsY+5
					  )
		elseif feature['type'] == 'puddle' then
			love.graphics.setColor(0,10,65,155)
			love.graphics.circle('fill',(feature['x']-1)*tilePixelsX+tilePixelsX/2, (feature['y']-1)*tilePixelsY+tilePixelsY/2, (tilePixelsX/2)-5)
		elseif feature['type'] == 'stone' then
			love.graphics.setColor(rockColor,120)
			love.graphics.circle('fill',(feature['x']-1)*tilePixelsX+tilePixelsX/2+3, (feature['y']-1)*tilePixelsY+tilePixelsY/2+6, (tilePixelsX/4)-3)
		end
	end
end

function draw_groundfeatures_visibilitylimited()
	-- draw groundfeatures
        for i=1,#visibleTiles,1 do
                local tile = visibleTiles[i]
                x=tile.x
                y=tile.y
		for i,feature in ipairs(groundfeatures) do
			if feature['x'] == x and feature['y'] == y then
				if feature['type'] == 'shrub' then
				love.graphics.setColor(20,85,30,90)
					love.graphics.line(
								(feature['x']-1)*tilePixelsX+4, (feature['y']-1)*tilePixelsY+2,
								(feature['x']-1)*tilePixelsX+6, (feature['y']-1)*tilePixelsY+13,
								(feature['x']-1)*tilePixelsX+12, (feature['y']-1)*tilePixelsY+4
							  )
					love.graphics.line(
								(feature['x']-1)*tilePixelsX+6, (feature['y']-1)*tilePixelsY+13,
								(feature['x']-1)*tilePixelsX+8, (feature['y']-1)*tilePixelsY+5
							  )
				elseif feature['type'] == 'puddle' then
					love.graphics.setColor(0,10,65,155)
					love.graphics.circle('fill',(feature['x']-1)*tilePixelsX+tilePixelsX/2, (feature['y']-1)*tilePixelsY+tilePixelsY/2, (tilePixelsX/2)-5)
				elseif feature['type'] == 'stone' then
					love.graphics.setColor(rockColor,120)
					love.graphics.circle('fill',(feature['x']-1)*tilePixelsX+tilePixelsX/2+3, (feature['y']-1)*tilePixelsY+tilePixelsY/2+6, (tilePixelsX/4)-3)
				end
			end
		end
	end
end

function draw_stairs_visibilitylimited()
        for i=1,#visibleTiles,1 do
                local tile = visibleTiles[i]
                x=tile.x
                y=tile.y
		if tilemap[x][y] == '>' or tilemap[x][y] == '<' then
			love.graphics.setColor(0,0,0,255)
			love.graphics.rectangle('fill',(x-1)*tilePixelsX,(y-1)*tilePixelsY+2,tilePixelsX-3,tilePixelsY-3)
			love.graphics.setColor(255,255,255,255)
			local total_lines = math.floor(tilePixelsX*0.7/2.5)
			local colorstep = 130/total_lines
			for i=1,total_lines,1 do
				love.graphics.setColor(255-(i*colorstep),255-(i*colorstep),255-(i*colorstep),255-(i*colorstep))
				if true or tilemap[x][y] == '>' then
					love.graphics.line(
								(x-1)*tilePixelsX+(i-1)*3+2,
								(y-1)*tilePixelsY+4,
								(x-1)*tilePixelsX+(i-1)*3+2,
								(y-1)*tilePixelsY+tilePixelsY-3
					)
				else
					love.graphics.line(
								(x-1)*tilePixelsX+tilePixelsX-(i-1)*3+2,
								(y-1)*tilePixelsY+4,
								(x-1)*tilePixelsX+tilePixelsX-(i-1)*3+2,
								(y-1)*tilePixelsY+tilePixelsY-3
					)
				end
			end
			love.graphics.setColor(155,155,155,255)
			love.graphics.setFont(heavy_font)
			love.graphics.print(tilemap[x][y],(x-1)*tilePixelsX+tilePixelsX/2*0.7,(y-1)*tilePixelsY+1)
		end
	end
end

function draw_stairs()
	local x, y = 1
	for x=1,resolutionTilesX,1 do
		for y=1,resolutionTilesY,1 do
			if tilemap[x][y] == '>' or tilemap[x][y] == '<' then
				love.graphics.setColor(0,0,0,255)
				love.graphics.rectangle('fill',(x-1)*tilePixelsX,(y-1)*tilePixelsY+2,tilePixelsX-3,tilePixelsY-3)
				love.graphics.setColor(255,255,255,255)
				local total_lines = math.floor(tilePixelsX*0.7/2.5)
				local colorstep = 130/total_lines
				for i=1,total_lines,1 do
					love.graphics.setColor(255-(i*colorstep),255-(i*colorstep),255-(i*colorstep),255-(i*colorstep))
					if true or tilemap[x][y] == '>' then
						love.graphics.line(
									(x-1)*tilePixelsX+(i-1)*3+2,
									(y-1)*tilePixelsY+4,
									(x-1)*tilePixelsX+(i-1)*3+2,
									(y-1)*tilePixelsY+tilePixelsY-3
						)
					else
						love.graphics.line(
									(x-1)*tilePixelsX+tilePixelsX-(i-1)*3+2,
									(y-1)*tilePixelsY+4,
									(x-1)*tilePixelsX+tilePixelsX-(i-1)*3+2,
									(y-1)*tilePixelsY+tilePixelsY-3
						)
					end
				end
				love.graphics.setColor(155,155,155,255)
				love.graphics.setFont(heavy_font)
				love.graphics.print(tilemap[x][y],(x-1)*tilePixelsX+tilePixelsX/2*0.7,(y-1)*tilePixelsY+1)
			end
		end
	end
end

function draw_doors()
	-- draw doors (on top of the map tilemap)
	local x, y = 1
	for x=1,resolutionTilesX,1 do
		for y=1,resolutionTilesY,1 do
			-- if horizontal door
			if (x>1 and tilemap[x-1][y] == 0) or (x<resolutionTilesX and tilemap[x+1][y] == 0) then
				-- 2 = closed door
				if tilemap[x][y] == 2 then
					love.graphics.setColor(doorColor)
					love.graphics.rectangle("fill", (x-1)*tilePixelsX,(y-1)*tilePixelsY+(math.floor(tilePixelsY/2)),tilePixelsX,3)
				-- 3 = open door
				elseif tilemap[x][y] == 3 then
					love.graphics.setColor(doorColor)
					love.graphics.rectangle("fill", (x-1)*tilePixelsX,(y-1)*tilePixelsY+(math.floor(tilePixelsY/2)),3,tilePixelsY)
				end
			-- vertical door
			else
				-- 2 = closed door
				if tilemap[x][y] == 2 then
					love.graphics.setColor(doorColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+(math.floor(tilePixelsX/2)),(y-1)*tilePixelsX,3,tilePixelsY)
				-- 3 = open door
				elseif tilemap[x][y] == 3 then
					love.graphics.setColor(doorColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+(math.floor(tilePixelsX/2)),(y-1)*tilePixelsX,tilePixelsX,3)
				end
			end
		end
	end
end

function draw_poorvisibility_overlay()
	-- draw shadedness over poorly visible tiles
        for i=1,#visibleTiles,1 do
                local tile = visibleTiles[i]
                x=tile.x
                y=tile.y
		v=tile.v
		local alpha
		if v ~= 1 then
			alpha = 50*v
			love.graphics.setColor(0,0,0,alpha)
			--print("@" .. x .. "/" .. y .. ", visibility = " .. v)
			love.graphics.rectangle("fill", (x-1)*tilePixelsX,(y-1)*tilePixelsY,tilePixelsX,tilePixelsY)
			love.graphics.setColor(0,0,0,100)
			love.graphics.rectangle("fill", (x-1)*tilePixelsX,(y-1)*tilePixelsY,tilePixelsX,tilePixelsY)
		end
	end
end

function draw_doors_visibilitylimited()
	-- draw doors (on top of the map tilemap)
        for i=1,#visibleTiles,1 do
                local tile = visibleTiles[i]
                x=tile.x
                y=tile.y
		-- if horizontal door
		if (x>1 and tilemap[x-1][y] == 0) or (x<resolutionTilesX and tilemap[x+1][y] == 0) then
			-- 2 = closed door
			if tilemap[x][y] == 2 then
				love.graphics.setColor(doorColor)
				love.graphics.rectangle("fill", (x-1)*tilePixelsX,(y-1)*tilePixelsY+(math.floor(tilePixelsY/2)),tilePixelsX,3)
			-- 3 = open door
			elseif tilemap[x][y] == 3 then
				love.graphics.setColor(doorColor)
				love.graphics.rectangle("fill", (x-1)*tilePixelsX,(y-1)*tilePixelsY+(math.floor(tilePixelsY/2)),3,tilePixelsY)
			end
		-- vertical door
		else
			-- 2 = closed door
			if tilemap[x][y] == 2 then
				love.graphics.setColor(doorColor)
				love.graphics.rectangle("fill",(x-1)*tilePixelsX+(math.floor(tilePixelsX/2)),(y-1)*tilePixelsX,3,tilePixelsY)
			-- 3 = open door
			elseif tilemap[x][y] == 3 then
				love.graphics.setColor(doorColor)
				love.graphics.rectangle("fill",(x-1)*tilePixelsX+(math.floor(tilePixelsX/2)),(y-1)*tilePixelsX,tilePixelsX,3)
			end
		end
	end
end

function draw_tilemap_beautification()
	if beautify then
		for x=1,resolutionTilesX,1 do
			for y=1,resolutionTilesY,1 do
				if tilemap[x][y] == 'o' then
					love.graphics.setColor(rockColor)
					love.graphics.circle("fill",(x-1)*tilePixelsX+(0.5*tilePixelsX),(y-1)*tilePixelsY+(0.5*tilePixelsX),math.floor(tilePixelsX/2)-1,10)
				elseif tilemap[x][y] == '^' then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX,(y-1)*tilePixelsY,2,2)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+tilePixelsX-2,(y-1)*tilePixelsY,2,2)
				elseif tilemap[x][y] == 4 then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX,(y-1)*tilePixelsY+tilePixelsY-2,2,2)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+tilePixelsX-2,(y-1)*tilePixelsY+tilePixelsY-2,2,2)
				elseif tilemap[x][y] == 5 then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX,(y-1)*tilePixelsY,2,2)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX,(y-1)*tilePixelsY+tilePixelsY-2,2,2)
				elseif tilemap[x][y] == 6 then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+tilePixelsX-2,(y-1)*tilePixelsY,2,2)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+tilePixelsX-2,(y-1)*tilePixelsY+tilePixelsY-2,2,2)
				elseif tilemap[x][y] == 7 then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+tilePixelsX-2,(y-1)*tilePixelsY+tilePixelsY-2,2,2)
				elseif tilemap[x][y] == 8 then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX,(y-1)*tilePixelsY+tilePixelsY-2,2,2)
				elseif tilemap[x][y] == 9 then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX,(y-1)*tilePixelsY,2,2)
				elseif tilemap[x][y] == 'R' then
					love.graphics.setColor(groundColor)
					love.graphics.rectangle("fill",(x-1)*tilePixelsX+tilePixelsX-2,(y-1)*tilePixelsY,2,2)
				end
			end
		end
	end
end

function draw_character()
	-- draw character
	love.graphics.setColor(characterColor)
	love.graphics.rectangle('fill',(characterX-1)*tilePixelsX+characterSmallness,(characterY-1)*tilePixelsY+characterSmallness,tilePixelsX-characterSmallness*2,tilePixelsY-characterSmallness*2)
end

function draw_npcs()
	-- draw npcs
	for i=1,#npcs,1 do
		local l=npcs[i]['location']
		if npcs[i]['color'] ~= nil then
			love.graphics.setColor(npcs[i]['color'])
		else
			love.graphics.setColor(defaultNpcColor)
		end
		love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+characterSmallness,(l['y']-1)*tilePixelsY+characterSmallness,tilePixelsX-characterSmallness*2,tilePixelsY-characterSmallness*2)
		if npcs[i]['tail'] ~= nil then
			love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+characterSmallness,(l['y']-1)*tilePixelsY+tilePixelsY-characterSmallness-2,-2,2)
			love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+characterSmallness-2,(l['y']-1)*tilePixelsY+tilePixelsY-characterSmallness-4,1,2)
			love.graphics.setColor(0,0,0,255)
			love.graphics.points({
				(l['x']-1)*tilePixelsX+characterSmallness+2,
				(l['y']-1)*tilePixelsY+characterSmallness+2,
				(l['x']-1)*tilePixelsX+tilePixelsX-characterSmallness-3,
				(l['y']-1)*tilePixelsY+characterSmallness+2,
					    })
		end
	        love.graphics.setColor(npcLabelShadowColor)
		-- NB. The following line is useful for debugging UTF-8 issues which Lua has in buckets
		--print("name: " .. npcs[i]['name'] .. " (" .. npcs[i]['type'] .. ")")
		love.graphics.setFont(light_font)
                love.graphics.print(npcs[i]['name'],(l['x']-1)*tilePixelsX+math.floor(tilePixelsX/2)+7, (l['y']-1)*tilePixelsY+2)
		if npcs[i]['color'] ~= nil then
			love.graphics.setColor(npcs[i]['color'])
		else
			love.graphics.setColor(defaultNpcLabelColor)
		end
		love.graphics.setFont(light_font)
                love.graphics.print(npcs[i]['name'],(l['x']-1)*tilePixelsX+math.floor(tilePixelsX/2)+6, (l['y']-1)*tilePixelsY+1)
	end
end

function draw_npcs_visibilitylimited()
	-- draw npcs
	for i=1,#npcs,1 do
		local l=npcs[i]['location']
		-- check if it's in the list of visible tiles

		-- cheat and display a dot on each unseen NPC
		--love.graphics.setColor(255,255,255,255)
		--love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+(characterSmallness+3),(l['y']-1)*tilePixelsY+(characterSmallness+3),tilePixelsX-(characterSmallness+3)*2,tilePixelsY-(characterSmallness+3)*2)
		local found=false
		for j=1,#visibleTiles,1 do
                	local tile = visibleTiles[j]
                	if tile.x == l['x'] and tile.y == l['y'] then
				found = true
			end
		end
		if found==true then
			if npcs[i]['color'] ~= nil then
				love.graphics.setColor(npcs[i]['color'])
			else
				love.graphics.setColor(defaultNpcColor)
			end
			love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+characterSmallness,(l['y']-1)*tilePixelsY+characterSmallness,tilePixelsX-characterSmallness*2,tilePixelsY-characterSmallness*2)
			if npcs[i]['tail'] ~= nil then
				love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+characterSmallness,(l['y']-1)*tilePixelsY+tilePixelsY-characterSmallness-2,-2,2)
				love.graphics.rectangle('fill',(l['x']-1)*tilePixelsX+characterSmallness-2,(l['y']-1)*tilePixelsY+tilePixelsY-characterSmallness-4,1,2)
				love.graphics.setColor(0,0,0,255)
				love.graphics.points({
					(l['x']-1)*tilePixelsX+characterSmallness+2,
					(l['y']-1)*tilePixelsY+characterSmallness+2,
					(l['x']-1)*tilePixelsX+tilePixelsX-characterSmallness-3,
					(l['y']-1)*tilePixelsY+characterSmallness+2,
						    })
			end
		        love.graphics.setColor(npcLabelShadowColor)
			-- NB. The following line is useful for debugging UTF-8 issues which Lua has in buckets
			--print("name: " .. npcs[i]['name'] .. " (" .. npcs[i]['type'] .. ")")
			love.graphics.setFont(light_font)
       		         love.graphics.print(npcs[i]['name'],(l['x']-1)*tilePixelsX+math.floor(tilePixelsX/2)+7, (l['y']-1)*tilePixelsY+2)
			if npcs[i]['color'] ~= nil then
				love.graphics.setColor(npcs[i]['color'])
			else
				love.graphics.setColor(defaultNpcLabelColor)
			end
			love.graphics.setFont(light_font)
        	        love.graphics.print(npcs[i]['name'],(l['x']-1)*tilePixelsX+math.floor(tilePixelsX/2)+6, (l['y']-1)*tilePixelsY+1)
		end
	end
end

function draw_logmessages()
	-- draw log messages
	local a = 0
	if #logMessages > 0 then
		for i,message in ipairs(logMessages) do
			local difference = os.clock() - message['time']
			a = 355 - (255*string.format("%.2f",difference))
			if a > 0 then
				local myColor = r,g,b,a
				love.graphics.setColor(a,a,a,a)
				love.graphics.setFont(light_font)
				love.graphics.print(message['message'],20,15*i)
			else
				message['delete'] = true
			end
		end
		for i,message in ipairs(logMessages) do
			if message['delete'] == true then
				table.remove(logMessages,i)
			end
		end
	end
end

function draw_popups()
	-- draw popups
	local border=100
	local pad=10
	-- help
	if love.keyboard.isDown('h') then
		-- shade others
		love.graphics.setColor(popupShadeColor)
		love.graphics.rectangle('fill',0,0,resolutionPixelsX,resolutionPixelsY)
		-- draw popup
		love.graphics.setColor(popupBorderColor)
		love.graphics.rectangle('fill',border,border,resolutionPixelsX-(border*2),resolutionPixelsY-(border*2))
		-- draw popup content box
		love.graphics.setColor(popupBackgroundColor)
		love.graphics.rectangle('fill',border+pad,border+pad,resolutionPixelsX-(border*2)-(pad*2),resolutionPixelsY-(border*2)-(pad*2))
		-- draw title
		love.graphics.setColor(popupTitleColor)
		love.graphics.setFont(heavy_font)
		love.graphics.printf("Help",0,border*1.3,resolutionPixelsX,"center")
		keys = {
			c='Close doors',
			e='Equipment',
			h='Help',
			i='Inventory',
			o='Open doors',
			arrows='Movement',
			escape='Quit',
			['<']='Up stairs / ladder',
			['>']='Down stairs / ladder'
		       }
		local i=0
		for key,description in pairs(keys) do
			output = {}
			table.insert(output, popupBrightTextColor)
			table.insert(output, key)
			local width=80
			love.graphics.setFont(light_font)
			love.graphics.printf(output, border+pad, border*1.3+pad+pad+i*20-1, pad+resolutionPixelsX/2*0.1-pad, "right")
			output = {}
			table.insert(output, popupNormalTextColor)
			table.insert(output, description)
			love.graphics.setFont(light_font)
			love.graphics.print(output,	math.floor(border+pad+resolutionPixelsX/2*0.1+pad*3),	border*1.3+pad+pad+i*20)
			i=i+1
		end
	-- equipment
	elseif love.keyboard.isDown('e') then
		-- shade others
		love.graphics.setColor(popupShadeColor)
		love.graphics.rectangle('fill',0,0,resolutionPixelsX,resolutionPixelsY)
		-- draw popup
		love.graphics.setColor(popupBorderColor)
		love.graphics.rectangle('fill',border,border,resolutionPixelsX-(border*2),resolutionPixelsY-(border*2))
		-- draw popup content box
		love.graphics.setColor(popupBackgroundColor)
		love.graphics.rectangle('fill',border+pad,border+pad,resolutionPixelsX-(border*2)-(pad*2),resolutionPixelsY-(border*2)-(pad*2))
		-- draw title
		love.graphics.setColor(popupTitleColor)
		love.graphics.setFont(heavy_font)
		love.graphics.printf("Equipment",0,border*1.3,resolutionPixelsX,"center")
	-- inventory
	elseif love.keyboard.isDown('i') then
		-- shade others
		love.graphics.setColor(popupShadeColor)
		love.graphics.rectangle('fill',0,0,resolutionPixelsX,resolutionPixelsY)
		-- draw popup
		love.graphics.setColor(popupBorderColor)
		love.graphics.rectangle('fill',border,border,resolutionPixelsX-(border*2),resolutionPixelsY-(border*2))
		-- draw popup content box
		love.graphics.setColor(popupBackgroundColor)
		love.graphics.rectangle('fill',border+pad,border+pad,resolutionPixelsX-(border*2)-(pad*2),resolutionPixelsY-(border*2)-(pad*2))
		-- draw title
		love.graphics.setColor(popupTitleColor)
		love.graphics.setFont(heavy_font)
		love.graphics.printf("Inventory",0,border*1.3,resolutionPixelsX,"center")
		-- draw inventory contents
		local i=0
		for index,item in pairs(inventory) do
			love.graphics.setColor(popupBrightTextColor)
			love.graphics.setFont(light_font)
			love.graphics.printf(item.qty, border+pad, border*1.3+pad+pad+i*20-1, pad+resolutionPixelsX/2*0.1-pad, "right")
			love.graphics.setColor(popupDarkTextColor)
			love.graphics.setFont(light_font)
			love.graphics.print('x',	math.floor(border+pad+resolutionPixelsX/2*0.1+pad),    	border*1.3+pad+pad+i*20)
			love.graphics.setColor(255,255,255,255)
			local item_description = { popupBrightTextColor, index }
			-- extend this if appropriate
			if item['name'] ~= nil then
					table.insert(item_description,popupNormalTextColor)
					table.insert(item_description,' "')
					table.insert(item_description,popupBlingTextColor)
					table.insert(item_description, item['name'])
					table.insert(item_description,popupNormalTextColor)
					table.insert(item_description,'" ')
			end
			if item['attack'] ~= nil then
				if item['attack']['qty'] ~= nil and
				   item['attack']['faces'] ~= nil then
					table.insert(item_description, popupDarkTextColor)
					table.insert(item_description, ' <')
					table.insert(item_description, popupBrightTextColor)
					table.insert(item_description, item['attack']['qty'] .. 'd' .. item['attack']['faces'])
					if item['attack']['bonus'] ~= nil then
						table.insert(item_description, popupNormalTextColor)
						table.insert(item_description, '+')
						table.insert(item_description, popupBrightTextColor)
						table.insert(item_description, item['attack']['bonus'])
					end
					table.insert(item_description, popupDarkTextColor)
					table.insert(item_description, '>')
				end
			end
			love.graphics.setFont(light_font)
			love.graphics.print(item_description,	math.floor(border+pad+resolutionPixelsX/2*0.1+pad*3),	border*1.3+pad+pad+i*20)
			i = i + 1
		end
		if i==0 then
			love.graphics.setFont(medium_font)
			love.graphics.printf("You have no items.",0,math.floor(resolutionPixelsY/2)-10,resolutionPixelsX,"center")
		end
	end
end

-- tiletype 0 = floor, 1 = wall
function tile_callback(tilex,tiley,tiletype)
	if tiletype == 0 then
		tiletype = 1
	elseif tiletype == 1 then
		tiletype = 0
	end
	tilemap[tilex][tiley] = tiletype
end

-- move the character relatively to a new location, but only if the desination is walkable
function moveCharacterRelatively(x,y)
	newX = characterX + x
	newY = characterY + y
	-- if the map space is potentially standable (1 = floor, 3 = open door, '<' = down stairs, '>' = up stairs)
	if tilemap[newX][newY] == 1 or tilemap[newX][newY] == 2 or tilemap[newX][newY] == 3 or tilemap[newX][newY] == '<' or tilemap[newX][newY] == '>' then
		local blocked=false
		-- if it's a closed door, open it
		if tilemap[newX][newY] == 2 then
			opendoor(newX,newY)
		else
			-- if there is no NPC there
			for i=1,#npcs,1 do
				-- for some reason this is required occasionally... seems an off by one end-of-table bug
				if npcs[i] ~= nil then
					-- actual check
					if npcs[i]['location']['x'] == newX and
					   npcs[i]['location']['y'] == newY then
						-- there is an npc there
						if npcs[i]['hostile'] == true then
							-- hostile npc: fight
							attack_npc(i)
						else
							-- non-hostile npc: whinge
							npcs[i]['sounds']['attack']:play()
							logMessage(failMessageColor,npcs[i]['name'] .. ' is in the way.')
						end
						blocked=true
					end
				end
			end
		end
		if blocked == false then
			-- if the new location is not beyond the map
			if newX > 0 and newY > 0 and newX <= resolutionTilesX and newY <= resolutionTilesY then
				-- ACTUALLY MOVE!
				footfallNoise()
				table.insert(footprints,{x=characterX,y=characterY,r=math.random(-90,90)})
				if #footprints > max_footprints then
					table.remove(footprints,1)
				end
				characterX = newX
				characterY = newY
				autoPickup()
				endTurn()
			end
		end
	else
		if tilemap[newX][newY] == 0 then
--			logMessage(failMessageColor,"You can't move that way (there is a wall in the way).")
--		else
--			logMessage(failMessageColor,"You can't move that way (there is something in the way).")
		end
	end
end

-- make the tiles more beautiful
function beautifyTiles()
	for x=2,resolutionTilesX-1,1 do
		for y=2,resolutionTilesY-1,1 do
			-- if the tile is 0 (ie. floor) AND ... 
			if tilemap[x][y] == 0 then
				-- .... is fully surrounded by floor (1), then mark it as 2
				if tilemap[x-1][y] == 1 and
				   tilemap[x+1][y] == 1 and
				   tilemap[x][y-1] == 1 and
				   tilemap[x][y+1] == 1 then
					tilemap[x][y] = 'o'
				-- .... is fully surrounded by floor (1), except on the bottom, then mark it as 3
				elseif tilemap[x-1][y] == 1 and
				       tilemap[x+1][y] == 1 and
				       tilemap[x][y-1] == 1 then
						tilemap[x][y] = '^'
				-- .... is fully surrounded by floor (1), except on the top, then mark it as 4
				elseif tilemap[x-1][y] == 1 and
				       tilemap[x+1][y] == 1 and
				       tilemap[x][y+1] == 1 then
						tilemap[x][y] = 4
				-- .... is fully surrounded by floor (1), except on the right, then mark it as 5
				elseif tilemap[x-1][y] == 1 and
				       tilemap[x][y-1] == 1 and
				       tilemap[x][y+1] == 1 then
						tilemap[x][y] = 5
				-- .... is fully surrounded by floor (1), except on the left, then mark it as 6
				elseif tilemap[x+1][y] == 1 and
				       tilemap[x][y-1] == 1 and
				       tilemap[x][y+1] == 1 then
						tilemap[x][y] = 6
				-- .... is surrounded by floor (1) only on the right and bottom, then mark it as 7
				elseif tilemap[x+1][y] == 1 and
				       tilemap[x][y+1] == 1 then
						tilemap[x][y] = 7
				-- .... is surrounded by floor (1) only on the left and bottom, then mark it as 8
				elseif tilemap[x-1][y] == 1 and
				       tilemap[x][y+1] == 1 then
						tilemap[x][y] = 8
				-- .... is surrounded by floor (1) only on the left and top, then mark it as 9
				elseif tilemap[x-1][y] == 1 and
				       tilemap[x][y-1] == 1 then
						tilemap[x][y] = 9
				-- .... is surrounded by floor (1) only on the right and top, then mark it as R
				elseif tilemap[x+1][y] == 1 and
				       tilemap[x][y-1] == 1 then
						tilemap[x][y] = 'R'
				end
			end
		end
	end
end

function randomStandingLocationWithoutNPCsOrPlayer()
	local failed = 1
	local x,y = 0
	while not(failed == 0) do
		failed = 1
		x,y = randomStandingLocation()
		if x == characterX and y == characterY then
			failed = true
		else
			-- search all NPCs for same coordinates
			for i,npc in ipairs(npcs) do
				local l = npc['location']
				if l ~= nil then
					if l['x'] == x and l['y'] == y then
						failed = failed + 1
						break
					end
				end
			end
			failed = failed - 1
		end
	end
	return x, y
end

function randomStandingLocation()
	local found_x,found_y = 0
	local placed=false
	while placed == false do
		x = math.random(1,resolutionTilesX)
		y = math.random(1,resolutionTilesY)
		if tilemap[x][y] == 1 or tilemap[x][y] == '1' then
			found_x = x
			found_y = y
			placed = true
		end
		--print("randomStandingLocation failed @ " .. x .. "/" .. y .. " (wanted 1 found '" .. tilemap[x][y] .. "')")
	end
	return x,y
end

function logMessage(color,string)
	table.insert(logMessages,{time=os.clock(),message={color,string}})
end

function footfallNoise()
	local id = math.floor(math.random(1,#sounds['footfalls']))
	local instance = sounds['footfalls'][id]:play()
	instance:setVolume(1.5)
        instance:setPitch(.5 + math.random() * .5)          -- set pitch for this instance only
end

function autoPickup()
	for i,gf in ipairs(groundfeatures) do
		if gf.x == characterX and gf.y == characterY then
			-- auto pickup
			if gf.type == 'shrub' then
				logMessage(vegetableMessageColor,'You collect vegetable matter from a shrub.')
				table.remove(groundfeatures,i)
				inventory_add('vegetable matter')
			elseif gf.type == 'stone' then
				logMessage(notifyMessageColor,'You collect a small pebble.')
				table.remove(groundfeatures,i)
				inventory_add('pebble')
			elseif gf.type == 'puddle' then
				logMessage(waterMessageColor,'You tread in a puddle.')
				sounds['footfall_water']:play()
			end
		end
	end
end

function opendoors()
	for x=-1,1,1 do
		if tilemap[characterX+x][characterY-1] == 2 then
			opendoor(characterX+x,characterY-1)
		end
		if tilemap[characterX+x][characterY+1] == 2 then
			opendoor(characterX+x,characterY+1)
		end
	end
	if tilemap[characterX-1][characterY] == 2 then
		opendoor(characterX-1,characterY)
	end
	if tilemap[characterX+1][characterY] == 2 then
		opendoor(characterX+1,characterY)
	end
end

function closedoors()
	for x=-1,1,1 do
		if tilemap[characterX+x][characterY-1] == 3 then
			closedoor(characterX+x,characterY-1)
		end
		if tilemap[characterX+x][characterY+1] == 3 then
			closedoor(characterX+x,characterY+1)
		end
	end
	if tilemap[characterX-1][characterY] == 3 then
		closedoor(characterX-1,characterY)
	end
	if tilemap[characterX+1][characterY] == 3 then
		closedoor(characterX+1,characterY)
	end
end

function opendoor(x,y)
	if tilemap[x][y] == 2 then
		local instance=sounds['door_open']:play()
		instance:setVolume(1)
		logMessage(notifyMessageColor,"You opened the door.")
		tilemap[x][y] = 3
	end
end

function closedoor(x,y)
	if tilemap[x][y] == 3 then
		local instance = sounds['door_close']:play()
		instance:setVolume(1)
		logMessage(notifyMessageColor,"You closed the door.")
		tilemap[x][y] = 2
	end
end

function inventory_add(thing)
	local instance = sounds['pickup']:play()
	instance:setVolume(1)
	if inventory[thing] == nil then
		inventory[thing] = {qty=0}
	end
	inventory[thing]['qty'] = inventory[thing]['qty'] + 1
end

function endTurn()
	-- allow NPCs to move
	for i,npc in ipairs(npcs) do
		-- each one has a 10% chance of moving
		local movementchance = math.floor(math.random(0,10))
		if movementchance == 9 then
			-- attempt to move: pick a direction, then try all directions clockwise until success
			local direction = math.ceil(math.random(0,9))
			local success=false
			local attempts=0
			local l=npc.location
			while success==false and attempts<8 do
				-- sw
				if direction == 1 then
					tryx = l.x-1
					tryy = l.y+1
				-- s
				elseif direction == 2 then
					tryx = l.x
					tryy = l.y+1
				-- se
				elseif direction == 3 then
					tryx = l.x+1
					tryy = l.y+1
				-- w
				elseif direction == 4 then
					tryx = l.x-1
					tryy = l.y
				-- e
				elseif direction == 6 then
					tryx = l.x+1
					tryy = l.y
				-- nw
				elseif direction == 7 then
					tryx = l.x-1
					tryy = l.y-1
				-- n
				elseif direction == 8 then
					tryx = l.x
					tryy = l.y-1
				-- ne
				elseif direction == 7 then
					tryx = l.x+1
					tryy = l.y-1
				end
				-- moment of truth
				success=true			
				attempts = attempts + 1
			end
		end
	end
end

function descend()
	if tilemap[characterX][characterY] == ">" then
		logMessage(notifyMessageColor,'Descending...')
		music:stop()
		music:play()
	else
		logMessage(failMessageColor,'There is no way down here!')
	end
end

function ascend()
	if tilemap[characterX][characterY] == "<" then
		logMessage(notifyMessageColor,'Ascending...')
		music:stop()
		music:play()
	else
		logMessage(failMessageColor,'There is no way up here!')
	end
end

function attack_npc(i)
	npcs[i]['sounds']['attack']:setVolume(3)
	npcs[i]['sounds']['attack']:play()
	logMessage(notifyMessageColor,'You smash it!')
	--table.remove(npcs,i)
end

-- calculate the set of visible tilemap squares
function update_draw_visibility()
	visibleTiles={}
	-- our algorithm is as follows:
	--  starting at the player's own location, spiral outward in a clockwise direction.
	--   - if a given tile blocks vision, mark its adjacent blocks as not visible (stop searching)
	local directions = {}
	-- note that 'next' can be determined by a modulo calculation instead... slower though
	directions[1] = {offset={-1,-1}, next={8,1,2}}
	directions[2] = {offset={0,-1},  next={1,2,3}}
	directions[3] = {offset={1,-1},  next={2,3,4}}
	directions[4] = {offset={1,0},   next={3,4,5}}
	directions[5] = {offset={1,1},   next={4,5,6}}
	directions[6] = {offset={0,1},   next={5,6,7}}
	directions[7] = {offset={-1,1},  next={6,7,8}}
	directions[8] = {offset={-1,0},  next={7,8,1}}
	-- we begin at the character's current location, and spiral out from there
	local x = characterX
	local y = characterY
	local direction = {1,2,3,4,5,6,7,8}
	-- we store branches for future lookup here
	local options={}
	local options_calculated={}
	-- we continue exploring until we have exhausted all options
	local done=false
	local last=''
	print("==============================================")
	while done==false do
		-- if we are on ground or an open door
		print(x .. "/" .. y .. ': ' .. table.concat(direction,','))
		if tilemap[x][y] == 1 or tilemap[x][y] == 3 then
			-- this tile is visible
			table.insert(visibleTiles,{['x']=x,['y']=y,['last']=#direction})
			-- use direction to inform subsequent options
			for crap,dir in pairs(direction) do
				local cx = 0
				local cy = 0
				-- calculate the next tile location
				cx,cy = update_draw_visibility_helper(x,y,directions[dir]['offset'])
				-- hang the next directions and last direction on that tile location option
				local newoption = {}
				local c = {cx, cy}
				if #direction == 3 then
					newoption = {coordinates=c,next={dir},last=direction}
				else
					newoption = {coordinates=c,next=directions[dir]['next'],last=direction}
				end
				-- insert only if the tile hasnt already been staged
				existing_index = 0
				max = #options
				for i=1, max, 1 do
					if options[i]['coordinates'][1] == cx and options[i]['coordinates'][2] == cy then
						existing_index = i+0
					end
				end
				if existing_index == 0 then
					table.insert(options,newoption)
					for i=1,#direction,1 do
						-- record each cell + direction (x/y/direction) combination as pre-scheduled
						local option_key = cx .. ',' .. cy .. ',' .. direction[i]
						options_calculated[option_key] = true
					end
				else
					for i,d in pairs(newoption.next) do
						local option_key = cx .. ',' .. cy .. ',' .. d
						if options_calculated[option_key] ~= nil then
							-- check the existing entry for the direction
							local found_it = false
							for _,v in pairs(options[existing_index]['next']) do
							  --print("v = " .. v)
							  if v == d then
							    found_it = true
							    break
							  end
							end
							-- if it wasn't found, insert it
							if found_it == false then
								print("added direction '" .. d .. "' to existing index @ " .. cx .. "/" .. cy)
								table.insert(options[existing_index]['next'],d)
							end
						end
					end
				end
			end
			-- debug summary
			--[[
			local output = "@" .. x .. "/" .. y .. " directions("
			for crap,dir in pairs(direction) do
				output = output .. dir .. " "
			end
			output = output .. ")"
			print(output)
			--]]
		end
		-- now we pick one of the existing options in the list, and allow the loop to repeat.
		-- if there are no options in the list, we are done
		if #options ~= 0 then
			if options[1] ~= nil and options[1]['coordinates'] ~= nil then
				local tmpc=options[1]['coordinates']
				x = tmpc[1]
				y = tmpc[2]
				--[[
				if x ~= nil then
					print(" x = " .. x)
				end
				if y ~= nil then
					print(" y = " .. y)
				end
				--]]
				direction = options[1]['next']
				last = options[1]['last']
			end
			table.remove(options,1)
		end
		if #options == 0 then
			done=true
			--[[
		else
			-- show options
			print("=====end run============")
			print(table.show(options))
			print("========================")
			--]]
		end
	end
end

-- compute relative coordinate
function update_draw_visibility_helper(x,y,offset)
	local offset_x = offset[1]
	local offset_y = offset[2]
	local newx = 0
	local newy = 0
	local newx = x + offset_x
	local newy = y + offset_y
	return newx,newy
end

function draw_visibility_overlay()
	local coordinate
	local x = 0
	local y = 0
	for i=1,#visibleTiles,1 do
		local tile = visibleTiles[i]
		x=tile.x
		y=tile.y
		love.graphics.setColor(255,255,0,30)
		love.graphics.rectangle("line",(x-1)*tilePixelsX,(y-1)*tilePixelsY,tilePixelsX,tilePixelsY)
		love.graphics.setFont(heavy_font)
		love.graphics.print(tile.last,(x-1)*tilePixelsX+tilePixelsX/2*0.7,(y-1)*tilePixelsY+1)
	end
end

function draw_coordinates_overlay()
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(heavy_font)
		love.graphics.print(characterX .. '/' .. characterY,(resolutionTilesX-10)*tilePixelsX,tilePixelsY)
end

function draw_tilemap_visibilitylimited()
	-- draw tilemap
	for i=1,#seenTiles,1 do
		local tile = seenTiles[i]
		x=tile.x
		y=tile.y
		-- 1 = floor, 2 = closed door, 3 = open door, '<' = upward stairs, '>' = downward stairs
		if tilemap[x][y] == 1 or tilemap[x][y] == 2 or tilemap[x][y] == 3 or tilemap[x][y] == '<' or tilemap[x][y] == '>' then
			love.graphics.setColor(groundColor)
			love.graphics.rectangle("fill", (x-1)*tilePixelsX, (y-1)*tilePixelsX, tilePixelsX, tilePixelsY)
			love.graphics.setColor(0,0,0,100)
			love.graphics.rectangle("fill", (x-1)*tilePixelsX, (y-1)*tilePixelsX, tilePixelsX, tilePixelsY)
		end
	end
	for i=1,#visibleTiles,1 do
		local tile = visibleTiles[i]
		x=tile.x
		y=tile.y
		-- 1 = floor, 2 = closed door, 3 = open door, '<' = upward stairs, '>' = downward stairs
		if tilemap[x][y] == 1 or tilemap[x][y] == 2 or tilemap[x][y] == 3 or tilemap[x][y] == '<' or tilemap[x][y] == '>' then
			love.graphics.setColor(groundColor)
			love.graphics.rectangle("fill", (x-1)*tilePixelsX, (y-1)*tilePixelsX, tilePixelsX, tilePixelsY)
		end
	end
end

function draw_simpleareashade()
	-- top
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle('fill',0,0,resolutionPixelsX,(characterY-10)*tilePixelsY)
	love.graphics.setColor(0,0,0,135)
	love.graphics.rectangle('fill',0,0,resolutionPixelsX,(characterY-9)*tilePixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',0,0,resolutionPixelsX,(characterY-8)*tilePixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',0,0,resolutionPixelsX,(characterY-7)*tilePixelsY)

	-- left
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle('fill',0,0,(characterX-10)*tilePixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,135)
	love.graphics.rectangle('fill',0,0,(characterX-9)*tilePixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',0,0,(characterX-8)*tilePixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',0,0,(characterX-7)*tilePixelsX,resolutionPixelsY)

	-- right
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle('fill',(characterX+10)*tilePixelsX,0,resolutionPixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,135)
	love.graphics.rectangle('fill',(characterX+9)*tilePixelsX,0,resolutionPixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',(characterX+8)*tilePixelsX,0,resolutionPixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',(characterX+7)*tilePixelsX,0,resolutionPixelsX,resolutionPixelsY)

	-- bottom
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle('fill',0,(characterY+10)*tilePixelsY,resolutionPixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,135)
	love.graphics.rectangle('fill',0,(characterY+9)*tilePixelsY,resolutionPixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',0,(characterY+8)*tilePixelsY,resolutionPixelsX,resolutionPixelsY)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle('fill',0,(characterY+7)*tilePixelsY,resolutionPixelsX,resolutionPixelsY)

end

-- working FOV
function update_draw_visibility_new()
	visibleTiles={}
	-- mark all seen tiles as not currently seen
	for i,v in ipairs(seenTiles) do
		seenTiles['i'] = 0
	end
	fov=ROT.FOV.Precise:new(lightPassesCallback,{topology=8})
	results = fov:compute(characterX,characterY,15,isVisibleCallback)
end

-- for FOV calculation
function lightPassesCallback(coords,qx,qy)
	-- required as otherwise moving near the edge crashes
	if tilemap[qx] ~= nil and tilemap[qx][qy] ~= nil then
		-- actual check
		if tilemap[qx][qy] == 1 or tilemap[qx][qy] == 3 or tilemap[qx][qy] == '<' or tilemap[qx][qy] == '>' then
			return true
		end
	end
	return false
end

-- for FOV calculation
function isVisibleCallback(x,y,r,v)
	-- first mark as visible
	table.insert(visibleTiles,{x=x,y=y,r=r,last=r,v=v})
	-- also mark in seen tiles as currently seen
	table.insert(seenTiles,{x=x,y=y})
end
