-- Imports
local Stars = require("Stars")

local Map = {}
Map.list = {}

function NewMap(pName)
    local map = {}
    map.img = love.graphics.newImage("images/maps/" .. pName .. ".png")

    if pName == "menu" then
        map.sx = 1.5
        map.sy = 1.5
        map.bShrink = true
    else
        map.sx = 1
        map.sy = 1
    end

    return map
end

function MapsInit(pMaps)
    for i, level in ipairs(pMaps) do
        Map.list[level] = NewMap(level)
    end
end

function ChangeMap(pLvl)
    -- Transition between black screen and the new map (play w opacity ?)
end

function Map.Load(pMaps)
    MapsInit(pMaps)
    Stars:Load()
end

function Map.Update(dt)
    Stars:Update(dt)
end

function Map.TitleUpdate(dt)
    if Map.list["menu"].bShrink then
        Map.list["menu"].sx = Map.list["menu"].sx - dt
        Map.list["menu"].sy = Map.list["menu"].sy - dt

        -- Min title size
        if Map.list["menu"].sx <= 1.8 then
            Map.list["menu"].bShrink = false
        end
    else
        Map.list["menu"].sx = Map.list["menu"].sx + dt
        Map.list["menu"].sy = Map.list["menu"].sy + dt

        -- Max title size
        if Map.list["menu"].sx >= 2 then
            Map.list["menu"].bShrink = true
        end
    end
end

function Map.Draw(pMap)
    love.graphics.draw(Map.list["inGame"].img, 0, 0)
    Stars:Draw()

    if pMap == "menu" then
        love.graphics.draw(Map.list[pMap].img, love.graphics.getWidth() / 2 + 5, love.graphics.getHeight() / 2 + 100, 0,
            Map.list[pMap].sx, Map.list[pMap].sy, Map.list[pMap].img:getWidth() / 2, Map.list[pMap].img:getHeight() / 2)
    end
end

return Map
