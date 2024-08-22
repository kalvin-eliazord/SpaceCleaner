-- Imports
local Vec2 = require("Vector2")
local Stars = require("Stars")

local Map = {}
Map.__index = Map
setmetatable(Map, {
    __index = Vec2
})
Map.list = {}
Map.current = nil

function Map:New(pName)
    local map = Vec2:New(0, 0)
    map.img = love.graphics.newImage("images/maps/" .. pName .. ".png")

    if pName == "title" then
        map.sxMin = 2
        map.syMin = 2
        map.sxMax = 2.2
        map.syMax = 2.2
        map.sx = 1.5
        map.sy = 1.5
        map.bShrink = true
    else
        map.sx = 1
        map.sy = 1
    end

    setmetatable(map, self)
    return map
end

function InitMapList(pMaps)
    for i, level in ipairs(pMaps) do
        Map.list[level] = Map:New(level)
    end
end

function ChangeMap(pLvl)
    -- Transition between black screen and the new map (play w opacity ?)
end

function Map.Load(pMaps)
    InitMapList(pMaps)
    Map.list["press_space"] = {}
    Map.list["press_space"].img = love.graphics.newImage("images/maps/press_space.png")
    Map.current = Map.list["menu"]
    Map.current.name = "menu"
    Stars:Load()
end

function Map.Update(dt)
    Stars:Update(dt)
    Map:SetShrink(Map.list["title"],1, dt)
   -- Map:SetShrink(Map.list["press_space"], dt) TODO
end

function Map.Draw(pMap)
    if pMap == "title" then
        Map.current = Map.list["menu"]
        Map.current.name = "menu"

        -- Space Background img
        love.graphics.draw(Map.list["menu"].img, Map.list["menu"].x, Map.list["menu"].y)

        -- "SpaceCleaner!" img
        local x = love.graphics.getWidth() / 2 + 5
        local y = love.graphics.getHeight() / 2 + 20
        love.graphics.draw(Map.list["title"].img, x, y, 0, Map.list["title"].sx, Map.list["title"].sy,
            Map.list["title"].img:getWidth() / 2, Map.list["title"].img:getHeight() / 2)


        -- Press space img
        x = love.graphics.getWidth() / 2 + 5
        y = love.graphics.getHeight() / 2 + 120
        love.graphics.draw(Map.list["press_space"].img, x, y, 0, Map.list["press_space"].sx, Map.list["press_space"].sy,
            Map.list["press_space"].img:getWidth() / 2, Map.list["press_space"].img:getHeight() / 2)
    else
        Map.current = Map.list[pMap]
        Map.current.name = pMap
        love.graphics.draw(Map.list[pMap].img, Map.list[pMap].x, Map.list[pMap].y)
    end

    Stars:Draw()
end

return Map