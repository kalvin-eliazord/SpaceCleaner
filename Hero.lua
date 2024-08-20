-- Imports
local Vec2 = require("Vector2")
local Laser = require("Laser")
local Enemy = require("Enemy")
local Waste = require("Waste")
local Asteroid = require("Asteroid")

local Hero = {}
setmetatable(Hero, Vec2)
local DustList = {}
local tileSize = 32

function Hero:New(x, y)
    local hero = Vec2:New(x, y)
    hero.img = {}
    hero.oldState = nil
    hero.currState = "Idle"
    hero.bDodge = false
    hero.bRobot = false

    -- Idle animation
    hero.img["Idle"] = {}
    hero.img["Idle"].w = tileSize
    hero.img["Idle"].h = tileSize
    hero.img["Idle"].iFrame = 1
    hero.img["Idle"].iFrameMax = nil
    hero.img["Idle"].bFramesDone = false
    hero.img["Idle"].frames = {}
    hero.img["Idle"].frames[1] = love.graphics.newImage("images/hero/hero.png")

    -- Yellow Idle animation
    hero.img["IdleYellow"] = {}
    hero.img["IdleYellow"].iFrame = 1
    hero.img["IdleYellow"].w = tileSize
    hero.img["IdleYellow"].h = tileSize
    hero.img["IdleYellow"].iFrameMax = nil
    hero.img["IdleYellow"].bFramesDone = false
    hero.img["IdleYellow"].frames = {}
    hero.img["IdleYellow"].frames[1] = love.graphics.newImage("images/hero/yellow_hero.png")

    -- Dodge animation
    hero.img["Dodge"] = {}
    hero.img["Dodge"].iFrame = 1
    hero.img["Dodge"].iFrameMax = 6
    hero.img["Dodge"].bFramesDone = false
    hero.img["Dodge"].imgSheet = nil
    hero.img["Dodge"].frames = {}
    hero.img["Dodge"].frameV = 5
    hero.img["Dodge"] = Vec2:NewSpriteSheet("images/hero/hero_dodge.png", hero.img["Dodge"], tileSize)

    -- Tilt animation
    hero.img["Tilt"] = {}
    hero.img["Tilt"].iFrame = 1
    hero.img["Tilt"].bFramesDone = false
    hero.img["Tilt"].iFrameMax = 5
    hero.img["Tilt"].imgSheet = nil
    hero.img["Tilt"].frames = {}
    hero.img["Tilt"].frameV = 6
    hero.img["Tilt"] = Vec2:NewSpriteSheet("images/hero/hero_tilt.png", hero.img["Tilt"], tileSize)

    -- Transform animation
    hero.img["Transform"] = {}
    hero.img["Transform"].iFrame = 1
    hero.img["Transform"].bFramesDone = false
    hero.img["Transform"].iFrameMax = 7
    hero.img["Transform"].imgSheet = nil
    hero.img["Transform"].frames = {}
    hero.img["Transform"].frameV = 6
    hero.img["Transform"] = Vec2:NewSpriteSheet("images/hero/hero_transform2.png", hero.img["Transform"], tileSize * 2)

    -- Robot Idle animation
    hero.img["RobotIdle"] = {}
    hero.img["RobotIdle"].iFrame = 1
    hero.img["RobotIdle"].bFramesDone = false
    hero.img["RobotIdle"].iFrameMax = 6
    hero.img["RobotIdle"].imgSheet = nil
    hero.img["RobotIdle"].frames = {}
    hero.img["RobotIdle"].frameV = 7
    hero.img["RobotIdle"] = Vec2:NewSpriteSheet("images/hero/hero_robot_idle2.png", hero.img["RobotIdle"], tileSize * 2)

    -- Robot Sword animation
    hero.img["RobotSword"] = {}
    hero.img["RobotSword"].iFrame = 1
    hero.img["RobotSword"].bFramesDone = false
    hero.img["RobotSword"].iFrameMax = 7
    hero.img["RobotSword"].imgSheet = nil
    hero.img["RobotSword"].frames = {}
    hero.img["RobotSword"].frameV = 7
    hero.img["RobotSword"] = Vec2:NewSpriteSheet("images/hero/hero_robot_sword2.png", hero.img["RobotSword"],
        tileSize * 2)

    -- Robot Fly animation
    hero.img["RobotFly"] = {}
    hero.img["RobotFly"].iFrame = 1
    hero.img["RobotFly"].bFramesDone = false
    hero.img["RobotFly"].iFrameMax = 5
    hero.img["RobotFly"].imgSheet = nil
    hero.img["RobotFly"].frames = {}
    hero.img["RobotFly"].frameV = 7
    hero.img["RobotFly"] = Vec2:NewSpriteSheet("images/hero/hero_robot_fly2.png", hero.img["RobotFly"], tileSize * 2)

    hero.hp = 3
    hero.vx = 0
    hero.vy = 0.2
    hero.vMax = 0.5
    hero.r = -90
    hero.sxMax = 5
    hero.syMax = 5
    hero.bDash = false
    hero.iDash = 0
    hero.bDashCDR = false
    hero.score = 0

    setmetatable(hero, self)
    return hero
