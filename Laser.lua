local Vec2 = require("Vector2")

local Laser = {}
Laser.__index = Laser
setmetatable(Laser, {
    __index = Vec2
})

local w = 1024
local h = 768

function Laser:New(pType, x, y, r)
    if not Laser.list then
        Laser.list = {}
    end

    local laser = Vec2:New(x, y)
    laser.r = r
    laser.sx = 1
    laser.sy = 1
    laser.vx = 0
    laser.vy = 0
    laser.target = {}
    laser.state = "noTarget"
    laser.type = pType

    if pType == "hero" then
        laser.img = love.graphics.newImage("images/lasers/laser1.png")
    elseif pType == "enemy" then
        local dist = math.sqrt((laser.x - Hero.hero.x) ^ 2 + (laser.y - Hero.hero.y) ^ 2)
        local toEnemyAng = math.angle(laser.x, laser.y, Hero.hero.x, Hero.hero.y)

        local heroSpeed = 300
        local angX = math.cos(toEnemyAng)
        local angY = math.sin(toEnemyAng)

        laser.vx = angX * heroSpeed
        laser.vy = angY * heroSpeed
        laser.img = love.graphics.newImage("images/lasers/laser2.png")
        -- laser.target = Hero.hero
    end

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
    if Enemy.list then
        for l, enem in ipairs(Enemy.list) do
            if Vec2:IsCollide(enem, Hero.hero) then
                Hero.hero.hp = Hero.hero.hp - 1
                enem.hp = enem.hp - 1
                Enemy:NewExplosion(Hero.hero.x+math.random(-5, 5), Hero.hero.y+math.random(-5, 5), dt)
            end
            if enem.type == 4 or enem.type == 2 then
                enemSpawnCDR = enemSpawnCDR - dt
                if enemSpawnCDR <= 0 then
                    Laser:New("enemy", enem.x, enem.y, enem.r)
                    enemSpawnCDR = maxSpawnCDR
                end
            end
        end

        local nearest = GetNearest(Enemy.list, Hero.hero)
        if OnScreen(nearest) then
            nearOnScreen = nearest
            heroSpawnCDR = heroSpawnCDR - dt
            if heroSpawnCDR <= 0 then
                Laser:New("hero", Hero.hero.x, Hero.hero.y, Hero.hero.r)
                heroSpawnCDR = maxSpawnCDR
            end
        end

        -- Set Velocity of laser
        if Laser.list then
            for i = #Laser.list, 1, -1 do
                local laser = Laser.list[i]

                if laser.type == "hero" then
                    if nearOnScreen then

                        if laser.state == "noTarget" then
                            laser.target = nearest
                            laser.state = "Attack"
                        end

                        if laser.state == "Attack" then
                            Laser:SetVelocity(laser, dt)
                        end

                        if Vec2:IsCollide(laser, nearest) then
                            nearest.hp = nearest.hp - 1
                            laser.target.hp = laser.target.hp - 1
                            laser.bDelete = true
                        end

                        if laser.target.hp < 1 and laser.state == "Attack" then
                            laser.state = nil
                            if laser.state == nil then
                                laser.x = laser.x * dt
                                laser.y = laser.y * dt
                                if Vec2:IsCollide(laser, Hero.hero) then
                                    laser.bDelete = true
                                    Hero.hero.hp = Hero.hero.hp - 1
                                end
                            end
                        end
                    end

                elseif laser.type == "enemy" then
                    laser.x = laser.x + laser.vx * dt
                    laser.y = laser.y + laser.vy * dt
                end

                if Vec2:IsOutScreen(laser) then
                    laser.bDelete = true
                end

                if laser.bDelete then
                    table.remove(Laser.list, i)
                end

            end
        end
    end

end

function Laser:destroy()

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
