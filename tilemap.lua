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

-- Fill a rectangle on the tilemap with a certain maptiletype
function tilemap_draw_recangle(tilemap,sx,sy,width,height,maptiletype)
	for x=sx,sx+width,1 do
		for y=sy,sy+width,1 do
			tilemap[x][y] = maptiletype
		end
	end
end
