-- Imports
local Vec2 = require("Vector2")

local Stars = {}
Stars.__index = Stars
setmetatable(Stars, {
    __index = Vec2
})

local w = 1024
local h = 768

function Stars:New()
    if not Stars.list then
        Stars.list = {}
    end

    local ast_x = math.random(0, w)
    local ast_y = math.random(0, h)
    local star = Vec2:New(ast_x, ast_y)
    star.type = math.random(1, 6)

    star.vx = 0
    star.vy = 0
    star.sx = 2
    star.sy = 2
    star.bFirst = true
    star.img = {}
    for i=1, 5 do
        star.img[i] = love.graphics.newImage("images/stars/stars_" .. star.type .. "_".. i..".png")
    end
    star.indexImg = 1
    setmetatable(star, self)
    table.insert(Stars.list, star)
end

function Stars:Load()
    maxSpawnCDR = 2
    spawnCDR = maxSpawnCDR
end

function Stars:Update(dt)
    -- Stars Spawn
    spawnCDR = spawnCDR - (10 * dt)
    if spawnCDR <= 0 then
        Stars:New()
        spawnCDR = maxSpawnCDR
    end

    if Stars.list then
        for i =#Stars.list, 1, -1 do 
            local star = Stars.list[i]
            if star.indexImg < 6 and star.bFirst then 
                star.indexImg = star.indexImg * (dt+1)
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
            love.graphics.draw(star.img[index], star.x, star.y, star.r, star.sx, star.sy, star.img[index]:getWidth() / 2,
                star.img[index]:getHeight() / 2)
        end
    end
end

return Stars
