-- Imports
local Vec2 = require("Vector2")

local Health = {}
setmetatable(Health, Vec2)

function Health:New(x, y)
    local health = Vec2:New(x, y)
    health.img = love.graphics.newImage("images/health.png")
    health.sx = 0.1
    health.sy = 0.1
    setmetatable(health, self)
    return health
end

function Health:Load(pCam)
    heroHp = Health:New(0, 0)
    -- cam = pCam??
end

function Health:Draw(pHeroHp)
    for i = 1, pHeroHp do
        love.graphics.draw(heroHp.img, (i-1)*(heroHp.img:getWidth()/10), 0, 0, heroHp.sx, heroHp.sy)
    end
end

return Health