-- Imports
local Vec2 = require("Vector2")
local Laser = require("Laser")
local Enemy = require("Enemy")
local Waste = require("Waste")
local Asteroid = require("Asteroid")
local Sound = require("Sound")
local Vortex = require("Vortex")

-- Separate modules for cleaner structure
local HeroMovement = require("HeroMovement")
local HeroEffects = require("HeroEffects")
local HeroAnimations = require("HeroAnimations")

local Hero = {}
Hero.__index = Hero
setmetatable(Hero, { __index = Vec2 })

local tileSize = 32

-- 🏆 Create a new Hero object
function Hero:New(x, y)
    local hero = Vec2:New(x, y)
    hero.hp = 3
    hero.vx, hero.vy = 0, 0.2
    hero.vMax = 0.5
    hero.r = -90 -- Rotation angle
    hero.sx, hero.sy = 1, 1
    hero.sxMax, hero.syMax = 1.5, 1.5
    hero.score = 0
    hero.bDodge, hero.bRobot = false, false
    hero.oldState = nil
    hero.currState = "Idle"

    -- Initialize animations & effects
    hero.img = HeroAnimations:Init(hero, "hero", tileSize)
    hero.listEffect = HeroEffects:InitEffects()

    setmetatable(hero, self)
    return hero
end

-- 🏆 Load Hero at game start
function Hero:Load(pMapList)
    local MAP_WIDTH = pMapList["inGame"].img:getWidth()
    local MAP_HEIGHT = pMapList["inGame"].img:getHeight()
    Hero.hero = Hero:New(MAP_WIDTH / 2, MAP_HEIGHT)
    hero = Hero.hero
    hero.y = MAP_HEIGHT

    -- Add effects
    HeroEffects:ApplyStartupEffects(hero)
    hero.listEffect["StartGame"].bActive = true
end

-- 🏆 Main update function (Delegates to submodules)
function Hero:Update(dt, cam, pGameStart)
    -- Update physics and movement
    HeroMovement:Update(hero, dt)

    -- Update animations & effects
    HeroEffects:Update(hero, dt)
    HeroAnimations:Update(hero, dt)

    -- Handle collisions
    Hero:CheckCollisions(dt)

    -- Update laser shooting
    local nearestEnemy = Vec2:GetNearest(Enemy.list, hero)
    Hero:SetLaser(nearestEnemy, dt)
end

-- 🏆 Handles collisions (move this to a CollisionManager later)
function Hero:CheckCollisions(dt)
    -- Map Boundaries
    local Map = require("Map").current.img
    if hero.x < 0 then hero.x = Map:getWidth() - 100 end
    if hero.x > Map:getWidth() then hero.x = 10 end
    if hero.y < 0 then hero.y = Map:getHeight() - 90 end
    if hero.y > Map:getHeight() then hero.y = 10 end

    -- Asteroid Collisions
    for i, asteroid in ipairs(Asteroid.list) do
        if Vec2:IsCollide(hero, asteroid) then
            hero.vx, hero.vy = 0, 0
        end
    end

    -- Vortex Collision with Robot Sword
    for i, vortex in ipairs(Vortex.list or {}) do
        if hero.currState == "RobotSword" and Vec2:IsCollide(hero, vortex) then
            vortex.bHit = true
        end
    end
end

-- 🏆 Laser Shooting Logic
function Hero:SetLaser(target, dt)
    if not hero.bRobot and target and hero.listEffect["Shoot"].bReady then
        hero.listEffect["Shoot"].bActive = true
        Laser:New(1, hero, target)
        Sound.PlayStatic("laserShoot_" .. math.random(1, 6))
    end
end

-- 🏆 Draw function (Handles drawing animations)
function Hero:Draw()
    HeroAnimations:Draw(hero)
end

return Hero
