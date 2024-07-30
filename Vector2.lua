local Vector2 = {}
Vector2.__index = Vector2

function Vector2:New(x, y)
    local vec2 = {}
    vec2.x = x
    vec2.y = x
    vec2.r = 0
    vec2.hp = 1
    vec2.vx = 0
    vec2.vy = 0
    vec2.vr = 400
    vec2.bShrink = false
    vec2.sxMax = 1.5
    vec2.syMax = 1.5
    vec2.sxMin = 1
    vec2.syMin = 1
    vec2.sx = vec2.sxMin
    vec2.sy = vec2.syMin
    vec2.bDelete = false
    setmetatable(vec2, self)
    return vec2
end

function Vector2:SetShrink(pVec2, dt)
    -- Enlarge
    if not pVec2.bShrink then
        if pVec2.sx > pVec2.sxMax then
            pVec2.bShrink = true
        end
        pVec2.sx = pVec2.sx + dt
        pVec2.sy = pVec2.sy + dt
    end

    -- Shrink
    if pVec2.bShrink == true then
        if pVec2.sx < pVec2.sxMin then
            pVec2.bShrink = false
        end
        pVec2.sx = pVec2.sx - dt
        pVec2.sy = pVec2.sy - dt
    end
end

function Vector2:SetImage(pFolder, pImg) -- USE THAT
    self.img = love.graphics.newImage(pFolder .. pImg)
end

function Vector2:IsCollide(pVec1, pVec2)
    if not pVec1 or not pVec2 then
        return
    end
    if pVec1 == pVec2 then
        return false
    end

    local deltaX = pVec1.x - pVec2.x
    local deltaY = pVec1.y - pVec2.y

    if math.abs(deltaX) < (pVec1.img:getWidth() + pVec2.img:getWidth()) - 20 and math.abs(deltaY) <
        (pVec1.img:getHeight() + pVec2.img:getHeight()) - 20 then
        return true
    end

    return false
end

function Vector2:SetTempEffect(pListEffect, pEffect)
    local effect = pListEffect[pEffect]

    if effect ~= nil then
        effect.iCurr = effect.iCurr - dt
        if pSrc_iCurr <= 0 then
            effect.bool = not effect.bool
            effect.iCurr = effect.iMax
        end
    end
end

function Vector2:PursueTarget(pSrc, pDst, dt, pSpeed)
    function math.angle(x1, y1, x2, y2)
        return math.atan2(y2 - y1, x2 - x1)
    end

    local dist = math.sqrt((pSrc.x - pDst.x) ^ 2 + (pSrc.y - pDst.y) ^ 2)
    local toHeroAng = math.angle(pSrc.x, pSrc.y, pDst.x, pDst.y)
    local speed = 0

    if pSpeed > 0 then
        speed = pSpeed
    else
        speed = love.math.random(50, 200)
    end

    local angX = math.cos(toHeroAng)
    local angY = math.sin(toHeroAng)

    pSrc.vx = angX * speed
    pSrc.vy = angY * speed
    pSrc.x = pSrc.x + pSrc.vx * dt
    pSrc.y = pSrc.y + pSrc.vy * dt
end

function Vector2:SetVelocity(pVec, dt)
    pVec.x = pVec.x + pVec.vx + dt
    pVec.y = pVec.y + pVec.vy + dt
end

function Vector2:NewParticle(pSrc, pType, vx, vy, dt)
    if pSrc == nil then
        return
    end
    if not Vector2.particleList then
        Vector2.particleList = {}
    end

    local particle = {}
    particle.x = pSrc.x + math.random(-10, 10)
    particle.y = pSrc.y + math.random(-10, 10)
    particle.w = math.random(2, 5)
    particle.h = particle.w
    particle.duration = math.random(1, 3)
    particle.vx = vx
    particle.vy = vy
    particle.r = 0
    particle.type = pType
    table.insert(Vector2.particleList, particle)
    return particle
end

function Vector2:Update(dt)
    if Vector2.particleList then
        for i, particle in ipairs(Vector2.particleList) do
            Vector2:SetVelocity(particle, dt)
            particle.w = particle.w - dt
            particle.h = particle.h - dt
            particle.duration = particle.duration - dt
            if particle.duration < 0 then
                particle.bDelete = true
            end
        end

        for i = #Vector2.particleList, 1, -1 do
            local particle = Vector2.particleList[i]
            if particle.bDelete then
                table.remove(Vector2.particleList, i)
            end
        end
    end
end

function Vector2:Load()
    Vector2.bStart = false
end

function Vector2:MapCollision(pVec2, dt)
    if pVec2 == nil then
        return
    end

    local Map = require("Map").current.img
    local iMax = 15
    if pVec2.x < 0 then
        pVec2.x = Map:getWidth() - 100
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, 0, math.random(-20, 20), dt)
        end
    elseif pVec2.x > Map:getWidth() then
        pVec2.x = 10
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, 0, math.random(-20, 20), dt)
        end
    elseif pVec2.y < 0 then
        pVec2.y = Map:getHeight() - 90
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, math.random(-20, 20), 0, dt)
        end
    elseif pVec2.y > Map:getHeight() then
        pVec2.y = 10
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, math.random(-20, 20), 0, dt)
        end
    end
end

function Vector2:IsOutScreen(pVec)
    local Map = require("Map").current.img
    if pVec.x < 0 or pVec.x > Map:getWidth() or pVec.y < 0 or pVec.y > Map:getHeight() then
        return true
    end

    return false
end

function Vector2:Destroy(pIndex) -- NOT USED
    table.remove(self.list, pIndex)
end

function Vector2:Draw()
    if Vector2.particleList then
        for i, particle in ipairs(Vector2.particleList) do
            if particle.type == "rect" then
                if particle.bExplosion then
                    love.graphics.setColor(200, 255, 0)
                end

                love.graphics.rectangle("fill", particle.x, particle.y, particle.w, particle.h)
                love.graphics.setColor(255, 255, 255)
            else
                love.graphics.circle("fill", particle.x, particle.y, particle.w, particle.h)
            end

        end
    end
end

return Vector2