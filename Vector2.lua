local Vector2 = {}
Vector2.__index = Vector2

function Vector2:New(x, y)
    local vec2 = {}
    vec2.x = x
    vec2.y = x
    vec2.r = 0
    vec2.hp = 1
    vec2.vx = 0
    vec2.vy = 0
    vec2.vr = 400
    vec2.currState = "Idle"
    vec2.bDelete = false
    vec2.img = {}
    vec2.bShrink = false
    vec2.sxMax = 1.5
    vec2.syMax = 1.5
    vec2.sxMin = 1
    vec2.syMin = 1
    vec2.sx = vec2.sxMin
    vec2.sy = vec2.syMin

    setmetatable(vec2, self)
    return vec2
end

function Vector2:SetShrink(pVec2, pDtV, dt)
    -- Enlarge
    if not pVec2.bShrink then
        if pVec2.sx > pVec2.sxMax then
            pVec2.bShrink = true
        end
        pVec2.sx = pVec2.sx + (dt * pDtV)
        pVec2.sy = pVec2.sy + (dt * pDtV)
    else
        -- Shrink
        if pVec2.sx < pVec2.sxMin then
            pVec2.bShrink = false
        end
        pVec2.sx = pVec2.sx - (dt * pDtV)
        pVec2.sy = pVec2.sy - (dt * pDtV)
    end
end

function Vector2:IsCollide(pVec1, pVec2)
    if not pVec1 or not pVec2 then
        return
    end
    if pVec1 == pVec2 then
        return false
    end

    local deltaX = pVec1.x - pVec2.x
    local deltaY = pVec1.y - pVec2.y

    if math.abs(deltaX) < (pVec1.img:getWidth() + pVec2.img:getWidth()) and math.abs(deltaY) <
        (pVec1.img:getHeight() + pVec2.img:getHeight()) then
        return true
    end

    return false
end

function Vector2:NewTempEffect(pVec2, pEffect, pCurr, pCdrMax)
    if not pVec2.listEffectName then
        pVec2.listEffectName = {}
    end

    table.insert(pVec2.listEffectName, pEffect)

    if not pVec2.listEffect then
        pVec2.listEffect = {}
    end

    pVec2.listEffect[pEffect] = {}
    pVec2.listEffect[pEffect].iCurr = pCurr
    pVec2.listEffect[pEffect].iMax = pCurr
    pVec2.listEffect[pEffect].bSoundReady = true
    pVec2.listEffect[pEffect].cdrMax = pCdrMax
    pVec2.listEffect[pEffect].cdr = pCdrMax
    pVec2.listEffect[pEffect].bReady = true
end

function Vector2:SetTempEffects(pVec2, dt)
    for i, effectName in pairs(pVec2.listEffectName) do
        local effect = pVec2.listEffect[effectName]
        if effect.bActive and effect.bReady then
            effect.iCurr = effect.iCurr - dt
            if effect.iCurr <= 0 then
                effect.bActive = false
                effect.bReady = false
                effect.iCurr = effect.iMax
                effect.cdr = 0
            end
        else
            effect.bActive = false
            if math.floor(effect.cdr) ~= effect.cdrMax then
                effect.cdr = effect.cdr + dt
            else
                effect.bReady = true
                effect.bSoundReady = true
            end
        end
    end
end

function Vector2:StopEffect(pEffect)
end

function Vector2:PursueTarget(pSrc, pDst, dt, pSpeed)
    if not pSrc or not pDst then
        return
    end

    function math.angle(x1, y1, x2, y2)
        return math.atan2(y2 - y1, x2 - x1)
    end

    local toHeroAng = math.angle(pSrc.x, pSrc.y, pDst.x, pDst.y)
    -- local toHeroAng=  Vector2:GetAngle(pSrc, pDst)
    local speed = 0

    if pSpeed > 0 then
        speed = pSpeed
    else
        speed = love.math.random(50, 200)
    end

    local angX = math.cos(toHeroAng)
    local angY = math.sin(toHeroAng)

    pSrc.vx = angX * speed
    pSrc.vy = angY * speed
    pSrc.x = pSrc.x + pSrc.vx * dt
    pSrc.y = pSrc.y + pSrc.vy * dt
end

function Vector2:SetVelocity(pVec, dt)
    if not pVec then
        return
    end
    pVec.x = pVec.x + pVec.vx + dt
    pVec.y = pVec.y + pVec.vy + dt
end

function Vector2:NewParticle(pSrc, pColor, vx, vy, duration, dt)
    if pSrc == nil then
        return
    end
    if not Vector2.particleList then
        Vector2.particleList = {}
    end

    local particle = {}
    particle.x = pSrc.x + math.random(-10, 10)
    particle.y = pSrc.y + math.random(-10, 10)
    particle.w = math.random(2, 5)
    particle.h = particle.w
    particle.duration = duration
    particle.vx = vx
    particle.vy = vy
    particle.r = 0
    particle.color = pColor
    table.insert(Vector2.particleList, particle)
    return particle
end

function Vector2:Update(dt)
    if Vector2.particleList then
        for i, particle in ipairs(Vector2.particleList) do
            Vector2:SetVelocity(particle, dt)
            particle.w = particle.w - dt
            particle.h = particle.h - dt

            particle.duration = particle.duration - dt
            if particle.duration <= 0 then
                particle.bDelete = true
            end
        end

        for i = #Vector2.particleList, 1, -1 do
            local particle = Vector2.particleList[i]
            if particle.bDelete then
                table.remove(Vector2.particleList, i)
            end
        end
    end
