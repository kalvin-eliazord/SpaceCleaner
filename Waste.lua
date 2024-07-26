local Waste = {}
local WasteImgList = {}

function Waste.New(pX, pY)
    if not Waste.list then
        Waste.list = {}
    end

    local waste = {}
    waste.x = pX + math.random(-10, 10)
    waste.y = pY + math.random(-10, 10)
    waste.r = 0

    local Map = require("Map").current.img

    if waste.x < Map:getWidth() / 2 then
        waste.vx = love.math.random(0, 200)
    else
        waste.vx = love.math.random(-200, 0)
    end

    if waste.y < Map:getHeight() / 2 then
        waste.vy = love.math.random(0, 200)
    else
        waste.vy = love.math.random(-200, 0)
    end

    waste.sx = 0.01
    waste.sy = 0.01

    local type = love.math.random(1, 14)

    if type == 1 then
        waste.dist = 90
    elseif type == 2 then
        waste.dist = 70
    elseif type == 3 then
        waste.dist = 90
    elseif type == 4 then
        waste.dist = 100
    else
        waste.dist = 150
    end

    waste.type = "asteroid"
    waste.img = WasteImgList[type]
    waste.vr = love.math.random(-9, 9)

    table.insert(Waste.list, waste)
end

function WasteInit()
    for i = 1, 14 do
        WasteImgList[i] = love.graphics.newImage("images/wastes/ast" .. i .. ".png")
    end
end

function Waste.Load()
    WasteInit()

    score = 0

    maxSpawnCDR = 0.2
    spawnCDR = maxSpawnCDR
end

function Waste.Update(dt)
    -- Set Velocity
    if Waste.list then
        for i = #Waste.list, 1, -1 do
            local waste = Waste.list[i]
            waste.x = waste.x + waste.vx * dt
            waste.y = waste.y + waste.vy * dt

            if waste.sx < 1 then
                waste.sx = waste.sx + (dt * 50)
                waste.sy = waste.sy + (dt * 50)
            end

            if waste.sx > 1.5 then
                waste.sx = waste.sx - dt
                waste.sy = waste.sy - dt
            else
                waste.sx = waste.sx + dt
                waste.sy = waste.sy + dt
            end

            waste.r = waste.r + (waste.vr * dt)
            if waste ~= nil then

                --    if Waste:IsOutScreen(waste) then TODO
                --          waste.bDelete = true
                --       end
            end

            if waste.bDelete then
                table.remove(Waste.list, i)
            end
        end
    end
end

function Waste:Draw()

    if Waste.list then
        for i, waste in ipairs(Waste.list) do
            love.graphics.draw(waste.img, waste.x, waste.y, waste.r, waste.sx, waste.sy, waste.img:getWidth() / 2,
                waste.img:getHeight() / 2)
            --      love.graphics.print("astSwallow " .. i .. " : " .. tostring(waste.bSwallow), 0, 200 + (i * 50))
        end

        -- dist = math.sqrt((waste.x - Hero.hero.x) ^ 2 + (waste.y - Hero.hero.y) ^ 2)

        -- love.graphics.print("AstDist:  " .. dist, 0, 200)

        --      love.graphics.print("Score: " .. score, w / 2, 10)

    end
end

return Waste
