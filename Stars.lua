-- Imports
local Vec2 = require("Vector2")

local Stars = {}
Stars.__index = Stars
setmetatable(Stars, {
    __index = Vec2
})
local tileSize = 16
Stars.bReady = false

function Stars:New(x, y, pStarColor)
    if not Stars.list then
        Stars.list = {}
    end

    local myStar = Vec2:New(x, y)
    local animName = "stars_" .. pStarColor
    myStar.vx = 0
    myStar.vy = 0
    myStar.sx = 2
    myStar.sy = 2
    myStar.bFirst = true
    -- Img Type 
    myStar.currState = animName
    myStar.img = {}
    myStar.img[animName] = Vec2:InitAnimList(myStar.img, "stars", animName, 7, 5, tileSize, tileSize)
    myStar.img[animName] = Vec2:NewLineFrameList(myStar.img[animName])

    setmetatable(myStar, self)
    table.insert(Stars.list, myStar)
end

function Stars:Load()
    Vec2:NewTempEffect(Stars, "NewStars", 0.1, 0.1)

    local hero = require("Hero").hero

    for i = 1, 6 do
        local randPos = {}
        randpos = Vec2:GetRandPosAroundPoint(hero)
        Stars:New(randPos.x, randPos.y, i)
    end
end

function Stars:UpdateAnimation(pVec2, dt)
    if not pVec2.currState then
        print("star curr state error")
        return
    end

    local currState = pVec2.img[pVec2.currState]
    if currState and currState.iFrameMax ~= nil then
        if currState.bReverse then
            currState.iFrame = currState.iFrame - (dt * currState.frameV)
            if math.floor(currState.iFrame) == 1 then
                currState.bFramesDone = true
                currState.bReverse = false
                -- currState.iFrame = 7
            end
        else
            currState.iFrame = currState.iFrame + (dt * currState.frameV)

            if math.floor(currState.iFrame) == currState.iFrameMax then
                --  currState.iFrame = 1
                currState.bReverse = true
                -- currState.bFramesDone = true
            end
        end
    end
end

a = 1
function Stars:Update(dt)
    local hero = require("Hero").hero

    -- Stars.listEffect["NewStars"].bActive = true
    -- Vec2:SetTempEffects(Stars, dt)

    -- Stars Spawn

    -- Stars process
    if Stars.list then
        for i = #Stars.list, 1, -1 do
            local myStar = Stars.list[i]
            local randPos = {}
            if math.floor(myStar.img[myStar.currState].iFrame) == 1 then 
          --  if myStar.img[myStar.currState].bFramesDone then
                randPos = Vec2:GetRandPosAroundPoint(hero)
                myStar.x = randPos.x 
                myStar.y = randPos.y
          end

          -- Star animation
          Stars:UpdateAnimation(myStar, dt)
          --  end
            -- Delete Star (not used)
            if myStar.bDelete then
                table.remove(Stars.list, i)
            end
        end
    end
end

function Stars:Draw()
    if Stars.list then
        for i, myStar in ipairs(Stars.list) do
            local currState = myStar.img[myStar.currState]
            local starImg = currState.frames[math.floor(currState.iFrame)]
            if currState.imgSheet and starImg then
                love.graphics.draw(currState.imgSheet, starImg, myStar.x, myStar.y, myStar.r, myStar.sx, myStar.sy,
                    currState.w / 2, currState.h / 2)
            end
        end
    end
end

return Stars
