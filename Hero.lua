-- Imports
local Vec2 = require("Vector2")
local UI_Hearth = require("Health")
local Laser = require("Laser")
local Enemy = require("Enemy")

local Hero = {}
setmetatable(Hero, Vec2)

local w = 1024
local h = 768

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

function Hero:Load(pGameSizes)
    gSizes = pGameSizes
    UI_Hearth:Load()

    iStart = 2
    -- sound shi TODO
    startSound = love.audio.newSource("music/ship_start.mp3", "static")
    startSound:setVolume(0.5)
    Hero.hero = Hero:New(gSizes.w / 2, gSizes.h + 200)
    hero = Hero.hero
    hero.y = h
    engine = Hero:NewEngine(hero.x, hero.y)
    oldX = nil
    oldY = nil
    dist = 0
    maxDashCDR = 2
    dashCDR = maxDashCDR
    dashLeft = 2
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
    if love.keyboard.isDown("space") then
        local angX = math.cos(shipAngRad)
        local angY = math.sin(shipAngRad)
        hero.vx = hero.vx + angX * (dt / 20)
        hero.vy = hero.vy + angY * (dt / 20)
        engine.bEngine = true
    else
        engine.bEngine = false
    end

    Vec2:SetVelocity(hero)
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

function Hero:SetDash(hero, engine, dt)
    local shipAngRad = math.rad(hero.r)
    -- Ship iDash start
    if hero.bDash and dashCDR > 0 then
        hero.vx = 0
        hero.vy = 0
        oldX = hero.x
        oldY = hero.y
        angX = math.cos(shipAngRad)
        angY = math.sin(shipAngRad)
        hero.vx = hero.vx + angX + dt
        hero.vy = hero.vy + angY + dt

        engine.bEngine = true
        local dist = math.sqrt((oldX - hero.x) ^ 2 + (oldY - hero.y) ^ 2)
        if math.abs(dist) >= 50 then
            -- slow the ship
            hero.vx = hero.vx - (100 * dt)
            hero.vy = hero.vy - (100 * dt)
            dist = 0
            hero.bDash = true
        end
        hero.bDash = false
    end
end

function Hero:Update(dt)
    -- Ship Start animation => GameState 
    if not Vec2.bStart then
        love.audio.play(startSound)
        iStart = iStart - dt
        hero.y = hero.y - (dt * 100)
        if iStart <= 0 then
            startSound:stop()
            Vec2.bStart = true
        end
    end

    -- Hero laser New
    local nearest = GetNearest(Enemy.list, hero)
    -- if OnScreen(nearest) then
    heroSpawnCDR = heroSpawnCDR - dt
    if heroSpawnCDR <= 0 then
        Laser:New(1, hero, nearest)
        heroSpawnCDR = maxSpawnCDR
    end

    -- Set Velocity of laser
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]

            if laser.state == "noTarget" then
                laser.target = nearest
                laser.state = "Attack"
            end

            if laser.state == "Attack" then
                Laser:SetVelocity(laser, dt)
            end

            if Hero:IsCollide(laser, laser.target) then
                -- nearest.hp = nearest.hp - 1
                laser.target.hp = laser.target.hp - 1
                laser.bDelete = true
            end

            if laser.target.hp < 1 and laser.state == "Attack" then
                laser.state = nil
                if laser.state == nil then
                    laser.x = laser.x * dt
                    laser.y = laser.y * dt
                end
            end
        end
    end

    -- Hero ship process
    if Vec2.bStart then
        Hero:KeysControl(hero, engine, dt)

        Hero:SetMaxSpeed(hero)

        Hero:SetDash(hero, engine, dt)

        Hero:MapCollision(hero, dt)
    end

end

function Hero:Draw()
    UI_Hearth:Draw(hero.hp)

    love.graphics.draw(hero.img, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy, hero.img:getWidth() / 2,
        hero.img:getHeight() / 2)

    if engine.bEngine then
        love.graphics.draw(engine.img, hero.x, hero.y, math.rad(hero.r), engine.sx, engine.sy,
            engine.img:getWidth() / 2, engine.img:getHeight() / 2)
    end

    --   love.graphics.print("iDash: " .. hero.iDash, w / 2, 400)
    --    love.graphics.print("bDash: " .. tostring(hero.bDash), w / 2, 800)
    --   love.graphics.print("dist: " .. dist, w / 2, 100)
    --  love.graphics.print("dashCDR: " .. dashCDR, w / 4, 500)
end

return Hero
