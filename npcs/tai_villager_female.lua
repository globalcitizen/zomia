npc_types['tai_villager_female'] = {
			name="Tai Female Villager",
			color={178,0,178},
			hostile=false,
			move='no',
			sounds={
				attack=love.audio.newSource({
					"npcs/tai_villager/tai_villager-1.wav",
					"npcs/tai_villager/tai_villager-2.wav",
					"npcs/tai_villager/tai_villager-3.wav"
				})
			},
			setup=function(instance) instance.name=taiFemaleNames:generate() end
		}

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
taiFemaleNames=ROT.StringGenerator:new()
filename = "npcs/tai_villager/tai-female-names.txt"
f = assert(io.open(filename, "r"))
done=false
line=true
while not (line==nil) do
	line=f:read()
	if not (line==nil) then
  		taiFemaleNames:observe(line)
 	end
end
f:close()
