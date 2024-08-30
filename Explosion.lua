-- Imports
local Vec2 = require("Vector2")
local Camera = require("lib/camera")
local Sound = require("Sound")

local Explosion = {}
Explosion.__index = Explosion
setmetatable(Explosion, {
    __index = Vec2
})
local tileSize = 64

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

    -- Animation init 
    for i=1, 5 do
        explo.img[i] = {}
        explo.img[i] = Explosion.imgList[i]
    end

    explo.iFrame = 1
    -- local animName = "explosion_sheets"
    -- explo.img[animName] = Vec2:InitAnimList(explo.img, "explosions", animName, 6, 2, tileSize, tileSize)
    -- explo.img[animName] = Vec2:NewLineFrameList(explo.img[animName])

    setmetatable(explo, self)
    table.insert(Explosion.list, explo)
end

function Explosion:Load()
    Vec2:NewImgList(Explosion, "explosions/explosion", 5)
end

function Explosion:UpdateAnimation(explo, dt)
    explo.iFrame = explo.iFrame + (dt * 5)
    if math.floor(explo.iFrame) == Explosion.imgImax then
       return true
    end
    return false
end

function Explosion:Update(dt)
    -- Explosion animation
    if Explosion.list then 
        for k = #Explosion.list, 1, -1 do
            local explo = Explosion.list[k]
             Vec2:SetShrink(explo, 1, dt)

            -- Explosion sound
            if not explo.bSound then
                Sound.PlayStatic("explosion_" .. math.random(1, 2))
                explo.bSound = true
            end

            if Explosion:UpdateAnimation(explo, dt) then
                Vec2:NewParticle(explo, "yellow", math.random(-20, 20), math.random(-20, 20), math.random(1, 3), dt)
                table.remove(Explosion.list, k)
            end
        end

    end
end

function Explosion:Draw()
    if Explosion.list then
        for k, explo in ipairs(Explosion.list) do
            love.graphics.draw(explo.img[math.floor(explo.iFrame)].img, explo.x, explo.y, explo.r, explo.sx, explo.sy)
        end
    end
end

return Explosion
