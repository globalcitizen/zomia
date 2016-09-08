area_types['wilderness'] = {
				 name  = 'Wilderness',
				 setup = function(instance) 
					-- Generate an appropriate name
					instance.name=wildernessNames:generate()
					-- Generate an appropriate map
					instance.map=true
					-- Populate with NPCs
				 end
		       	    }

-- generate names via markov process: first train via 'observe()' then generate via 'generate()'
lines = {}
wildernessNames=ROT.StringGenerator:new()
filename = "areas/wilderness/wilderness-names.txt"
f = assert(io.open(filename, "r"))
done=false
line=true
while not (line==nil) do
        line=f:read()
        if not (line==nil) then
                wildernessNames:observe(line)
        end
end
f:close()
