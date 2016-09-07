npc_types['yi_villager'] = {
			name="Yi Villager",
			color={230,230,248},
			hostile=false,
			move='no',
			sounds={
				attack=love.audio.newSource({
					"npcs/yi_villager/yi_villager-1.wav",
					"npcs/yi_villager/yi_villager-2.wav",
					"npcs/yi_villager/yi_villager-3.wav"
				})
			},
			setup=function(instance) instance.name=yiNames:generate() end
		}

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
yiNames=ROT.StringGenerator:new()
filename = "npcs/yi_villager/yi-names.txt"
f = assert(io.open(filename, "r"))
done=false
line=true
while not (line==nil) do
	line=f:read()
	if not (line==nil) then
  		yiNames:observe(line)
 	end
end
f:close()
