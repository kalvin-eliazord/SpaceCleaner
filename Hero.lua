-- Imports
local Vec2 = require("Vector2")
local UI_Hearth = require("Health")
local Laser = require("Laser")
local Enemy = require("Enemy")
local Waste = require("Waste")

local Hero = {}
setmetatable(Hero, Vec2)
local DustList = {}

function Hero:New(x, y)
    local hero = Vec2:New(x, y)
    hero.img = love.graphics.newImage("images/hero.png")
    hero.hp = 3
    hero.vx = 0
    hero.vy = 0.2
    hero.sx = 1
    hero.sy = 1
    hero.vMax = 0.5
    hero.bDash = false
    hero.r = -90
    hero.type = "hero"
    hero.iDash = 0
    hero.bDashCDR = false
    setmetatable(hero, self)
    return hero
end

function Hero:NewEngine(x, y)
    local engine = Vec2:New(x, y)
    engine.bEngine = false
    engine.img = love.graphics.newImage("images/engine3.png")
    engine.sx = 1.5
    engine.sy = 1.5
    engine.r = -90
    setmetatable(engine, self)
    return engine
end

function NewDust(x, y, r)
    local dust = {}
    dust.x = x
    dust.y = y
    local iDust = math.random(1, 4)
    dust.img = love.graphics.newImage("images/dust" .. iDust .. ".png")
    dust.sx = 0.5
    dust.sy = 0.5
    dust.r = r
    dust.timer = 0.2
    table.insert(DustList, dust)
    return dust
end

function Hero:Load(pMapList)
    UI_Hearth:Load()
    w = pMapList["inGame"].img:getWidth()
    h = pMapList["inGame"].img:getHeight()
    iStart = 2
    -- sound shi TODO
    startSound = love.audio.newSource("music/ship_start.mp3", "static")
    startSound:setVolume(0.5)

    Hero.hero = Hero:New(pMapList["inGame"].img:getWidth() / 2, pMapList["inGame"].img:getHeight() + 200)
    hero = Hero.hero
    hero.y = h
    engine = Hero:NewEngine(hero.x, hero.y)
    oldX = nil
    oldY = nil
    dist = 0
    maxDashCDR = 2
    dashCDR = maxDashCDR
    dashLeft = 2
    iTimer = 0.1
end

function Hero:MapCollision(hero, dt)
    if hero.x <= hero.img:getWidth() then
        hero.x = hero.x + hero.img:getWidth()
        hero.vx = (hero.vx * -1)
        hero.vx = hero.vx - (100 * dt)
    end
    if hero.x >= w - hero.img:getWidth() then
        hero.x = hero.x - hero.img:getWidth()
        hero.vx = (hero.vx * -1)
        hero.vx = hero.vx + (100 * dt)
    end
    if hero.y <= hero.img:getHeight() then
        hero.y = hero.y + hero.img:getHeight()
        hero.vy = (hero.vy * -1)
        hero.vy = hero.vy - (100 * dt)
    end
    if hero.y >= h - hero.img:getHeight() then
        hero.y = hero.y - hero.img:getHeight()
        hero.vy = (hero.vy * -1)
        hero.vy = hero.vy + (100 * dt)
    end
end

function Hero:KeysControl(hero, engine, dt)
    local shipAngRad = math.rad(hero.r)

    if love.keyboard.isDown("right") then
        hero.r = hero.r + hero.vr * dt
    elseif love.keyboard.isDown("left") then
        hero.r = hero.r - hero.vr * dt
    end

    Vec2:SetVelocity(hero)

    --  if love.keyboard.isDown("space") then
    --    local angX = math.cos(shipAngRad)
    --  local angY = math.sin(shipAngRad)
    -- hero.vx = hero.vx + angX * (dt / 20)
    -- hero.vy = hero.vy + angY * (dt / 20)
    -- engine.bEngine = true
    -- else
    -- engine.bEngine = false
    -- end

end

function Hero:SetMaxSpeed(hero)
    -- max Acceleration
    if not hero.bDash then
        if hero.vx >= hero.vMax then
            hero.vx = hero.vMax
        elseif hero.vx <= -hero.vMax then
            hero.vx = -hero.vMax
        end
        if hero.vy >= hero.vMax then
            hero.vy = hero.vMax
        elseif hero.vy <= -hero.vMax then
            hero.vy = -hero.vMax
        end
    end
