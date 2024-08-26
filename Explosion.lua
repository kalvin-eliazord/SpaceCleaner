-- Imports
local Vec2 = require("Vector2")
local Camera = require("lib/camera")
local Sound = require("Sound")

local Explosion = {}
Explosion.__index = Explosion
setmetatable(Explosion, {
    __index = Vec2
})

function Explosion:New(x, y)
    if not Explosion.list then
        Explosion.list = {}
    end

    local explo = Vec2:New(x, y)
    explo.x = x
    explo.y = y
    explo.bSound = false
    explo.sx = math.random(0.99, 1)
    explo.sy = math.random(0.99, 1)
    explo.img = Explosion.imgList[1]
    explo.indexImg = 1
    setmetatable(explo, self)
    table.insert(Explosion.list, explo)
end

function Explosion:Load()
    Vec2:NewImgList(Explosion, "explosions/explosion", 5)
end

function Explosion:Update(dt)
    -- Explosion animation
    if Explosion.list then
        for k = #Explosion.list, 1, -1 do
            local explo = Explosion.list[k]
            Vec2:SetShrink(explo, 1,dt)
            if not explo.bSound then
                Sound.PlayStatic("explosion_"..math.random(1,2))
                explo.bSound = true
            end
            explo.indexImg = explo.indexImg + (dt * 4)
            if explo.indexImg >= 5 then
                local part = Vec2:NewParticle(explo, "yellow", math.random(-20, 20), math.random(-20, 20),math.random(1, 3), dt)
                explo.indexImg = 5
                table.remove(Explosion.list, k)
            end
        end

    end
end

function Explosion:Draw()
    if Explosion.list then
        for k, explo in ipairs(Explosion.list) do
            local index = math.floor(explo.indexImg)
            love.graphics.draw(explo.imgList[index], explo.x, explo.y, 0, explo.sx, explo.sy,
                explo.imgList[index]:getWidth() / 2, explo.imgList[index]:getHeight() / 2)
        end
    end
end

return Explosion