end

function Hero:NewEngine(x, y)
    local engine = Vec2:New(x, y)
    engine.img = love.graphics.newImage("images/engine3.png")
    engine.sxMin = 1.3
    engine.syMin = 1.3
    engine.sx = engine.sxMin
    engine.sy = engine.syMin

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
    dust.timer = 0.3
    table.insert(DustList, dust)
    return dust
end

function Hero:Load(pMapList)
    w = pMapList["inGame"].img:getWidth()
    h = pMapList["inGame"].img:getHeight()
    iStart = 2
    -- sound shi TODO
    startSound = love.audio.newSource("music/ship_start.mp3", "static")
    startSound:setVolume(0.5)

    Hero.hero = Hero:New(pMapList["inGame"].img:getWidth() / 2, pMapList["inGame"].img:getHeight() + 200)
    hero = Hero.hero

    Hero:NewEffect(hero, "SpeedMap", 1, 4)
    Hero:NewEffect(hero, "Dash", 1, 4)
    Hero:NewEffect(hero, "StartEntrance", 1, 0)
    Hero:NewEffect(hero, "Shooting", 0.2, 0)
    Hero:NewEffect(hero, "Dodge", 1, 4)
    Hero:NewEffect(hero, "DamageTaken", 1, 0)
    Hero:NewEffect(hero, "Shoot", 0, 3)
    Hero:NewEffect(hero, "Transform", 2, 0)
    Hero:NewEffect(hero, "Robot", 0, 0)

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

function UpdateHeroAnimation(dt)
    local currState = hero.img[hero.currState]
    if currState.iFrameMax ~= nil then
        if not hero.bRobot and hero.listEffect["Transform"].bActive then
            currState.iFrame = currState.iFrame - (dt * currState.frameV)
        else
            currState.iFrame = currState.iFrame + (dt * currState.frameV)
        end
        currState.bFramesDone = false
            if math.floor(currState.iFrame) == currState.iFrameMax and not currState.bFramesDone then
                currState.iFrame = 1
                currState.bFramesDone = true
            end
    end
end

function Hero:MapCollision(hero, dt)
    local Map = require("Map").current.img
    local iMax = 15
    if hero.x < 0 then
        hero.x = Map:getWidth() - 100
        for i = 1, iMax do
            Vec2:NewParticle(hero, "rect", 0, math.random(-20, 20), dt)
        end
        hero.listEffect["SpeedMap"].bActive = true
    elseif hero.x > Map:getWidth() then
        hero.x = 10
        for i = 1, iMax do
            Vec2:NewParticle(hero, "rect", 0, math.random(-20, 20), dt)
        end
        hero.listEffect["SpeedMap"].bActive = true

    elseif hero.y < 0 then
        hero.y = Map:getHeight() - 90
        for i = 1, iMax do
            Vec2:NewParticle(hero, "rect", math.random(-20, 20), 0, dt)
        end
        hero.listEffect["SpeedMap"].bActive = true

    elseif hero.y > Map:getHeight() then
        hero.y = 10
        for i = 1, iMax do
            Vec2:NewParticle(hero, "rect", math.random(-20, 20), 0, dt)
        end
        hero.listEffect["SpeedMap"].bActive = true
    end

    if hero.listEffect["SpeedMap"].bActive then
        hero.vx = hero.vx + dt
        hero.vy = hero.vy + dt
    end
