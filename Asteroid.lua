-- Imports
local Vec2 = require("Vector2")

local Asteroid = {}
Asteroid.__index = Asteroid
setmetatable(Asteroid, {
    __index = Vec2
})

function Asteroid:New()
    if not Asteroid.list then
        Asteroid.list = {}
    end

    local Map = require("Map").current.img

    math.randomseed(os.time())
    local asteroid = Vec2:New(math.random(10, Map:getWidth()), math.random(10, Map:getHeight()))
    asteroid.r = 0

    -- asteroid direction based on coordinates
    if asteroid.x < Map:getWidth() / 2 then
        asteroid.vx = love.math.random(0, 200)
    else
        asteroid.vx = love.math.random(-200, 0)
    end

    if asteroid.y < Map:getHeight() / 2 then
        asteroid.vy = love.math.random(0, 200)
    else
        asteroid.vy = love.math.random(-200, 0)
    end

    asteroid.sxMax = 0.01
    asteroid.syMax = 0.01
    asteroid.sx = asteroid.sxMax
    asteroid.sy = asteroid.syMax
    asteroid.sxMin = 0.01
    asteroid.syMin = 0.01
    asteroid.vr = love.math.random(-9, 9)

    -- Type process
    local type = love.math.random(1, 5)
    asteroid.img = Asteroid.imgList[type]

    if type == 1 then
        Asteroid.dist = 90
    elseif type == 2 then
        asteroid.dist = 70
    elseif type == 3 then
        asteroid.dist = 90
    elseif type == 4 then
        asteroid.dist = 100
    else
        asteroid.dist = 150
    end

    setmetatable(asteroid, self)
    table.insert(Asteroid.list, asteroid)
end

function AsteroidInit()
    if not Asteroid.imgList then
        Asteroid.imgList = {}
    end

    for i = 1, 5 do
        Asteroid.imgList[i] = love.graphics.newImage("images/asteroids/ast" .. i .. ".png")
    end
end

function Asteroid:Load()
    AsteroidInit()

    maxSpawnCDR = 0.2
    spawnCDR = maxSpawnCDR
end

function Asteroid:Update(dt)
    spawnCDR = spawnCDR - dt
    if spawnCDR < 0 then
        Asteroid:New()
        spawnCDR = maxDashCDR
    end
    
    if Asteroid.list then
        for i = #Asteroid.list, 1, -1 do
            local asteroid = Asteroid.list[i]

            -- Asteroid:SetShrink(asteroid, dt)

            -- Set Velocity
            asteroid.x = asteroid.x + asteroid.vx * dt
            asteroid.y = asteroid.y + asteroid.vy * dt

            if asteroid.sx < 1 then
                asteroid.sx = asteroid.sx + (dt * 50)
                asteroid.sy = asteroid.sy + (dt * 50)
            end

            if asteroid.sx > 1.5 then
                asteroid.sx = asteroid.sx - dt
                asteroid.sy = asteroid.sy - dt
            else
                asteroid.sx = asteroid.sx + dt
                asteroid.sy = asteroid.sy + dt
            end

            asteroid.r = asteroid.r + (asteroid.vr * dt)

            if Asteroid:IsOutScreen(asteroid) then
                asteroid.bDelete = true
            end

            -- Delete Asteroid
            if asteroid.bDelete then
                table.remove(Asteroid.list, i)
            end
        end
    end
end

function Asteroid:Draw()
    if Asteroid.list then
        for i, Asteroid in ipairs(Asteroid.list) do
            love.graphics.draw(Asteroid.img, Asteroid.x, Asteroid.y, Asteroid.r, Asteroid.sx, Asteroid.sy,
                Asteroid.img:getWidth() / 2, Asteroid.img:getHeight() / 2)
        end

     --   print("ast list:", #Asteroid.list)
    end
end

return Asteroid