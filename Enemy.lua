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
Enemy.maxSpawnCDR = 4
Enemy.spawnCDR = Enemy.maxSpawnCDR

function Enemy:New(x, y)
    if not Enemy.list then
        Enemy.list = {}
    end

    local enem = Vec2:New(x, y)
    enem.type = math.random(1, Enemy.imgImax)
    enem.vx = math.random(-200, 200)
    enem.vy = math.random(-200, 200)
    enem.sx = 0.1
    enem.sy = 0.1
    enem.img = Enemy.imgList[enem.type]
    enem.wasteMaxSpawn = math.random(1, 5)
    enem.wasteSpawn = enem.wasteMaxSpawn
    enem.laserMaxSpawn = math.random(4, 6)
    enem.laserSpawn = enem.laserMaxSpawn
    enem.bArrow = false
    enem.bReady = false
    setmetatable(enem, self)
    table.insert(Enemy.list, enem)
end

function Enemy:Load()
    Vec2:NewImgList(Enemy, "enemies/enemy", 6)
end

function Enemy:IsCollideHero(pEnem)
    if not pEnem then
        return
    end

    local hero = require("Hero").hero
    local iFrame = hero.img[hero.currState].iFrame
    local heroImg = hero.img[hero.currState].frames[math.floor(iFrame)]
    local deltaX = hero.x - pEnem.x
    local deltaY = hero.y - pEnem.y

    if math.abs(deltaX) < (hero.img[hero.currState].w + pEnem.img:getWidth()) - 20 and math.abs(deltaY) <
        (hero.img[hero.currState].h + pEnem.img:getHeight()) - 20 then
        return true
    end

    return false
end

function Enemy:Update(dt)
    Enemy.spawnCDR = Enemy.spawnCDR - dt

    local hero = require("Hero").hero

    if Enemy.list then
        for i = #Enemy.list, 1, -1 do
            local enem = Enemy.list[i]
            Enemy:NewTempEffect(enem, "DamageTaken", 1, 0)

            if not enem.bReady then
                if math.floor(enem.sx) ~= 1 then
                    enem.sx = enem.sx + dt
                    enem.sy = enem.sy + dt
                    Vec2:NewParticle(enem, "red",math.random(-20, 20), math.random(-20, 20), 0.005, dt )
                else
                    enem.bReady = true
                end
            else
                -- Waste Spawn by Enemy
                enem.wasteSpawn = enem.wasteSpawn - dt
                if enem.wasteSpawn <= 0 then
                    Waste:New(enem.x, enem.y)
                    enem.wasteSpawn = enem.wasteMaxSpawn
                end

                -- Enemy collision w/ Hero
                if Enemy:IsCollideHero(enem) and not hero.bDodge then
                    if not hero.listEffect["RobotSword"].bActive then
                        hero.hp = hero.hp - 1
                        hero.listEffect["DamageTaken"].bActive = true
                    end
                    enem.hp = enem.hp - 1
                    Explosion:New(enem.x, enem.y, dt)
                    enem.listEffect["DamageTaken"].bActive = true
                end

                -- Enemy Shrinking
                Enemy:SetShrink(enem, 1, dt)

                -- Enemy rotation
                enem.r = Vec2:GetAngle(enem, hero)

                -- Enemy logic based on type
                if enem.type == 5 or enem.type == 2 then
                    enem.laserSpawn = enem.laserSpawn - dt
                    if enem.laserSpawn <= 0 then
                        Laser:New(2, enem, hero)
                        enem.laserSpawn = enem.laserMaxSpawn
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

    end

    -- Set Velocity of enemy laser
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]
            if laser.type == 2 then -- enemy type
                Laser.SetLaser(laser, dt)
                Vec2:NewParticle(laser, "red", math.random(-0.1, 0.1), math.random(-0.1, 0.1), 0.0001, dt)

                -- Enemy Laser to Hero
                if Enemy:IsCollideHero(laser) and hero.listEffect["RobotSword"].bActive then
                    laser.vy = laser.vy * -1
                    laser.vx = laser.vx * -1
                elseif Enemy:IsCollideHero(laser) and not hero.bDodge then
                    laser.bDelete = true
                    Explosion:New(hero.x + love.math.random(-2, 2), hero.y + love.math.random(-2, 2))
                    hero.hp = hero.hp - 1
                    hero.listEffect["DamageTaken"].bActive = true
                end
            end
        end
    end

end

function Enemy:Draw()
    if Enemy.list then
        for i, enem in ipairs(Enemy.list) do

            if enem.listEffect["DamageTaken"].bActive then
                love.graphics.setColor(1, 0, 0)
            end

            love.graphics.draw(enem.img, enem.x, enem.y, enem.r, enem.sx, enem.sy, enem.img:getWidth() / 2,
                enem.img:getHeight() / 2)

            love.graphics.setColor(1, 1, 1)
        end
    end
end

return Enemy
