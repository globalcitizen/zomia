npc_types['tibetan_villager'] = {
			name="Tibetan Villager",
			color={200,98,58},
			hostile=false,
			move='no',
			sounds={
				attack=love.audio.newSource({
					"npcs/tibetan_villager/tibetan_villager-1.wav",
					"npcs/tibetan_villager/tibetan_villager-2.wav",
					"npcs/tibetan_villager/tibetan_villager-3.wav"
				})
			},
			setup=function(instance) instance.name=tibetanNames:generate() end
		}

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
tibetanNames=ROT.StringGenerator:new()
filename = "npcs/tibetan_villager/tibetan-names.txt"
for line in love.filesystem.lines(filename) do
        if not (line==nil) then
                tibetanNames:observe(line)
        end
end
