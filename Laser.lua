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

function GetNearest(pListDst, pSrc)
    if not pListDst or not pSrc then
        return false
    end
    local nearest = pListDst[1]
    local oldDist = 99999
    for i, curr in ipairs(pListDst) do
        local currDist = math.sqrt((pSrc.x - curr.x) ^ 2 + (pSrc.y - curr.y) ^ 2)
        if currDist < oldDist then
            oldDist = currDist
            nearest = curr
        end
    end

    return nearest
end

function Laser:SetGuidedLaser(pLaser, dt)
  --  if not pLaser.target then return end
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
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]
            if laser.bDelete then
                table.remove(Laser.list, i)
            end
        end
    end
end

function Laser:Draw()
    if Laser.list then
        for i, laser in ipairs(Laser.list) do
            love.graphics.draw(laser.img, laser.x, laser.y, laser.r, laser.sx, laser.sy)
        end
    end

end

return Laser
