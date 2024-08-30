-- Imports
local Vec2 = require("Vector2")
local hero = require("Hero").hero

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

    local star = Vec2:New(x, y)
    local animName = "stars_" .. pStarColor
    star.vx = 0
    star.vy = 0
    star.sx = 2
    star.sy = 2
    star.bFirst = true
    -- Img Type 
    Stars.imgList[animName] = Vec2:InitAnimList(Stars.imgList, "stars", animName, 5, 5, tileSize, tileSize)
    Stars.imgList[animName] = Vec2:NewLineFrameList(Stars.imgList[animName], tileSize)

    star.img = Stars.imgList[math.random(1, 6)]
    setmetatable(star, self)
    table.insert(Stars.list, star)
end

function Stars:Load()
    -- Vec2:NewImgList(Stars, "stars/stars", 5)
    Vec2:NewTempEffect(Stars, "NewStars", 0.1, 0.1)
end

function Stars:UpdateAnimation(pVec2, dt)
    if not pVec2.currState then
        return
    end
    local currState = pVec2.img[pVec2.currState]
    if currState and currState.iFrameMax ~= nil then
        if currState.bReverse then
            currState.iFrame = currState.iFrame - (dt * currState.frameV)
            if math.floor(currState.iFrame) == 1 then
                -- currState.bFramesDone = true
                -- currState.bReverse = false
                currState.iFrame = 7
            end
        else
            currState.iFrame = currState.iFrame + (dt * currState.frameV)
            if math.floor(currState.iFrame) == currState.iFrameMax then
                currState.iFrame = 1
                currState.bReverse = true
                -- currState.bFramesDone = true
            end
        end
    end
end

function Stars:Update(dt)
    if Vec2.bStart and not Stars.bReady then
        if hero then
            -- Stars Init
            for i = 1, 6 do
                local randPos = Vec2:GetRandPosAroundPoint(hero)
                Stars:New(randPos.x, randPos.y, i)
            end
            Stars.bReady = true
        end
    end

    -- Stars.listEffect["NewStars"].bActive = true
    -- Vec2:SetTempEffects(Stars, dt)

    -- Stars Spawn

    -- Stars process
    if Stars.list then
        for i = #Stars.list, 1, -1 do
            local star = Stars.list[i]
            local randPos = Vec2:GetRandPosAroundPoint(hero)
            star.x = randPos.x
            star.y = randPos.y

            -- Star animation
            Stars:UpdateAnimation(star, dt)

            -- Delete Star
            if star.bDelete then
                table.remove(Stars.list, i)
            end
        end
    end
end

function Stars:Draw()
    if Stars.list then
        for i, star in ipairs(Stars.list) do
            local currState = star.img[star.currState]
            local starImg = currState.frames[math.floor(currState.iFrame)]
            if currState.imgSheet and starImg then
                love.graphics.draw(star.imgSheet, starImg, star.x, star.y, star.r, star.sx, star.sy, currState.w / 2,
                    currState.h / 2)
            end
        end
    end
end

return Stars
