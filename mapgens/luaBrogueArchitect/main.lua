ROT = require "rotLove"
require "tilemap"
require "luaBrogueArchitect"
require "tableshow"

rng = ROT.RNG.Twister:new()
rng:randomseed()

tilemap = mapgen_broguestyle(24,80)

tilemap_show(tilemap,"End result")
os.exit()

function love.update()
end

function love.draw()
end