end

function SetHeroAngle(hero, dt)
    if love.keyboard.isDown("right") then
        hero.r = hero.r + hero.vr * dt
    elseif love.keyboard.isDown("left") then
        hero.r = hero.r - hero.vr * dt
    end
end

function SetHeroMaxSpeed(hero)
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

function SetVelocity(hero, dt)
    local shipAngRad = math.rad(hero.r)
    local angX = math.cos(shipAngRad)
    local angY = math.sin(shipAngRad)
    hero.vx = hero.vx + angX * (dt * 100)
    hero.vy = hero.vy + angY * (dt * 100)

    Hero:SetVelocity(hero, dt)

    -- Engine Particles
    if hero.listEffect["Dash"].bActive then
        local iRand = math.random(2, 3)
        for i = 1, iRand do
            NewDust(hero.x + math.random(-6, 6), hero.y, hero.r)
        end
    end

end

function GetNearest(pListDst, pSrc)
    if not pListDst or not pSrc then
        return false
    end
    local nearest = false
    local oldDist = 99999
    for i, curr in ipairs(pListDst) do
        local currDist = math.sqrt((pSrc.x - curr.x) ^ 2 + (pSrc.y - curr.y) ^ 2)
        -- Shoot enemy only when they are visible
        if currDist < 400 then
            if currDist < oldDist then
                oldDist = currDist
                nearest = curr
            end
        end
    end

    return nearest
end

function Hero:IsCollideHero(pVec2)
    if not pVec2 or not hero then
        return
    end

    local currState = hero.img[hero.currState]
    local deltaX = hero.x - pVec2.x
    local deltaY = hero.y - pVec2.y
    if math.abs(deltaX) < (currState.w + pVec2.img:getWidth()) - 20 and math.abs(deltaY) <
        (currState.h + pVec2.img:getHeight()) - 20 then
        return true
    end

    return false
end

