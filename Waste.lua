-- Imports
local Vec2 = require("Vector2")
local Sound = require("Sound")

local Waste = {}
Waste.__index = Waste
setmetatable(Waste, {
    __index = Vec2
})

function Waste:New(pX, pY)
    if not Waste.list then
        Waste.list = {}
    end

    local waste = Vec2:New(pX + math.random(-10, 10), pY + math.random(-10, 10))
    waste.r = 0

    local Map = require("Map").current.img

    -- Waste direction based on coordinates
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

    
    waste.sxMax = 0.01
    waste.syMax = 0.01
    waste.sx = waste.sxMax
    waste.sy = waste.syMax
    waste.sxMin = 0.01
    waste.syMin = 0.01
    waste.vr = love.math.random(-9, 9)

    -- Type process
    local type = love.math.random(1, 9)
    waste.currState = "waste_" .. type
    waste.img = {}
    waste.img[waste.currState] = Waste.imgList[type]
    waste.dist = 150

    table.insert(Waste.list, waste)
end

function Waste:Load()
    Vec2:NewImgList(Waste, "wastes/waste", 9)
    Vec2:NewTempEffect(Waste, "NewWasteTitle", 0.01, 5)
    Vec2:NewTempEffect(Waste, "NewWasteGame", 0.1, 4)
end

function Waste:Update(pGame, dt)
    Vec2:SetTempEffects(Waste, dt)
    if pGame.currScreen == "title" then
        if Waste.listEffect["NewWasteTitle"].bReady then
            Waste.listEffect["NewWasteTitle"].bActive = true
        end
        if Waste.listEffect["NewWasteTitle"].bActive then
            local Map = require("Map").current.img
            Waste:New(math.random(10, Map:getWidth()), math.random(10, Map:getHeight()))
        end
    end

    if Waste.list then
        for i = #Waste.list, 1, -1 do
            local waste = Waste.list[i]

            Waste:SetShrink(waste, 8,dt) -- need to fix

            -- Set Velocity
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

            -- Swallow animation
            if waste.bSwallow then
                -- waste Shrinking
                waste.sx = waste.sx - (dt * 10)
                waste.sy = waste.sy - (dt * 10)
            end

            if Waste:IsOutScreen(waste) then
                waste.bDelete = true
            end

            -- Delete Waste
            if waste.bDelete then
                table.remove(Waste.list, i)
            end
        end
    end
end

function Waste.swallow(pSrc, waste, dt)
    -- Waste cleaning process
    if Vec2:IsDistInferior(pSrc, waste, waste.dist) then
        Vec2:PursueTarget(waste, pSrc, dt, 250)
        waste.bSwallow = true
        if Vec2:IsCollide(pSrc, waste) then
            --     hero.score = hero.score + 20
            Sound.PlayStatic("waste_collect_" .. math.random(1, 5))
            waste.bDelete = true
        end
    end

end

function Waste:Draw()
    if Waste.list then
        for i, waste in ipairs(Waste.list) do
            local currState = waste.img[waste.currState]
            if currState then
                love.graphics.draw(currState.img, waste.x, waste.y, waste.r, 1.5, 1.5, currState.w / 2, currState.h / 2)
            end
        end

        -- print("wasteList: ",#Waste.list)
    end
end

return Waste
