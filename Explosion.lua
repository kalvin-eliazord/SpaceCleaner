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

    -- Img 
    local animName = "explosion_sheets"
    explo.currState = animName
    explo.img[animName] = Vec2:NewAnimation(explo.img, "explosions", animName, 5, 5, tileSize, tileSize)
    explo.img[animName] = Vec2:NewLineFrameList(explo.img[animName])

    setmetatable(explo, self)
    table.insert(Explosion.list, explo)
end

function Explosion:Load()
end

function Explosion:Update(dt)
    -- Explosion animation
    if Explosion.list then
        for k = #Explosion.list, 1, -1 do
            local explo = Explosion.list[k]
            Vec2:SetShrink(explo, 1, dt)
            if not explo.bSound then
                Sound.PlayStatic("explosion_" .. math.random(1, 2))
                explo.bSound = true
            end
            Vec2:UpdateAnimation(explo, dt)
            local currState = explo.img[explo.currState]
            if currState.iFrame >= 5 then
                Vec2:NewParticle(explo, "yellow", math.random(-20, 20), math.random(-20, 20), math.random(1, 3), dt)
                table.remove(Explosion.list, k)
            end
        end

    end
end

function Explosion:Draw()
    if Explosion.list then
        for k, explo in ipairs(Explosion.list) do
            local currState = explo.img[explo.currState]
            local exploImg = currState.frames[math.floor(currState.iFrame)]
            if currState.imgSheet and exploImg then
                love.graphics.draw(currState.imgSheet, exploImg, exploImg.x, exploImg.y, exploImg.r, exploImg.sx,
                    exploImg.sy, currState.w / 2, currState.h / 2)
            end
        end
    end
end

return Explosion
