area_types['natural_cavern'] = {
				 name  = 'Natural Cavern',
				 setup = function(instance) 
                                        instance.name='Cavern'
                                        instance.prefix='Natural '

					-- Generate an appropriate map
					local new_tilemap
					new_tilemap = tilemap_new()

					-- generate tilemap
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
				        local generator = astray.Astray:new( math.floor(resolutionTilesX/2)-1, math.floor(resolutionTilesY/2)-1, 25, 90, 80, astray.RoomGenerator:new(22,2,5,2,5) )
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
					-- first 3 levels
					if world_location.z >= -3 then
				        	add_npcs(instance.npcs,'goblin',rng:random(2,math.abs(2.5*world_location.z)))
				        	add_npcs(instance.npcs,'bear',math.abs(world_location.z))
				        	add_npcs(instance.npcs,'mouse',rng:random(1,5))
					elseif world_location.z >= -5 then
				        	add_npcs(instance.npcs,'midnight_jelly',math.abs(world_location.z+3*rng:random(1,2)))
				        	add_npcs(instance.npcs,'bear',math.abs(world_location.z))
					end
			
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
						"sounds/ambient/cave-ambience.mp3",
						"sounds/ambient/cave-atmosphere.mp3",
						"sounds/ambient/cave-cavernscape.mp3",
						"sounds/ambient/cave-drips-2.mp3",
						"sounds/ambient/cave-drips.mp3",
						"sounds/ambient/cave-winds.mp3"
				                           }
					instance.ambient_volume = 2

					-- colors
                                        instance.colors={}
                                        instance.colors['groundColor'] = {25,25,25}

					-- FOV
					instance.fov = 15
				 end
		       	    }
