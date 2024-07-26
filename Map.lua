-- Imports
local Stars = require("Stars")

local Map = {}
Map.list = {}
Map.current = nil

function NewMap(pName)
    local map = {}
    map.img = love.graphics.newImage("images/maps/" .. pName .. ".png")
    map.x = 0
    map.y = 0

    if pName == "title" then
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
    Map.list["press_space"] = {}
    Map.list["press_space"].img = love.graphics.newImage("images/maps/press_space.png")
    Map.current = Map.list["menu"]
    Map.current.name = "menu"
    Stars:Load()
end

function Map.Update(dt)
    Stars:Update(dt)
end

function Map.TitleUpdate(dt)
    if Map.list["title"].bShrink then
        Map.list["title"].sx = Map.list["title"].sx - dt
        Map.list["title"].sy = Map.list["title"].sy - dt

        -- Min title size
        if Map.list["title"].sx <= 1.8 then
            Map.list["title"].bShrink = false
        end
    else
        Map.list["title"].sx = Map.list["title"].sx + dt
        Map.list["title"].sy = Map.list["title"].sy + dt

        -- Max title size
        if Map.list["title"].sx >= 2 then
            Map.list["title"].bShrink = true
        end
    end
end

function Map.CameraShake(pDuration, pOffset)
    -- TODO
end

function Map.Draw(pMap)
    if pMap == "title" then
        Map.current = Map.list[pMap]
        Map.current.name = pMap

        -- Background img
        love.graphics.draw(Map.list["menu"].img, Map.list["menu"].x, Map.list["menu"].y)

        local x = love.graphics.getWidth() / 2 + 5
        local y = love.graphics.getHeight() / 2 + 10
        love.graphics.draw(Map.list["title"].img, x, y, 0, Map.list["title"].sx, Map.list["title"].sy,
            Map.list["title"].img:getWidth() / 2, Map.list["title"].img:getHeight() / 2)

        x = love.graphics.getWidth() / 2 + 5
        y = love.graphics.getHeight() / 2 + 75
        love.graphics.draw(Map.list["press_space"].img, x,
            y, 0, Map.list["press_space"].sx, Map.list["press_space"].sy,
            Map.list["press_space"].img:getWidth() / 2, Map.list["press_space"].img:getHeight() / 2)
    else
        Map.current = Map.list[pMap]
        Map.current.name = pMap
        love.graphics.draw(Map.list[pMap].img, Map.list[pMap].x, Map.list[pMap].y)
    end

    Stars:Draw()
end

return Map