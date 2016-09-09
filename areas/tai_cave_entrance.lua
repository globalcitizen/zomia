area_types['tai_cave_entrance'] = {
				 name  = 'Tai Cave Entrance',
				 setup = function(instance) 
					-- Generate an appropriate name
					instance.name = tai_cave_name_generate()
                                        instance.prefix='Cave Mouth of '

                                        -- FOV
                                        instance.fov=0

                                        -- Colours
                                        instance.colors={}
                                        instance.colors['groundColor'] = {40,130,40}

                                        -- Generate an appropriate map
                                        --  - First, all clear
                                        local new_tilemap = {}
                                        for i=1,resolutionTilesX,1 do
                                                new_tilemap[i] = {}
                                                for j=1,resolutionTilesY,1 do
                                                        new_tilemap[i][j] = 1
                                                end
                                        end

                                        -- Add the cave entrance itself
                                        -- set scale (building are this x this squared)
                                        buildingScale=3
                                        -- find a location
                                        bx,by = randomStandingLocation(new_tilemap,4)
                                        -- fill it in
					new_tilemap[bx][by] = '0'
					new_tilemap[bx+1][by] = '0'
					new_tilemap[bx+2][by] = '0'
					new_tilemap[bx][by+1] = '0'
					new_tilemap[bx+1][by+1] = '>'
					new_tilemap[bx+2][by+1] = '0'
					new_tilemap[bx][by+2] = '0'
					new_tilemap[bx+2][by+2] = '0'

                                        --  Trees
                                        for i=1,90,1 do
                                                -- set space required around tree
                                                treeSpace=1
                                                -- find a location
                                                ts = treeSpace*2 + 1
                                                bx,by = randomStandingLocation(new_tilemap,ts)
                                                new_tilemap[bx+treeSpace][by+treeSpace] = 'T'
                                        end

					instance.map=new_tilemap

                                        -- Populate with NPCs
                                        instance.npcs = {}
                                        add_npcs(instance.npcs,'tai_villager_male',1)		-- should add more personality, place near cave
                                        add_npcs(instance.npcs,'dog',1)

                                        -- music
					--[[
                                        instance.music = {
                                                                        "music/track.mp3",
                                                         }
                                        instance.music_volume=0.3
					--]]

                                        -- ambient noise
                                        --[[
                                        instance.ambient = {
                                                                                "sounds/ambient/cave-drips.mp3"
                                                           }
                                        instance.ambient_volume = 2
                                        --]]
				 end
		       	    }

function tai_cave_name_generate()
	prefixes = {
			'Metal',
			'Silver',
			'Tin',
			'Copper',
			'Gold',
			'Salt',
			'Ruby',
			'Emerald'
	}
	suffixes = {
			'Cavern',
			'Caverns',
			'Cutting',
			'Cuttings',
			'Passage',
			'Passages',
			'Cave',
			'Caves',
			'Shafts',
			'Grotto',
			'Grottoes',
			'Den',
			'Hollow',
			'Cavity',
			'Cavities'
	}
	prefix = prefixes[math.random(1,#prefixes)]
	suffix = suffixes[math.random(1,#suffixes)]
	return prefix .. ' ' .. suffix
end
