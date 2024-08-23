-- Imports
local Vec2 = require("Vector2")
local Laser = require("Laser")
local Enemy = require("Enemy")
local Waste = require("Waste")
local Asteroid = require("Asteroid")
local Sound = require("Sound")

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
    local animName = "Idle"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, nil, nil)
    hero.img[animName].w = tileSize
    hero.img[animName].h = tileSize

    -- Dash animation
    local animName = "Dash"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, nil, nil)
    hero.img[animName].w = tileSize
    hero.img[animName].h = tileSize

    -- Yellow Idle animation
    animName = "IdleYellow"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, nil, nil)
    hero.img[animName].w = tileSize
    hero.img[animName].h = tileSize

    -- Dodge animation
    animName = "Dodge"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 7, 5)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize)

    -- Tilt animation
    animName = "Tilt"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 5, 6)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize)

    -- Transform animation
    animName = "Transform"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 7, 7)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize * 2)

    -- Robot Idle animation
    animName = "RobotIdle"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 7, 7)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize * 2)

    -- Robot Sword animation
    animName = "RobotSword"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 7, 7)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize * 2)
    animName = "RobotSword2"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 5, 5)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize * 2)

    -- Robot Fly animation
    animName = "RobotFly"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 5, 7)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize * 2)

    -- Robot Shoot animation
    animName = "RobotShoot"
    hero.img[animName] = Hero:NewAnimation(hero.img, animName, 7, 7)
    hero.img[animName] = Vec2:NewFrameList(hero.img[animName], tileSize * 2)

    hero.hp = 3
    hero.vx = 0
    hero.vy = 0.2
    hero.vMax = 0.5
    hero.r = -90
    hero.sxMax = 1.5
    hero.syMax = 1.5
    hero.score = 0

    setmetatable(hero, self)
    return hero
end

function Hero:Load(pMapList)
    MAP_WIDTH = pMapList["inGame"].img:getWidth()
    MAP_HEIGHT = pMapList["inGame"].img:getHeight()

    -- New Hero's SpaceShip
    Hero.hero = Hero:New(MAP_WIDTH / 2, MAP_HEIGHT)
    hero = Hero.hero
    hero.y = MAP_HEIGHT

    -- New Effects
    Vec2:NewTempEffect(hero, "StartGame", 2, 0)
    Vec2:NewTempEffect(hero, "SpeedMap", 1, 4)
    Vec2:NewTempEffect(hero, "Dash", 1, 4)
    Vec2:NewTempEffect(hero, "Shooting", 0.8, 0)
    Vec2:NewTempEffect(hero, "Dodge", 1, 4)
    Vec2:NewTempEffect(hero, "DamageTaken", 1, 0)
    Vec2:NewTempEffect(hero, "Shoot", 0.01, 3)
    Vec2:NewTempEffect(hero, "Transform", 1.2, 5)
    Vec2:NewTempEffect(hero, "Robot", 0, 0)
    Vec2:NewTempEffect(hero, "RobotFly", 1, 4)
    Vec2:NewTempEffect(hero, "RobotSword", 1, 1)
    Vec2:NewTempEffect(hero, "RobotSword2", 1, 1)
    Vec2:NewTempEffect(hero, "RobotShoot", 2, 4)

    hero.listEffect["StartGame"].bActive = true

    -- New SpaceShip's Engine
    engine = Hero:NewEngine(hero.x, hero.y)
end

function Hero:NewAnimation(pHeroImg, pAnimName, pFrameMax, pFrameV)
    pHeroImg[pAnimName] = {}
    pHeroImg[pAnimName].iFrame = 1
    pHeroImg[pAnimName].bFramesDone = false
    pHeroImg[pAnimName].iFrameMax = pFrameMax
    pHeroImg[pAnimName].imgSheet = love.graphics.newImage("images/hero/" .. pAnimName .. ".png")
    pHeroImg[pAnimName].frames = {}
    pHeroImg[pAnimName].frameV = pFrameV
    pHeroImg[pAnimName].bReverse = false
    return pHeroImg[pAnimName]
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
    dust.img = love.graphics.newImage("images/dust" .. math.random(1, 4) .. ".png")
    dust.sx = 0.5
    dust.sy = 0.5
    dust.r = r
    dust.timer = 0.2
    table.insert(DustList, dust)
    return dust
end

function Hero:UpdateAnimation(hero, dt)
    local currState = hero.img[hero.currState]
    -- print("iFrame: ", currState.iFrame, " frameMax: ", currState.iFrameMax, " name: ", hero.currState)
    if currState.iFrameMax ~= nil then
        if currState.bReverse then
            currState.iFrame = currState.iFrame - (dt * currState.frameV)
            if math.floor(currState.iFrame) == 1 then
                currState.bFramesDone = true
                currState.bReverse = false
                -- currState.iFrame = 7
            end
        else
            currState.iFrame = currState.iFrame + (dt * currState.frameV)
            if math.floor(currState.iFrame) == currState.iFrameMax then
                currState.iFrame = 1
                currState.bFramesDone = true
            end
        end
    end
