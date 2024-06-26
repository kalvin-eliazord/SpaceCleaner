local Vec2 = require("Vector2")

local Laser = {}
Laser.__index = Laser
setmetatable(Laser, {
    __index = Vec2
})

local w = 1024
local h = 768

function Laser:NewHero(pHero, r)
    if not Laser.list then
        Laser.list = {}
    end

    local laser = Vec2:New(pHero.x, pHero.y)
    laser.r = r
    laser.sx = 1
    laser.sy = 1
    laser.vx = 0
    laser.vy = 0
    laser.target = {}
    laser.state = "noTarget"
    laser.type = pType

    laser.img = love.graphics.newImage("images/lasers/laser1.png")

    local offsetX = math.cos(math.rad(r))
    local offsetY = math.sin(math.rad(r))
    laser.x = x + offsetX
    laser.y = y + offsetY

    setmetatable(laser, self)
    table.insert(Laser.list, laser)
end

function Laser:NewEnemy(pEnem, pHero, r)
    if not Laser.list then
        Laser.list = {}
    end

    local laser = Vec2:New(pEnem.x, pEnem.y)
    laser.r = r
    laser.sx = 1
    laser.sy = 1
    laser.vx = 0
    laser.vy = 0
    laser.target = {}
    laser.state = "noTarget"
    laser.type = pType

    local dist = math.sqrt((laser.x - pHero.x) ^ 2 + (laser.y - pHero.y) ^ 2)
    local toEnemyAng = math.angle(laser.x, laser.y, pHero.x, pHero.y)

    local heroSpeed = 300
    local angX = math.cos(toEnemyAng)
    local angY = math.sin(toEnemyAng)

    laser.vx = angX * heroSpeed
    laser.vy = angY * heroSpeed
    laser.img = love.graphics.newImage("images/lasers/laser2.png")

    local offsetX = math.cos(math.rad(r))
    local offsetY = math.sin(math.rad(r))
    laser.x = x + offsetX
    laser.y = y + offsetY

    setmetatable(laser, self)
    table.insert(Laser.list, laser)
end

function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
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

function Laser:SetVelocity(pLaser, dt)
    local dist = math.sqrt((pLaser.x - pLaser.target.x) ^ 2 + (pLaser.y - pLaser.target.y) ^ 2)
    local toEnemyAng = math.angle(pLaser.x, pLaser.y, pLaser.target.x, pLaser.target.y)

    local heroSpeed = 300
    local angX = math.cos(toEnemyAng)
    local angY = math.sin(toEnemyAng)

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
            love.graphics.draw(laser.img, laser.x, laser.y, laser.r, laser.sx, laser.sy)
            --     love.graphics.print("nearest" .. tostring(nearest), 0, 200)
            --   love.graphics.print("laserState   : " .. tostring(laser.state), 0, 300)
            -- love.graphics.print("laser.target.hp   : " .. tostring(laser.target.hp), 0, 600)

        end
    end

end

return Laser
