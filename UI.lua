-- Imports
local Vec2 = require("Vector2")
local Hero = require("Hero")
local Enemy = require("Enemy")

local UI = {}
UI.__index = UI
setmetatable(UI, {
    __index = Vec2
})

function UI:New(x, y, pImg, sx, sy)
    local ui = Vec2:New(x, y)
    ui.img = love.graphics.newImage("images/" .. pImg .. ".png")

    ui.sxMin = sx
    ui.syMin = sy
    ui.sx = ui.sxMin
    ui.sy = ui.syMin
    ui.sxMax = ui.sxMin * 2.5
    ui.syMax = ui.sxMin * 2.5

    ui.r = 0

    if pImg == "arrow" then
        if not listArrow then
            listArrow = {}
            listArrow.iLeft = 0
            listArrow.iUp = 0
            listArrow.iRight = 0
            listArrow.iDown = 0
        end
        ui.side = nil
        ui.bDelete = false
        ui.bDormant = false

        table.insert(listArrow, ui)
    end

    setmetatable(ui, self)
    return ui
end

function UI:Load()
    local myFont = love.graphics.newFont("fonts/PixelOperator8-Bold.ttf", 20)
    love.graphics.setFont(myFont)
    healthUI = UI:New(0, 0, "health", 0.1, 0.1)
end

function GetAngle(pVec1, pVec2)
    if pVec1 and pVec2 then
        return math.atan2(pVec2.y - pVec1.y, pVec2.x - pVec1.x)
    end
end

function UI:Update(dt)
  --  Vec2:SetShrink(healthUI, 0.1,dt)

    if Enemy.list then
        for i, enem in ipairs(Enemy.list) do
            -- New Arrow
            if not enem.bArrow then
                enem.bArrow = true
                enem.arrowUI = UI:New(500, 50, "arrow", 0.06, 0.06)
            else
                local hero = Hero.hero
                local deltaArrow = {}
                deltaArrow.x = hero.x - enem.x
                deltaArrow.y = hero.y - enem.y

                -- Arrow Position 
                if math.abs(deltaArrow.x) > math.abs(deltaArrow.y) then
                    if enem.x < hero.x then
                        if listArrow.iLeft > 3 then
                            enem.arrowUI.bDormant = true
                        end
                        listArrow.iLeft = listArrow.iLeft + 1
                        enem.arrowUI.side = "left"
                        enem.arrowUI.x = 10
                        enem.arrowUI.y = 350
                    else
                        if listArrow.iRight > 3 then
                            enem.arrowUI.bDormant = true
                        end
                        listArrow.iRight = listArrow.iRight + 1
                        enem.arrowUI.side = "right"
                        enem.arrowUI.x = 1000
                        enem.arrowUI.y = 200
                    end
                else
                    if enem.y < hero.y then
                        if listArrow.iUp > 3 then
                            enem.arrowUI.bDormant = true
                        end
                        listArrow.iUp = listArrow.iUp + 1
                        enem.arrowUI.side = "up"
                        enem.arrowUI.x = 350
                        enem.arrowUI.y = 20
                    else
                        if listArrow.iDown > 3 then
                            enem.arrowUI.bDormant = true
                        end
                        listArrow.iDown = listArrow.iDown + 1
                        enem.arrowUI.side = "down"
                        enem.arrowUI.x = 350
                        enem.arrowUI.y = 750
                    end
                end

                -- Arrow Rotation
                enem.arrowUI.r = GetAngle(hero, enem)

                -- Arrow Shrinking
                UI:SetShrink(enem.arrowUI, 0.5,dt)

                -- bDormant Check
                local currDist = math.sqrt(deltaArrow.x ^ 2 + deltaArrow.y ^ 2)
                -- print(currDist)
                if currDist < 500 then
                    enem.arrowUI.bDormant = true
                else
                    enem.arrowUI.bDormant = false
                end

                -- Delete Arrow
                if enem.bDelete then
                    enem.arrowUI.bDelete = true
                end

                for k = #listArrow, 1, -1 do
                    local arrow = listArrow[k]
                    if arrow.bDelete then

                        -- Arrow Side counter cleaning
                        if not arrow.bDormant then
                            if arrow.side == "up" then
                                listArrow.iUp = listArrow.iUp - 1
                            elseif arrow.side == "right" then
                                listArrow.iRight = listArrow.iRight - 1
                            elseif arrow.side == "down" then
                                listArrow.iDown = listArrow.iDown - 1
                            elseif arrow.side == "left" then
                                listArrow.iLeft = listArrow.iLeft - 1
                            end
                        end

                        table.remove(listArrow, k)
                        enem.bArrow = false
                    end
                end
            end

        end

    end

end

function UI:Draw()
    -- Health UI
    for i = 1, Hero.hero.hp do
        love.graphics.draw(healthUI.img, (i - 1) * (healthUI.img:getWidth() / 10), 0, healthUI.r, healthUI.sx,
            healthUI.sy)
    end

    -- Arrow UI
    if listArrow then
        for i, arrow in ipairs(listArrow) do
            local padding = nil
            love.graphics.setColor(1, 0, 0, 0.7)
            -- Padded drawing based on arrow Side 
            if arrow.side == "up" or arrow.side == "down" then
                padding = (i * arrow.img:getWidth() / 5)
                if padding ~= nil and not arrow.bDormant then
                    love.graphics.draw(arrow.img, arrow.x + padding, arrow.y, arrow.r, arrow.sx, arrow.sy,
                        arrow.img:getWidth() / 2, arrow.img:getHeight() / 2)
                end
            elseif arrow.side == "right" or arrow.side == "left" then
                padding = (i * arrow.img:getHeight() / 5)
                if padding ~= nil and not arrow.bDormant then
                    love.graphics.draw(arrow.img, arrow.x, arrow.y + padding, arrow.r, arrow.sx, arrow.sy,
                        arrow.img:getWidth() / 2, arrow.img:getHeight() / 2)
                end
            end
            love.graphics.setColor(255, 255, 255)

        end
    end

    -- Score UI 
    love.graphics.print("Score: "..Hero.hero.score, 430, 10)

end

return UI
