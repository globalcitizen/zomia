-- holds active areas
areas={}
-- area types
area_types={}

-- instantiate area
function area_generate(z,x,y)
	local new_area = {}
	new_area.type=world[z][x][y].type
	if world[z][x][y].name ~= nil then
		new_area.name=world[z][x][y].name
	end
	setmetatable(new_area,{__index = area_types[area_type]})
	if new_area.setup ~= nil then
		new_area:setup(new_area)
	end
	world[z][x][y] = new_area
end

-- load areas
require "areas/tai_cave"
require "areas/tai_cave_entrance"
require "areas/tai_village"
require "areas/wilderness"
