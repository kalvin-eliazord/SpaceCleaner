local Vec2 = require("Vector2")
local Laser = require("Laser")

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, {
    __index = Vec2
})

function Enemy:New()
    if not Enemy.list then
        Enemy.list = {}
    end

    local enemType = math.random(1, 6)
    local enemX = math.random(0, w)
    local enemY = math.random(0, h)

    local enem = Vec2:New(enemX, enemY)
    enem.type = enemType
    enem.vx = math.random(-200, 200)
    enem.vy = math.random(-200, 200)
    enem.sx = 1
    enem.sy = 1
    enem.img = love.graphics.newImage("images/enemies/enemy" .. enemType .. ".png")

    setmetatable(enem, self)
    table.insert(Enemy.list, enem)
end

function Enemy:Load()
    exploImgList = {}
    for i = 1, 5 do
        exploImgList[i] = love.graphics.newImage("images/explosions/explosion" .. i .. ".png")
    end

    maxSpawnCDR = 2
    spawnCDR = maxSpawnCDR
end

function NewExplosion(x, y)
    if not Enemy.exploList then
        Enemy.exploList = {}
    end

    local explosion = {}
    explosion.x = x
    explosion.y = y

    explosion.sx = 1
    explosion.sy = 1
    explosion.img = exploImgList
    explosion.indexImg = 1
    table.insert(Enemy.exploList, explosion)
end

function Enemy:Update(dt)
    -- Enemy Spawn
    spawnCDR = spawnCDR - dt
    if spawnCDR <= 0 then
        Enemy:New()
        spawnCDR = maxSpawnCDR
    end

    -- Set Velocity
    if Enemy.list then
        for i = #Enemy.list, 1, -1 do
            local enem = Enemy.list[i]

            -- if enemy type 1 or 2
            local hero = require("Hero").hero
            if Enemy:IsCollide(enem, hero) then
                hero.hp = hero.hp - 1
                enem.hp = enem.hp - 1
                NewExplosion(hero.x, hero.y, dt)
            end

            -- enemy logic based on type
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

            -- explosion creation
            if enem.hp <= 0 then
                for j = 1, 3 do
                    NewExplosion(enem.x + love.math.random(-15, 15), enem.y + love.math.random(-10, 10))
                end
                table.remove(Enemy.list, i)
            end

            -- Explosion
            if Enemy.exploList then
                for k = #Enemy.exploList, 1, -1 do
                    local explo = Enemy.exploList[k]
                    explo.indexImg = explo.indexImg + (dt * 4)
                    if explo.indexImg >= 5 then
                        explo.indexImg = 5
                        table.remove(Enemy.exploList, k)
                    end
                end
            end

        end

    end

    -- Set Velocity of laser
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]
            if laser.type == 2 then -- enemy type
                Laser.SetLaser(laser, dt)

                if Vec2:IsCollide(laser, hero) then
                    laser.bDelete = true
                    NewExplosion(hero.x + love.math.random(-2, 2), hero.y + love.math.random(-2, 2))
                    hero.hp = hero.hp - 1
                end

                if Vec2:IsOutScreen(laser) then
                    --       laser.bDelete = true
                end

                if laser.bDelete then
                    table.remove(Laser.list, i)
                end
            end

        end
    end

end

function Enemy:Draw()
    -- Enemies
    if Enemy.list then
        for i, enem in ipairs(Enemy.list) do
            love.graphics.draw(enem.img, enem.x, enem.y, enem.r, enem.sx, enem.sy, enem.img:getWidth() / 2,
                enem.img:getHeight() / 2)
        end
    end

    -- Explosion
    if Enemy.exploList then
        for k, explo in ipairs(Enemy.exploList) do
            local index = math.floor(explo.indexImg)
            love.graphics.draw(explo.img[index], explo.x, explo.y, 0, explo.sx, explo.sy,
                explo.img[index]:getWidth() / 2, explo.img[index]:getHeight() / 2)
        end
    end

end

return Enemy
