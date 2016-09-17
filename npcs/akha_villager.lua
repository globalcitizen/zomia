npc_types['akha_villager'] = {
			name="Akha Villager",
			color={0,128,128},
			hostile=false,
			move='no',
			sounds={
				attack=love.audio.newSource({
					"npcs/akha_villager/akha_villager-1.wav",
					"npcs/akha_villager/akha_villager-2.wav",
					"npcs/akha_villager/akha_villager-3.wav"
				})
			},
			setup=function(instance) instance.name=akhaNames:generate() end
		}

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
akhaNames=ROT.StringGenerator:new()
filename = "npcs/akha_villager/akha-names.txt"
for line in love.filesystem.lines(filename) do
	if not (line==nil) then
  		akhaNames:observe(line)
 	end
end
