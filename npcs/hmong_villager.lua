npc_types['hmong_villager'] = {
			name="Hmong Villager",
			color={32,228,128},
			hostile=false,
			move='no',
			sounds={
				attack=love.audio.newSource({
					"npcs/hmong_villager/hmong_villager-1.wav",
					"npcs/hmong_villager/hmong_villager-2.wav",
					"npcs/hmong_villager/hmong_villager-3.wav"
				})
			},
			setup=function(instance) instance.name=hmongNames:generate() end
		}

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
hmongNames=ROT.StringGenerator:new()
filename = "npcs/hmong_villager/hmong-names.txt"
f = assert(io.open(filename, "r"))
done=false
line=true
while not (line==nil) do
	line=f:read()
	if not (line==nil) then
  		hmongNames:observe(line)
 	end
end
f:close()
