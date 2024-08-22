-- Imports
local Vec2 = require("Vector2")

local Stars = {}
Stars.__index = Stars
setmetatable(Stars, {
    __index = Vec2
})

function Stars:New(x, y)
    if not Stars.list then
        Stars.list = {}
    end

    local star = Vec2:New(x, y)
    star.type = math.random(1, 6)
    star.vx = 0
    star.vy = 0
    star.sx = 2
    star.sy = 2
    star.bFirst = true
    star.img = {}
    for i = 1, 5 do
        star.img[i] = love.graphics.newImage("images/stars/stars_" .. star.type .. "_" .. i .. ".png")
    end
    star.indexImg = 1
    setmetatable(star, self)
    table.insert(Stars.list, star)
end

function Stars:Load()
    Vec2:NewEffect(Stars, "NewStars", 0.1, 0.1)
end

function Stars:Update(dt)
    Stars.listEffect["NewStars"].bActive = true
    Vec2:SetTempEffects(Stars, dt)

    -- Stars Spawn
    if Stars.listEffect["NewStars"].bReady then
        Stars.listEffect["NewStars"].bActive = true
    end
    if Stars.listEffect["NewStars"].bActive then
        math.randomseed(os.time())
        local Map = require("Map").current

        local randX = math.random(20, Map.img:getWidth())
        local randY = math.random(10, Map.img:getHeight())
        
        if Map.name ~= "menu" then
            local Hero = require("Hero").hero
            randX = Hero.x + math.random(-300, 300)
            randY = Hero.y + math.random(-300, 300)
        end

        Stars:New(randX, randY)
    end

    -- Stars process
    if Stars.list then
        for i = #Stars.list, 1, -1 do
            local star = Stars.list[i]

            -- Star animation
            if star.indexImg < 6 and star.bFirst then
                star.indexImg = star.indexImg * (dt + 1)
            end
            if star.indexImg >= 5 then
                star.bFirst = false
            end
            if star.bFirst == false then
                star.indexImg = star.indexImg - (dt * 10)
                if star.indexImg < 2 then
                    star.bDelete = true
                end
            end

            star.indexImg = star.indexImg + dt

            -- Delete Star
            if star.bDelete then
                table.remove(Stars.list, i)
            end
        end
    end
end

function Stars:Draw()
    if Stars.list then
        for i, star in ipairs(Stars.list) do
            local index = math.floor(star.indexImg)
            love.graphics.draw(star.img[index], star.x, star.y, star.r, star.sx, star.sy,
                star.img[index]:getWidth() / 2, star.img[index]:getHeight() / 2)
        end
    end
end

return Stars