end

function Hero:SetVelocity(hero, engine, dt)
    local shipAngRad = math.rad(hero.r)

    local angX = math.cos(shipAngRad)
    local angY = math.sin(shipAngRad)
    hero.vx = hero.vx + angX * (dt * 100)
    hero.vy = hero.vy + angY * (dt * 100)

    engine.bEngine = true

    local iRand = math.random(2, 3)
    for i = 1, iRand do
        NewDust(hero.x + math.random(-6, 6), hero.y, hero.r)
    end

    -- if hero.bDash and dashCDR > 0 then

    -- end
end

function Hero:Update(dt)
    -- Ship Start animation
    if not Vec2.bStart then
        love.audio.play(startSound)
        iStart = iStart - dt
        hero.y = hero.y - (dt * 100)
        if iStart <= 0 then
            startSound:stop()
            Vec2.bStart = true
        end
    end
    
    -- Hero ship process
    if Vec2.bStart then
        Hero:KeysControl(hero, engine, dt)
        Hero:SetMaxSpeed(hero)
        Hero:SetVelocity(hero, engine, dt)
        Hero:MapCollision(hero, dt)

        -- Hero laser New
        local nearest = GetNearest(Enemy.list, hero)

        heroSpawnCDR = heroSpawnCDR - dt
        if heroSpawnCDR <= 0 and nearest then
            Laser:New(1, hero, nearest)
            heroSpawnCDR = maxSpawnCDR
        end

        -- Set Velocity of laser
        if Laser.list then
            for i = #Laser.list, 1, -1 do
                local laser = Laser.list[i]
                if laser.type == 1 then -- hero type

                    Laser:SetGuidedLaser(laser, dt)

                    if Hero:IsCollide(laser, laser.target) then
                        laser.target.hp = laser.target.hp - 1
                        laser.bDelete = true
                    end

                    if laser.target and laser.target.hp < 1 then
                        laser.state = nil
                    end

                end
            end
        end

        if #DustList > 0 then
            for i = #DustList, 1, -1 do
                local dust = DustList[i]
                local iRand = math.random(-1, 1)
                dust.x = dust.x + ((hero.vx + iRand) * -1) + dt
                dust.y = dust.y + (hero.vy * -2) + dt
                dust.r = dust.r + dt
                dust.timer = dust.timer - dt
                if dust.timer <= 0 then
                    table.remove(DustList, i)
                end
            end

        end

        if Waste.list then
            for i = #Waste.list, 1, -1 do
                local waste = Waste.list[i]
                local dist = math.sqrt((waste.x - Hero.hero.x) ^ 2 + (waste.y - Hero.hero.y) ^ 2)

                if math.abs(dist) < waste.dist then
                    Vec2:PursueTarget(waste, Hero.hero, dt, 250)
                    waste.bSwallow = true

                    -- swallow animation
                    if waste.bSwallow then
                        waste.sx = waste.sx - dt
                        waste.sy = waste.sy - dt
                    end
                    if waste.bSwallow and Vec2:IsCollide(waste, Hero.hero) then
                        waste.bDelete = true
                        score = score + 1
                    end
                end
                --     waste.bSwallow = false
            end
        end
    end

end

function Hero:Draw()
    UI_Hearth:Draw(hero.hp)

    if hero.bDash then
        --   love.graphics.setColor(1, 0, 0)
        print("test")
    end

    if DustList then
        for i, dust in ipairs(DustList) do
            love.graphics.draw(dust.img, dust.x, dust.y, dust.r, dust.sx, dust.sy, dust.img:getWidth() / 2,
                dust.img:getHeight() / 4)
        end
    end

    love.graphics.draw(hero.img, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy, hero.img:getWidth() / 2,
        hero.img:getHeight() / 2)

    if hero.bDash then
        -- love.graphics.setColor(1, 1, 1)
    end

    --   love.graphics.print("iDash: " .. hero.iDash, w / 2, 400)
    --    love.graphics.print("bDash: " .. tostring(hero.bDash), w / 2, 800)
    --   love.graphics.print("dist: " .. dist, w / 2, 100)
    --  love.graphics.print("dashCDR: " .. dashCDR, w / 4, 500)
end

return Hero