end

function Hero:ActivateAnimation(hero, effectName)
    --    print("effectName: ", effectName, " bReady: ", hero.listEffect[effectName].bReady)
    if hero.img[effectName] and hero.listEffect[effectName].bReady then
        hero.img[effectName].bFramesDone = false
        hero.listEffect[effectName].bActive = true
        hero.oldState = hero.currState
        hero.currState = effectName
        return true
    end
    return false
end

function Hero:MapCollision(hero, dt)
    local Map = require("Map").current.img
    local iMax = 15
    if hero.x < 0 then
        hero.x = Map:getWidth() - 100
        for i = 1, iMax do
            Vec2:NewParticle(hero, nil, 0, math.random(-20, 20), math.random(1, 3), dt)
        end
        hero.listEffect["SpeedMap"].bActive = true
    elseif hero.x > Map:getWidth() then
        hero.x = 10
        for i = 1, iMax do
            Vec2:NewParticle(hero, nil, 0, math.random(-20, 20), math.random(1, 3), dt)
        end
        hero.listEffect["SpeedMap"].bActive = true

    elseif hero.y < 0 then
        hero.y = Map:getHeight() - 90
        for i = 1, iMax do
            Vec2:NewParticle(hero, nil, math.random(-20, 20), 0, math.random(1, 3), dt)
        end
        hero.listEffect["SpeedMap"].bActive = true

    elseif hero.y > Map:getHeight() then
        hero.y = 10
        for i = 1, iMax do
            Vec2:NewParticle(hero, nil, math.random(-20, 20), 0, math.random(1, 3), dt)
        end
        hero.listEffect["SpeedMap"].bActive = true
    end

    if hero.listEffect["SpeedMap"].bActive then
        hero.vx = hero.vx + dt
        hero.vy = hero.vy + dt
    end
end

function SetHeroAngle(hero, dt)
    hero.bTilt = false

    if love.keyboard.isDown("right") then
        hero.r = hero.r + hero.vr * dt
        hero.bTilt = true
    elseif love.keyboard.isDown("left") then
        hero.r = hero.r - hero.vr * dt
        hero.bTilt = true
    end

    if hero.bTilt and not hero.bDodge and not hero.bRobot then
        hero.img["Tilt"].bFramesDone = false
        hero.currState = "Tilt"
    end
end

function SetHeroMaxSpeed(hero)
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

function SetIdleAnimation()
    if hero.bRobot then
        if hero.currState ~= "RobotIdle" and hero.img[hero.currState].bFramesDone then
            hero.currState = "RobotIdle"
        end
    else
        if hero.currState ~= "Idle" and hero.img[hero.currState].bFramesDone then
            hero.currState = "Idle"
        end
    end
end

