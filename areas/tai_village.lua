area_types['tai_village'] = {
				 name  = 'Tai Village',
				 setup = function(instance) 
					-- Generate an appropriate name
					instance.name=taiVillageNames:generate()
					-- Generate an appropriate map
					local new_tilemap = {}
					for i=1,resolutionTilesX,1 do
						new_tilemap[i] = {}
						for j=1,resolutionTilesY,1 do
							new_tilemap[i][j] = '1'
						end
					end
					instance.tilemap=new_tilemap
					-- Populate with NPCs

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
                                        instance.music_volume=0.05
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
