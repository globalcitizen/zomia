area_types['tai_village'] = {
				 name  = 'Tai Village',
				 setup = function(instance) 
					-- Generate an appropriate name
					instance.name=taiVillageNames:generate()
					-- Generate an appropriate map
					instance.map=true
					-- Populate with NPCs
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

for i=1,100,1 do
 print(" - " .. taiVillageNames:generate())
end
