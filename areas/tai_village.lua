area_types['tai_village'] = {
				 name  = 'Tai Village',
				 setup = function(instance) 

					-- Generate an appropriate name
					instance.name=taiVillageNames:generate()
					instance.prefix='The Little Tai Village of '

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
					--  - Second, we place a river to the left or right
					river_location = math.random(1,2)
					river_edge_offset = math.random(2,3) * 0.1
					bridge_location = math.floor(math.random(math.floor(resolutionTilesY*0.2),math.floor(resolutionTilesY*0.8)))
					if river_location == 1 then
						river_center_x = river_edge_offset*resolutionTilesX
					else
						river_center_x = resolutionTilesX-(river_edge_offset*resolutionTilesX)
					end
					for y=1,resolutionTilesY,1 do
						tiletype='W'
						if y==bridge_location then 
							tiletype='='
						end
						-- had a crash here, leave for debugging
						print("river_center_x = " .. river_center_x .. " ... y = " .. y .. " (resolutionTilesX = " .. resolutionTilesX .. " / resolutionTilesY = " .. resolutionTilesY .. ")")
						-- river_center_x = 27 ... y = 1
						if new_tilemap[river_center_x-1] == nil then
							print(table.show(new_tilemap))
							print("Allegedly new_tilemap[" .. (river_center_x-1) .. "] is nonexistant.")
							print(table.show(new_tilemap[river_center_x-1]))
							os.exit()
						end
						new_tilemap[river_center_x-1][y] = tiletype
						new_tilemap[river_center_x][y] = tiletype
						new_tilemap[river_center_x+1][y] = tiletype
						if tiletype == '=' then
							new_tilemap[river_center_x-2][y] = tiletype
							new_tilemap[river_center_x+2][y] = tiletype
						end
						river_shift = math.random(1,100)
						if river_shift < 4 then
							river_center_x = river_center_x - 1
						elseif river_shift > 96 then
							river_center_x = river_center_x + 1
						end
						if river_center_x < 4 then
							river_center_x = 4
						elseif river_center_x > resolutionTilesX-4 then
							river_center_x = resolutionTilesX-4
						end
					end
					
					--  - Second, a few buildings
					for i=1,5,1 do
						-- set scale (building are this x this squared)
						buildingScale=4
						-- find a location
						bx,by = randomStandingLocation(new_tilemap,4)
						-- fill it in
						for tx=bx,bx+buildingScale,1 do
							for ty=by,by+buildingScale,1 do
								new_tilemap[tx][ty] = '0'
							end
						end
					end
					--  - Third, a couple of roads
					-- TODO
					--  - Fourth, a water pond
					-- TODO
					--  - Fifth, some trees
					-- TODO
					instance.tilemap=new_tilemap

					-- Populate with NPCs
					instance.npcs = {}
					add_npcs(instance.npcs,'tai_villager_male',5)
					add_npcs(instance.npcs,'tai_villager_female',3)
					add_npcs(instance.npcs,'chicken',6)
					add_npcs(instance.npcs,'rooster',2)
					add_npcs(instance.npcs,'dog',2)
					add_npcs(instance.npcs,'water_buffalo',1)

                                        -- music
                                        instance.music = {
                                                                        "music/Greg_Reinfeld_-_02_-_Canon_in_D_ni_nonaC_Pachelbels_Canon.mp3",
                                                                        "music/Kevin MacLeod - Sardana.mp3",
                                                                        "music/Kevin MacLeod - Suonatore di Liuto.mp3",
                                                                        "music/Kevin MacLeod - Teller of the Tales.mp3",
                                                                        "music/Komiku_-_03_-_Champ_de_tournesol.mp3",
                                                                        "music/Komiku_-_05_-_La_Citadelle.mp3",
                                                                        "music/Komiku_-_06_-_La_ville_aux_ponts_suspendus.mp3"
                                                         }
                                        instance.music_volume=0.3

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
taiVillageNames=ROT.StringGenerator:new()
filename = "areas/tai_village/tai-village-names.txt"
f = assert(io.open(filename, "r"))
done=false
line=true
while not (line==nil) do
        line=f:read()
        if not (line==nil) then
                taiVillageNames:observe(line)
        end
end
f:close()