function Hero:Update(dt, cam)
    -- Engine process
    engine.x = hero.x
    engine.y = hero.y
    Vec2:SetShrink(engine, dt)

    -- Ship Start animation
    if not Vec2.bStart then
        love.audio.play(startSound)
        iStart = iStart - dt
        hero.y = hero.y - (dt * 100)
        if iStart <= 0 then
            startSound:stop()
            Vec2.bStart = true
        end
    else
        UpdateHeroAnimation(dt)
        SetHeroAngle(hero, dt)
        SetHeroMaxSpeed(hero)
        SetVelocity(hero, dt)
        Hero:MapCollision(hero, dt)

        -- New Laser
        local nearest = GetNearest(Enemy.list, hero)
        heroSpawnCDR = heroSpawnCDR - dt
        if heroSpawnCDR <= 0 and nearest then
            --  hero.listEffect["Shoot"].bActive = true -- TODO TOFIX
            -- print(hero.listEffect["Shoot"].iCurr)
            -- if math.floor(hero.listEffect["Shoot"].cdr) <= 0 and nearest then
            Laser.New(1, hero, nearest)
            hero.listEffect["Shooting"].bActive = true
            Vec2:NewParticle(hero, "rect", math.random(-0.5, 0.5), math.random(-0.5, 0.5), dt)
            -- local test = cam:move(200, 400)
            -- test.x = test.x + 20
            -- When hero shoot there is an halo (yellow spaceship sprite glowing for 0.5s below the hero)
            -- boolean shooting state w/timer
            heroSpawnCDR = maxSpawnCDR
        end

        -- Dodging animation
        if hero.listEffect["Dodge"].bActive then
            hero.sx = hero.sx + dt
            hero.sy = hero.sy + dt
        else
            if hero.sx > 1 then
                hero.sx = hero.sx - dt
                hero.sy = hero.sy - dt
            else
                if hero.img["Dodge"].bFramesDone then
                    hero.currState = "Idle"
                    hero.bDodge = false
                end
            end
        end

        -- Transform animation
        if hero.listEffect["Transform"].bActive then
            Vec2:SetShrink(hero, dt)
        end

        if hero.img["Transform"].bFramesDone then
            hero.oldState = "RobotIdle"
            hero.currState = "RobotIdle"
            hero.listEffect["Robot"].bActive = true
        end

        -- Robot Sword animation
        if hero.img["RobotSword"].bFramesDone then
            hero.currState = "RobotIdle"
        end

        -- Set Velocity of laser
        if Laser.list then
            for i, laser in ipairs(Laser.list) do
                if laser.type == 1 then -- hero type
                    Laser.SetGuidedLaser(laser, dt)

                    -- Hero Laser collision w/ enemies
                    if Hero:IsCollide(laser, laser.target) then
                        laser.target.hp = laser.target.hp - 1
                        if laser.target.hp <= 0 then
                            hero.score = hero.score + 10
                        end
                        laser.bDelete = true
                    end
                end
            end
        end

        -- Speed boost animation
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

        -- Waste cleaning process
        if Waste.list then
            for i = #Waste.list, 1, -1 do
                local waste = Waste.list[i]
                local dist = math.sqrt((waste.x - Hero.hero.x) ^ 2 + (waste.y - Hero.hero.y) ^ 2)

                if math.abs(dist) < waste.dist then
                    Vec2:PursueTarget(waste, Hero.hero, dt, 250)
                    waste.bSwallow = true

                    -- Swallow animation
                    if waste.bSwallow then
                        waste.sx = waste.sx - (dt * 5)
                        waste.sy = waste.sy - (dt * 5)
                        -- Sound Effect
                    end

                    if waste.bSwallow and Hero:IsCollideHero(waste) then
                        hero.score = hero.score + 20
                        waste.bDelete = true
                    end
                end
            end
        end

        -- Asteroid cleaning process
        if Asteroid.list then
            for i = #Asteroid.list, 1, -1 do
                local asteroid = Asteroid.list[i]
                local dist = math.sqrt((asteroid.x - Hero.hero.x) ^ 2 + (asteroid.y - Hero.hero.y) ^ 2)

                if math.abs(dist) < asteroid.dist then
                    Vec2:PursueTarget(asteroid, Hero.hero, dt, 250)
                    asteroid.bSwallow = true

                    -- Swallow animation
                    if asteroid.bSwallow then
                        asteroid.sx = asteroid.sx - (dt * 5)
                        asteroid.sy = asteroid.sy - (dt * 5)
                        -- Sound Effect
                    end

                    if asteroid.bSwallow and Hero:IsCollideHero(asteroid) then
                        asteroid.bDelete = true
                    end
                end
            end
        end

        -- Hero Effect process
        for i, effectName in pairs(hero.listEffectName) do
            local effect = hero.listEffect[effectName]
            Vec2:SetTempEffect(effect, dt)
        end
    end
end

function Hero:Draw()
    if DustList then
        for i, dust in ipairs(DustList) do
            love.graphics.draw(dust.img, dust.x, dust.y, dust.r, dust.sx, dust.sy, dust.img:getWidth() / 2,
                dust.img:getHeight() / 4)
        end
    end

    if hero.listEffect["Shooting"].bActive and hero.currState == "Idle" then
        love.graphics.draw(hero.img["IdleYellow"].frames[1], hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy,
            hero.img["IdleYellow"].frames[1]:getWidth() / 2, hero.img["IdleYellow"].frames[1]:getHeight() / 2)
    end

    if hero.listEffect["DamageTaken"].bActive then
        love.graphics.setColor(255, 0, 0)
    end

    if not hero.listEffect["Dash"].bActive then
        love.graphics.draw(engine.img, engine.x, engine.y, math.rad(hero.r), engine.sx, engine.sy,
            engine.img:getWidth() / 2, engine.img:getHeight() / 2)
    end

    local currState = hero.img[hero.currState]
    local heroImg = currState.frames[math.floor(currState.iFrame)]
    if currState.iFrameMax ~= nil then
        love.graphics.draw(currState.imgSheet, heroImg, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy,
            currState.w / 2, currState.h / 2)
    else
        love.graphics.draw(heroImg, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy, heroImg:getWidth() / 2,
            heroImg:getHeight() / 2)
    end

    love.graphics.setColor(255, 255, 255)
end

return Hero
