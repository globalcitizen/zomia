area_types['wilderness'] = {
       				 name  = 'Wilderness',
       				 setup = function(instance)
       					-- Generate an appropriate name
       					instance.name=wildernessNames:generate()
					instance.prefix='The Wilds of '

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
					add_npcs(instance.npcs,'tai_villager_male',1)
					add_npcs(instance.npcs,'dog',1)
					add_npcs(instance.npcs,'water_buffalo',1)

                                        -- music
					--[[
                                        instance.music = {
                                                                        "music/track.mp3"
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



-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
wildernessNames=ROT.StringGenerator:new()
filename = "areas/wilderness/wilderness-names.txt"
for line in love.filesystem.lines(filename) do
        if not (line==nil) then
                wildernessNames:observe(line)
        end
end
