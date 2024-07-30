-- Imports
local Vec2 = require("Vector2")
local Camera = require("lib/camera")

local Explosion = {}
Explosion.__index = Explosion
setmetatable(Explosion, {
    __index = Vec2
})

function Explosion:New(x, y)
    if not Explosion.list then
        Explosion.list = {}

        -- Explosion Img Init
        Explosion.imgList = {}
        for i = 1, 5 do
            Explosion.imgList[i] = love.graphics.newImage("images/explosions/explosion" .. i .. ".png")
        end
    end

    local explo = Vec2:New(x, y)
    explo.x = x
    explo.y = y

    explo.sx = math.random(0.99, 1)
    explo.sy = math.random(0.99, 1)
    explo.img = Explosion.imgList
    explo.indexImg = 1
    setmetatable(explo, self)
    table.insert(Explosion.list, explo)
end

function Explosion:Update(dt)
    -- Explosion animation
    if Explosion.list then
        for k = #Explosion.list, 1, -1 do
            local explo = Explosion.list[k]
            Vec2:SetShrink(explo, dt)
            explo.indexImg = explo.indexImg + (dt * 4)
            if explo.indexImg >= 5 then
                local part = Vec2:NewParticle(explo, "rect", math.random(-20, 20), math.random(-20, 20), dt)
                part.bExplosion = true
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
            love.graphics.draw(explo.img[index], explo.x, explo.y, 0, explo.sx, explo.sy,
                explo.img[index]:getWidth() / 2, explo.img[index]:getHeight() / 2)
        end
    end
end

return Explosion