area_types['tai_cave_entrance'] = {
				 name  = 'Tai Cave Entrance',
				 setup = function(instance) 
					-- Generate an appropriate name
					instance.name=taiCaveNames:generate()
					-- Generate an appropriate map
					instance.map=true
					-- Populate with NPCs
				 end
		       	    }

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
taiCaveNames=ROT.StringGenerator:new()
filename = "areas/tai_cave_entrance/tai-cave-names.txt"
f = assert(io.open(filename, "r"))
done=false
line=true
while not (line==nil) do
        line=f:read()
        if not (line==nil) then
                taiCaveNames:observe(line)
        end
end
f:close()
