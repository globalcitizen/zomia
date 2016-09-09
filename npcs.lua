-- holds active npcs
npcs={}
-- holds reference npc types
npc_types={}

-- add NPC(s) to specified structure (eg. could be npcs (current map NPCs), or a world[z][x][y].npcs structure for other areas)
function add_npcs(structure,npc_type,npc_qty)
	if npc_qty == nil then
		npc_qty = 1
	end
	for i=0,npc_qty,1 do
		local new_npc = {}
		new_npc.type=npc_type
		setmetatable(new_npc,{__index = npc_types[npc_type]})
		if new_npc.setup ~= nil then
			new_npc:setup(new_npc)
		end
		table.insert(structure,new_npc)
	end
end


-- load reference npc types
require "npcs/chicken"
require "npcs/dog"
require "npcs/goblin"
require "npcs/mouse"
require "npcs/rooster"
require "npcs/water_buffalo"
require "npcs/akha_villager"
require "npcs/hmong_villager"
require "npcs/tai_villager_female"
require "npcs/tai_villager_male"
require "npcs/tibetan_villager"
require "npcs/yi_villager"
