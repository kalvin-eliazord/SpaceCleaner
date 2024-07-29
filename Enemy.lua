-- Imports
local Vec2 = require("Vector2")
local Laser = require("Laser")
local Waste = require("Waste")
local Explosion = require("Explosion")

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, {
    __index = Vec2
})

function Enemy:New(x, y)
    if not Enemy.list then
        Enemy.list = {}
    end

    local enem = Vec2:New(x, y)
    enem.type = math.random(1, 6)
    enem.vx = math.random(-200, 200)
    enem.vy = math.random(-200, 200)
    enem.img = love.graphics.newImage("images/enemies/enemy" .. enem.type .. ".png")
    enem.wasteSpawn = 1
    enem.wasteMaxSpawn = math.random(1, 5)
    enem.bArrow = false
    setmetatable(enem, self)
    table.insert(Enemy.list, enem)
end

function Enemy:Load()
    maxSpawnCDR = 4
    spawnCDR = maxSpawnCDR
end

function Enemy:Update(dt)
    spawnCDR = spawnCDR - dt

    -- Enemy Spawn
    if math.floor(spawnCDR) < 0 then
        local Map = require("Map").current.img
        --print(Map.current.name)
        Enemy:New(math.random(20, Map:getWidth() - 100), math.random(20, Map:getHeight() - 300))
        spawnCDR = maxSpawnCDR + math.random(4, 6)
    end

    if Enemy.list then
        for i = #Enemy.list, 1, -1 do
            local enem = Enemy.list[i]

            -- Waste Spawn by Enemy
            enem.wasteSpawn = enem.wasteSpawn - dt
            if enem.wasteSpawn <= 0 then
                Waste:New(enem.x, enem.y)
                enem.wasteSpawn = enem.wasteMaxSpawn
            end

            -- Enemy collision w/ Hero
            local hero = require("Hero").hero
            if Enemy:IsCollide(enem, hero) then
                hero.hp = hero.hp - 1
                enem.hp = enem.hp - 1
                Explosion:New(hero.x, hero.y, dt)
            end

            -- Enemy Shrinking
            Enemy:SetShrink(enem, dt)

            -- Enemy rotation
            enem.r = GetAngle(enem, hero)

            -- Enemy logic based on type
            if enem.type == 5 or enem.type == 2 then
                enemSpawnCDR = enemSpawnCDR - dt
                if enemSpawnCDR <= 0 then
                    Laser.New(2, enem, hero)
                    enemSpawnCDR = maxSpawnCDR
                end

            elseif enem.type == 6 then
                Enemy:PursueTarget(enem, hero, dt, 200)
            elseif enem.type == 4 then
                Enemy:PursueTarget(enem, hero, dt, 0)
            end

            Enemy:MapCollision(enem, dt)

            -- New Explosion
            if enem.hp <= 0 then
                for j = 1, 3 do
                    Explosion:New(enem.x + love.math.random(-15, 15), enem.y + love.math.random(-10, 10))
                end
                enem.bDelete = true
            end

            -- Delete Enemy
            if enem.bDelete and not enem.bArrow then
                table.remove(Enemy.list, i)
            end
        end

    end

    -- Set Velocity of laser
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]
            if laser.type == 2 then -- enemy type
                Laser.SetLaser(laser, dt)

                -- Enemy Laser to Hero explosion
                if Enemy:IsCollide(laser, hero) then
                    laser.bDelete = true
                    Explosion:New(hero.x + love.math.random(-2, 2), hero.y + love.math.random(-2, 2))
                    hero.hp = hero.hp - 1
                end

                if laser.bDelete then
                    table.remove(Laser.list, i)
                end
            end

        end
    end

end

function Enemy:Draw()
    if Enemy.list then
        for i, enem in ipairs(Enemy.list) do
            love.graphics.draw(enem.img, enem.x, enem.y, enem.r, enem.sx, enem.sy, enem.img:getWidth() / 2,
                enem.img:getHeight() / 2)
        end
    end
end

return Enemy