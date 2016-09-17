npc_types['tai_villager_male'] = {
			name="Tai Male Villager",
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
			setup=function(instance) instance.name=taiMaleNames:generate() end
		}

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
taiMaleNames=ROT.StringGenerator:new()
filename = "npcs/tai_villager/tai-male-names.txt"
for line in love.filesystem.lines(filename) do
        if not (line==nil) then
                taiMaleNames:observe(line)
        end
end