function Hero:Update(dt, cam)
    -- Hero Effect process
    Vec2:SetTempEffects(hero, dt)

    -- Engine process
    engine.x = hero.x
    engine.y = hero.y
    -- Vec2:NewParticle(engine, "red", 0, -hero.vy, 0.001)
    Vec2:SetShrink(engine, 0.9, dt)

    -- Ship Start animation
    if hero.listEffect["StartGame"].bActive then
        Sound.PlayStatic("ship_start")
        hero.y = hero.y - (dt * 100)
    else
        if Sound.StopStatic("ship_start") then
            Vec2.bStart = true
        end

        Hero:UpdateAnimation(hero, dt)
        SetHeroAngle(hero, dt)
        SetHeroMaxSpeed(hero)
        SetVelocity(hero, dt)
        Hero:MapCollision(hero, dt)

        -- New Laser
        local nearest = Vec2:GetNearest(Enemy.list, hero)

        heroSpawnCDR = heroSpawnCDR - dt
   --     print(hero.listEffect["Shoot"].bReady)

        if nearest and hero.listEffect["Shoot"].bReady then
            hero.listEffect["Shoot"].bActive = true
        end
        -- print(hero.listEffect["Shoot"].iCurr)
        --   if heroSpawnCDR <= 0 and nearest then
        if hero.listEffect["Shoot"].bActive and nearest then
            Laser.New(1, hero, nearest)
            Sound.PlayStatic("laserShoot_" .. math.random(1, 6))
            hero.listEffect["Shooting"].bActive = true
            Vec2:NewParticle(hero, "yellow", math.random(-0.5, 0.5), math.random(-0.5, 0.5), math.random(1, 3), dt)
            -- local test = cam:move(200, 400)
            -- test.x = test.x + 20
            heroSpawnCDR = maxSpawnCDR
            hero.listEffect["Shoot"].bActive = false
            hero.listEffect["Shoot"].bReady = false
            hero.listEffect["Shoot"].cdr = 0
         end

        -- Dodging animation
        if hero.listEffect["Dodge"].bActive then
            Vec2:NewParticle(hero, nil, math.random(-20, 20), math.random(-20, 20), 0.005, dt)
            hero.sx = hero.sx + dt
            hero.sy = hero.sy + dt
        else
            if hero.currState == "Dodge" and hero.img["Dodge"].bFramesDone then
                hero.bDodge = false
            end
            if hero.sx > 1 then
                hero.sx = hero.sx - dt
                hero.sy = hero.sy - dt
            end
        end

        if hero.listEffect["SpeedMap"].bActive then
            hero.vx = hero.vx + dt
            hero.vy = hero.vy + dt
            Vec2:NewParticle(hero, nil, math.random(-20, 20), math.random(-20, 20), 0.005, dt)
        end

        -- Transform Robot animation
        if hero.listEffect["Transform"].bActive then
            Vec2:NewParticle(hero, nil, math.random(-20, 20), math.random(-20, 20), 0.005, dt)

            -- Be invicible
            hero.bDodge = true
            if hero.img["Transform"].bFramesDone then
                hero.bDodge = false
            end
        end

        -- Robot Sword animation
        if hero.listEffect["RobotSword"].bActive then
            if hero.img["RobotSword"].bFramesDone then
                --     hero.listEffect["RobotSword"].bActive = false
            end
            Vec2:NewParticle(hero, "green", math.random(-15, 15), math.random(-15, 15), 0.002, dt)
            if hero.listEffect["RobotSword2"].bActive and math.floor(hero.img[hero.currState].iFrame) == 5 then
                Hero:ActivateAnimation(hero, "RobotSword2")
            end
            -- Attack with tp to enemy
        end

        if hero.currState == "RobotSword2" and hero.img["RobotSword2"].bFramesDone then
            hero.img["RobotSword"].iFrame = 1
        end

        -- Robot Shoot animation
        if hero.listEffect["RobotShoot"].bActive then
            Vec2:NewParticle(hero, "yellow", math.random(-20, 20), math.random(-20, 20), 0.005, dt)
        end

        -- Robot Fly animation
        if hero.listEffect["RobotFly"].bActive then
            -- Dash
            hero.listEffect["Dash"].bActive = true
        end

        -- Temp animation
        SetIdleAnimation()

        -- Set Velocity of Hero laser
        if Laser.list then
            for i, laser in ipairs(Laser.list) do
                if laser.type == 1 then -- hero type
                    Vec2:NewParticle(laser, "yellow", math.random(-0.1, 0.1), math.random(-0.1, 0.1), 0.0001, dt)

                    Laser.SetGuidedLaser(laser, dt)

                    -- Hero Laser collision w/ enemies
                    if Hero:IsCollide(laser, laser.target) then
                        laser.target.listEffect["DamageTaken"].bActive = true
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
                if Vec2:IsDistInferior(waste, hero, waste.dist) then
                    Vec2:PursueTarget(waste, Hero.hero, dt, 250)
                    waste.bSwallow = true

                    -- Swallow animation
                    if waste.bSwallow then
                        waste.sx = waste.sx - (dt * 10)
                        waste.sy = waste.sy - (dt * 10)
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
        AsteroidCollision(dt)
    end
end

function AsteroidCollision(dt)
    if Asteroid.list then
        for i = #Asteroid.list, 1, -1 do
            local asteroid = Asteroid.list[i]
            if Hero:IsCollideHero(asteroid) then
                asteroid.x = asteroid.x
                asteroid.y = asteroid.y
                asteroid.vx = asteroid.vx * -1
                asteroid.vy = asteroid.vy * -1
                -- New Effect on ast
                if not asteroid.listEffect["PushAst"] then
                    Vec2:NewTempEffect(asteroid, "PushAst", 1, 0)
                end
                asteroid.listEffect["PushAst"].bActive = true
            end
            -- Vec2:PursueTarget(asteroid, Hero.hero, dt, 250) push it into enemies
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
        love.graphics.draw(hero.img["IdleYellow"].imgSheet, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy,
            hero.img["IdleYellow"].w / 2, hero.img["IdleYellow"].h / 2)
    end

    if hero.listEffect["DamageTaken"].bActive then
        love.graphics.setColor(1, 0, 0)
    end

    if not hero.listEffect["Dash"].bActive then
        local engineBoost = 1
        if hero.bRobot then
            engineBoost = 2
        end
        love.graphics.draw(engine.img, engine.x, engine.y, math.rad(hero.r), engine.sx * engineBoost,
            engine.sy * engineBoost, engine.img:getWidth() / 2, engine.img:getHeight() / 2)
    end

    local currState = hero.img[hero.currState]
    local heroImg = currState.frames[math.floor(currState.iFrame)]
    if currState.iFrameMax ~= nil then
        if currState.imgSheet and heroImg then
            love.graphics.draw(currState.imgSheet, heroImg, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy,
                currState.w / 2, currState.h / 2)
        end
    else
        love.graphics.draw(currState.imgSheet, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy, currState.w / 2,
            currState.h / 2)
    end

    love.graphics.setColor(255, 255, 255)
end

return Hero
