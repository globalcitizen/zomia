-- holds active areas
areas={}
-- area types
area_types={}

-- instantiate area
function area_generate(z,x,y)
	local new_area = {}
	if world[z][x][y].type == nil then
		if z == 0 then
			new_area.type='wilderness'
		elseif z < 0 then
			new_area.type='natural_cavern'
		else
			print("ERROR: Transition to elevated area.")
			os.exit()
		end
	else
		new_area.type=world[z][x][y].type
	end
	if world[z][x][y].name ~= nil then
		new_area.name=world[z][x][y].name
	end
	print(" - Generating area type '" .. new_area.type .. "'.")
	setmetatable(new_area,{__index = area_types[area_type]})
	if area_types[new_area.type].setup ~= nil then
		area_types[new_area.type].setup(new_area)
	end
	return new_area
end

-- load areas
require "areas/natural_cavern"
require "areas/tai_cave"
require "areas/tai_cave_entrance"
require "areas/tai_village"
require "areas/wilderness"
