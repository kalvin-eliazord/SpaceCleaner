-- Imports
local Vec2 = require("Vector2")

local Vortex = {}
Vortex.__index = Vortex
setmetatable(Vortex, {
    __index = Vec2
})
local tileSize = 192
function Vortex:New(x, y)
    if not Vortex.list then
        Vortex.list = {}
    end

    local vortex = Vec2:New(x, y)
    local animName = "VortexIdle2"
    vortex.currState = animName
    vortex.vx = 0
    vortex.vy = 0
    vortex.sx = 0.1
    vortex.sy = 0.1
    vortex.bReady = false

    -- Vortex Idle animation
    vortex.img[animName] = Vec2:NewAnimation(vortex.img, animName, 6, 7)
    vortex.img[animName] = Vec2:NewFrameList(vortex.img[animName], tileSize)

    setmetatable(vortex, self)
    table.insert(Vortex.list, vortex)
end

function Vortex:Load()
    Vec2:NewEffect(Vortex, "NewVortex", 0.01, 20)
end

function Vortex:Update(dt)
    --    Vortex.listEffect["NewVortex"].bActive = true
    Vec2:SetTempEffects(Vortex, dt)

    -- Vortex Spawn
    if Vortex.listEffect["NewVortex"].bReady then
        Vortex.listEffect["NewVortex"].bActive = true
    end

    if Vortex.listEffect["NewVortex"].bActive then
        math.randomseed(os.time())
        local Map = require("Map").current

        local randX = math.random(20, Map.img:getWidth())
        local randY = math.random(10, Map.img:getHeight())

        local hero = require("Hero").hero
        if Map.name ~= "menu" then
            randX = hero.x + math.random(-300, 300)
            randY = hero.y + math.random(-300, 300)
            Vortex:New(randX, randY)
        end
    end

    -- Vortex process
    if Vortex.list then
        for i = #Vortex.list, 1, -1 do
            local vortex = Vortex.list[i]

            if not vortex.bReady and math.floor(vortex.sx) ~= 1 then
                vortex.sx = vortex.sx + dt
                vortex.sy = vortex.sy + dt
            else
                vortex.bReady = true
            end

            if not Vortex.listEffect["NewVortex"].bReady then
                --     vortex.bDelete = true
            end

            -- Vortex animation
            if vortex.bReady then
                Vec2:SetShrink(vortex,0.5, dt)
            end
         --   vortex.r = vortex.r + dt
            Vec2:UpdateAnimation(vortex, dt)
            local color = "green"
            local nbColor = math.random(1, 2)
            if nbColor == 1 then
                color = "blue"
            end
            Vec2:NewParticle(vortex, color, math.random(-20, 20), math.random(-20, 20), 0.01,dt)

            -- Delete Vortex
            if vortex.bDelete then
                table.remove(Vortex.list, i)
            end
        end
    end
end

function Vortex:Draw()
    if Vortex.list then
        for i, vortex in ipairs(Vortex.list) do
            local currState = vortex.img[vortex.currState]
            local vortexImg = currState.frames[math.floor(currState.iFrame)]
            if currState.imgSheet and vortexImg then
                love.graphics.draw(currState.imgSheet, vortexImg, vortex.x, vortex.y, vortex.r, vortex.sx*2, vortex.sy,
                    currState.w / 2, currState.h / 2)
            end
        end
    end
end

return Vortex