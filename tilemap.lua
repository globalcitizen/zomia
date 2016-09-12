-- Tile map related utility functions
--
-- Tile maps are tables of structure:
--  name[x][y]
--
-- The values of each cell define the fixed features at that position on the map.
--
-- These values are known as map tile types.

maptiletypes = {
			[0]='rock',
			[1]='floor',
			[2]='closed door',
			[3]='open door',
			['T']='tree',
			['W']='water',
			['=']='bridge_horizontal'
	       }

-- New tilemap
function tilemap_new(width,height,defaultmaptiletype)
	width = width or resolutionTilesX
	height = height or resolutionTilesY
	defaultmaptiletype = defaultmaptiletype or 0
	local m={}
	for x=1,width,1 do
		m[x] = {}
		for y=1,height,1 do
			m[x][y] = defaultmaptiletype
		end
	end
	return m
end

-- Find all instances of a specific maptiletype on a tilemap
function tilemap_find_maptiletype(tilemap,maptiletype)
	local results = {}
	for x=1,#tilemap,1 do
		for y=1,#tilemap[1],1 do
			if tilemap[x][y] == maptiletype then
				table.insert(results,{x=x,y=y})
			end
		end
	end
	return results
end

-- Fill a rectangle on the tilemap with a certain maptiletype
function tilemap_draw_rectangle(tilemap,sx,sy,width,height,maptiletype)
	for x=sx,sx+width,1 do
		for y=sy,sy+width,1 do
			tilemap[x][y] = maptiletype
		end
	end
end

-- Fill a circle on the tilemap with a certain maptiletype
function tilemap_draw_circle(tilemap,sx,sy,radius,maptiletyle)
	--[[
	for (i=max(0, x - radius - 1); i < max(DCOLS, x + radius); i++) {
		for (j=max(0, y - radius - 1); j < max(DROWS, y + radius); j++) {
			if ((i-x)*(i-x) + (j-y)*(j-y) < radius * radius + radius) {
				grid[i][j] = value;
			}
		}
	}
	--]]
	for i=math.max(0,sx-radius-1), math.max(#tilemap, sx+radius), 1 do
		for j=math.max(0,sy-radius-1), math.max(#tilemap[1],sy+radius),1 do
			if ((i-sx)*(i-sx) + (j-sy)*(j-sy)) < (radius*radius + radius) then
				tilemap[i][j] = maptiletype
			end
		end
	end

	return tilemap
end
