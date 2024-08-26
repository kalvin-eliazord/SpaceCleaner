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

    -- Img Type 
    asteroid.img = Asteroid.imgList[love.math.random(1, Asteroid.imgImax)]

    setmetatable(asteroid, self)
    table.insert(Asteroid.list, asteroid)
end

function Asteroid:Load()
    Vec2:NewImgList(Asteroid, "asteroids/ast", 5)
    Vec2:NewTempEffect(Asteroid, "NewAst", 0.01, 4)
    Vec2:NewTempEffect(Asteroid, "PushAst", 5, 4)
end

function Asteroid:Update(dt)
    Vec2:SetTempEffects(Asteroid, dt)
    if Asteroid.listEffect["NewAst"].bReady then
        Asteroid.listEffect["NewAst"].bActive = true
    end
    if Asteroid.listEffect["NewAst"].bActive then
        Asteroid:New()
    end
    
    if Asteroid.list then
        for i = #Asteroid.list, 1, -1 do
            local asteroid = Asteroid.list[i]

            -- Push Asteroid Effect
            if asteroid.listEffect["PushAst"] and asteroid.listEffect["PushAst"].bActive then
            end

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

    end
end

return Asteroid