-- Imports
local Vec2 = require("Vector2")
local Hero = require("Hero")
local Waste = require("Waste")

local Cleaner = {}
Cleaner.__index = Cleaner
setmetatable(Cleaner, {
    __index = Vec2
})
local tileSize = 32
function Cleaner:New(x, y)
    if not Cleaner.list then
        Cleaner.list = {}
    end

    local cleaner = Vec2:New(x, y)
    cleaner.x = x
    cleaner.y = y

    local animName = "Cleaner"
    cleaner.currState = animName
    cleaner.sx = 0
    cleaner.sy = 0

    -- Cleaner animation
    cleaner.img[animName] = Vec2:InitAnimList(cleaner.img, "hero", animName, nil, nil, tileSize, tileSize)

    setmetatable(cleaner, self)
    table.insert(Cleaner.list, cleaner)
end

function Cleaner:Load()
    --  Vec2:NewTempEffect(Cleaner, "Cleaner", 0.01, 20)
end

function Cleaner:Update(dt)
    -- Vec2:SetTempEffects(Cleaner, dt)

    -- Cleaner process
    if Cleaner.list then
        for i = #Cleaner.list, 1, -1 do
            local cleaner = Cleaner.list[i]
            Vec2:NewParticle(cleaner, nil, math.random(-15, 15), math.random(-15, 15), 0.002, dt)
            if not cleaner.bReady then
                if math.floor(cleaner.sx) ~= 1 then
                    cleaner.sx = cleaner.sx + dt
                    cleaner.sy = cleaner.sy + dt
                else
                    cleaner.bReady = true
                end

            else

                -- Cleaner animation
                Vec2:SetShrink(cleaner, 1, dt)

                if Waste.list then
                    for i, waste in ipairs(Waste.list) do
                        cleaner.r = Vec2:GetAngle(cleaner, waste)
                        Vec2:PursueTarget(cleaner, waste, dt, 400)
                        if Vec2:IsCollide(cleaner, waste) then
                            waste.bSwallow = true
                        end
                    end
                end

                -- Delete Cleaner
                if cleaner.bDelete then
                    table.remove(Cleaner.list, i)
                end
            end

        end
    end
end

function Cleaner:Draw()
    if Cleaner.list then
        for i, cleaner in ipairs(Cleaner.list) do
            local currState = cleaner.img[cleaner.currState]
            love.graphics.draw(currState.imgSheet, cleaner.x, cleaner.y, cleaner.r, cleaner.sx, cleaner.sy,
                currState.w / 2, currState.h / 2)
        end
    end
end

return Cleaner