end

function Vector2:Load()
    Vector2.bStart = false
end

function Vector2:MapCollision(pVec2, dt)
    if pVec2 == nil then
        return
    end

    local Map = require("Map").current.img
    local iMax = 15
    if pVec2.x < 0 then
        pVec2.x = Map:getWidth() - 100
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, nil, 0, math.random(-20, 20), math.random(1, 3), dt)
        end
    elseif pVec2.x > Map:getWidth() then
        pVec2.x = 10
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, nil, 0, math.random(-20, 20), math.random(1, 3), dt)
        end
    elseif pVec2.y < 0 then
        pVec2.y = Map:getHeight() - 90
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, nil, math.random(-20, 20), 0, math.random(1, 3), dt)
        end
    elseif pVec2.y > Map:getHeight() then
        pVec2.y = 10
        for i = 1, iMax do
            Vector2:NewParticle(pVec2, nil, math.random(-20, 20), 0, math.random(1, 3), dt)
        end
    end
end

function Vector2:NewAnimation(pVec2Img, pAnimName, pFrameMax, pFrameV)
    pVec2Img[pAnimName] = {}
    pVec2Img[pAnimName].iFrame = 1
    pVec2Img[pAnimName].bFramesDone = false
    pVec2Img[pAnimName].iFrameMax = pFrameMax
    pVec2Img[pAnimName].imgSheet = love.graphics.newImage("images/" .. pAnimName .. ".png")
    pVec2Img[pAnimName].frames = {}
    pVec2Img[pAnimName].frameV = pFrameV
    pVec2Img[pAnimName].bReverse = false
    return pVec2Img[pAnimName]
end

function Vector2:UpdateAnimation(pVec2, dt)
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
                -- currState.bFramesDone = true
            end
        end
    end
end

function Vector2:IsDistInferior(pVec1, pVec2, pDist)
    local dist = math.sqrt((pVec1.x - pVec2.x) ^ 2 + (pVec1.y - pVec2.y) ^ 2)
    if math.abs(dist) < pDist then
        return true
    end
    return false
end

function Vector2:GetNearest(pListDst, pSrc)
    if not pListDst or not pSrc then
        return false
    end
    local nearest = false
    local oldDist = 99999
    for i, currNearest in ipairs(pListDst) do
        if currNearest.bReady then
            local currDist = math.sqrt((pSrc.x - currNearest.x) ^ 2 + (pSrc.y - currNearest.y) ^ 2)
            -- Shoot enemy only when they are visible
            if currDist < 400 and currDist < oldDist then
                oldDist = currDist
                nearest = currNearest
            end
        end

    end

    return nearest
end

function Vector2:IsOutScreen(pVec)
    local Map = require("Map").current.img
    if pVec.x < 0 or pVec.x > Map:getWidth() or pVec.y < 0 or pVec.y > Map:getHeight() then
        return true
    end

    return false
end

function Vector2:GetAngle(pSrc, pDst)
    if pSrc and pDst then
        return math.atan2(pDst.y - pSrc.y, pDst.x - pSrc.x)
    end
end

function Vector2:NewLineFrameList(animList, tileWidth, tileHeight)
    if tileHeight == nil then
        tileHeight = tileWidth
    end
    if animList.iFrameMax == nil then
        return
    end
    local img = animList.imgSheet
    animList.w = tileWidth
    animList.h = tileHeight
    for i = 1, animList.iFrameMax do
        animList.frames[i] = love.graphics.newQuad((i - 1) * tileWidth, 0, tileWidth, tileHeight, img:getWidth(),
            img:getHeight())
    end
    return animList
end

function Vector2:NewFrameList(animList, tileWidth, tileHeight)
    if tileHeight == nil then
        tileHeight = tileWidth
    end
    if animList.iFrameMax == nil or animList.rowMax == nil then
        print("animList iFrameMax or roMax MISSING")
        return
    end

    local img = animList.imgSheet
    animList.w = tileWidth
    animList.h = tileHeight
    for j = 1, animList.rowMax do
        for i = 1, animList.iFrameMax do
            animList.frames[j][i] = love.graphics.newQuad((i - 1) * tileWidth, (j - 1) * tileHeight, tileWidth,
                tileHeight, img:getWidth(), img:getHeight())
            if j == animList.rowMax and animList.bLastRowDifferent and i == animList.iLastColMax then
                return animList
            end
        end
    end
    return animList
end

function Vector2:Draw()
    if Vector2.particleList then
        for i, particle in ipairs(Vector2.particleList) do
            if particle.color == "yellow" then
                love.graphics.setColor(1, 1, 0)
            elseif particle.color == "blue" then
                love.graphics.setColor(0, 1, 1)
            elseif particle.color == "green" then
                love.graphics.setColor(64 / 255, 30, 1)
            elseif particle.color == "red" then
                love.graphics.setColor(1, 0, 0)
            end

            love.graphics.rectangle("fill", particle.x, particle.y, particle.w, particle.h)
            love.graphics.setColor(255, 255, 255)
        end
    end
end

return Vector2
