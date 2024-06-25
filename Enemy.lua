local Vec2 = require("Vector2")
local Hero = require("Hero")

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, {
    __index = Vec2
})

local w = 1024
local h = 768

function Enemy:New()
    if not Enemy.list then
        Enemy.list = {}
    end

    local enemType = love.math.random(1, 6)
    local enemX = love.math.random(0, w)
    local enemY = love.math.random(0, h)

    local enem = Vec2:New(enemX, enemY)
    enem.type = enemType
    enem.vx = love.math.random(-200, 200)
    enem.vy = love.math.random(-200, 200)
    enem.sx = 1
    enem.sy = 1
    enem.img = love.graphics.newImage("images/enemies/enemy" .. enemType .. ".png")

    setmetatable(enem, self)
    table.insert(Enemy.list, enem)
end

function Enemy:Load()
    self.exploImgList = {}
    for i = 1, 5 do
        self.exploImgList[i] = love.graphics.newImage("images/explosions/explosion" .. i .. ".png")
    end

    maxSpawnCDR = 2
    spawnCDR = maxSpawnCDR
end

function Enemy:NewExplosion(x, y)
    if not Enemy.exploList then
        Enemy.exploList = {}
    end

    local explosion = Vec2:New(x, y)
    explosion.sx = 1
    explosion.sy = 1
    explosion.img = self.exploImgList
    explosion.indexImg = 1
    setmetatable(explosion, self)
    -- Vec2:AddEnt(explosion)
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
            if enem.type == 6 then
                Vec2:PursueTarget(enem, Hero.hero, dt, 100)
            elseif enem.type == 4 then
                Vec2:PursueTarget(enem, Hero.hero, dt, 0)
            end
            if enem.hp <= 0 then
                -- explosion creation
                for j = 1, 3 do
                    Enemy:NewExplosion(enem.x+love.math.random(-15, 15), enem.y+love.math.random(-10, 10))
                end
                table.remove(Enemy.list, i)
            end
        end
    end

    -- Explosion
    if Enemy.exploList then
        for k = #Enemy.exploList, 1, -1 do
            local explo = Enemy.exploList[k]
            explo.indexImg = explo.indexImg + (dt * 8)
            if explo.indexImg >= 5 then
                explo.indexImg = 5
                table.remove(Enemy.exploList, k)
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
