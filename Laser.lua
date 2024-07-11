local Vec2 = require("Vector2")

local Laser = {}
Laser.__index = Laser
setmetatable(Laser, {
    __index = Vec2
})

-- Recode ev. about laser, new should be the same but the set Velocity should be different for hero and enemies

local w = 1024
local h = 768

function GetAngle(pVec1, pVec2)
    if pVec1 and pVec2 then
        return math.atan2(pVec2.y - pVec1.y, pVec2.x - pVec1.x)
    end
end

function Laser:New(pType, pSrc, pDst)
    if not Laser.list then
        Laser.list = {}
    end

    local laser = Vec2:New(pSrc.x, pSrc.y)
    laser.r = pSrc.r
    laser.sx = 1
    laser.sy = 1
    laser.vx = 0
    laser.vy = 0
    laser.target = pDst
    laser.type = pType

    laser.img = love.graphics.newImage("images/lasers/laser" .. pType .. ".png")

    setmetatable(laser, self)
    table.insert(Laser.list, laser)
end

function GetNearest(pList, pLaser)
    if not pList or not pLaser then
        return false
    end
    local nearest = pList[1]
    local oldDist = 99999
    for i, curr in ipairs(pList) do
        local currDist = math.sqrt((pLaser.x - curr.x) ^ 2 + (pLaser.y - curr.y) ^ 2)
        if currDist < oldDist then
            oldDist = currDist
            nearest = curr
        end
    end

    return nearest
end

function Laser:SetGuidedLaser(pLaser, dt)
    if not pLaser.target then return end
    -- local dist = math.sqrt((pLaser.x - pLaser.target.x) ^ 2 + (pLaser.y - pLaser.target.y) ^ 2)
    local toTargetAng = GetAngle(pLaser, pLaser.target)

    local heroSpeed = 300
    local angX = math.cos(toTargetAng)
    local angY = math.sin(toTargetAng)

    pLaser.vx = angX * heroSpeed
    pLaser.vy = angY * heroSpeed
    pLaser.x = pLaser.x + pLaser.vx * dt
    pLaser.y = pLaser.y + pLaser.vy * dt
end

function Laser:SetLaser(pLaser, dt)
    if not pLaser.target then return end
    -- local dist = math.sqrt((pLaser.x - pLaser.target.x) ^ 2 + (pLaser.y - pLaser.target.y) ^ 2)
    local toTargetAng = GetAngle(pLaser, pLaser.target)

    local heroSpeed = 300
    local angX = math.cos(toTargetAng)
    local angY = math.sin(toTargetAng)

    pLaser.vx = angX * heroSpeed
    pLaser.vy = angY * heroSpeed
    pLaser.x = pLaser.x + pLaser.vx * dt
    pLaser.y = pLaser.y + pLaser.vy * dt
end

function Laser:Load()
    maxSpawnCDR = 3
    heroSpawnCDR = maxSpawnCDR
    enemSpawnCDR = maxSpawnCDR
end

function OnScreen(pNearest)
    if not pNearest then
        return false
    end
    if pNearest.x >= 0 and pNearest.x <= w and pNearest.y >= 0 and pNearest.y <= h then
        return true
    end
    return false
end

function table.clear(t)
    for i = #t, 1, -1 do
        table.remove(t, i)
    end
end

function Laser:Update(dt)
    -- Laser Spawn based on enemy on screen
    local nearOnScreen = nil
end

function Laser:Draw()
    if Laser.list then
        for i, laser in ipairs(Laser.list) do
            love.graphics.draw(laser.img, laser.x, laser.y, 0, laser.sx, laser.sy)
            --     love.graphics.print("nearest" .. tostring(nearest), 0, 200)
            --   love.graphics.print("laserState   : " .. tostring(laser.state), 0, 300)
            -- love.graphics.print("laser.target.hp   : " .. tostring(laser.target.hp), 0, 600)

        end
    end

end

return Laser
