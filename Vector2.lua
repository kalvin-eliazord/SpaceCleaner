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
    vec2.bShrink = false
    vec2.sxMax = 1.5
    vec2.syMax = 1.5
    vec2.sxMin = 1
    vec2.syMin = 1
    vec2.sx = vec2.sxMin
    vec2.sy = vec2.syMin
    vec2.bDelete = false
    setmetatable(vec2, self)
    return vec2
end

function Vector2:SetShrink(pVec2, dt)
    -- Enlarge
    if not pVec2.bShrink then
        if pVec2.sx > pVec2.sxMax then
            pVec2.bShrink = true
        end
        pVec2.sx = pVec2.sx + dt
        pVec2.sy = pVec2.sy + dt
    end

    -- Shrink
    if pVec2.bShrink == true then
        if pVec2.sx < pVec2.sxMin then
            pVec2.bShrink = false
        end
        pVec2.sx = pVec2.sx - dt
        pVec2.sy = pVec2.sy - dt
    end
end

function Vector2:SetImage(pFolder, pImg) -- USE THAT
    self.img = love.graphics.newImage(pFolder .. pImg)
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

    if math.abs(deltaX) < (pVec1.img:getWidth() + pVec2.img:getWidth()) - 20 and math.abs(deltaY) <
        (pVec1.img:getHeight() + pVec2.img:getHeight()) - 20 then
        return true
    end

    return false
end

function Vector2:PursueTarget(pSrc, pDst, dt, pSpeed)
    function math.angle(x1, y1, x2, y2)
        return math.atan2(y2 - y1, x2 - x1)
    end

    local dist = math.sqrt((pSrc.x - pDst.x) ^ 2 + (pSrc.y - pDst.y) ^ 2)
    local toHeroAng = math.angle(pSrc.x, pSrc.y, pDst.x, pDst.y)
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
    pVec.x = pVec.x + pVec.vx + dt
    pVec.y = pVec.y + pVec.vy + dt
end

function Vector2:Load()
    Vector2.bStart = false
end

function Vector2:IsOutScreen(pVec)
    if pVec.x < 0 or pVec.x > w or pVec.y < 0 or pVec.y > h then
        return true
    end

    return false
end

function Vector2:Destroy(pIndex)
    table.remove(self.list, pIndex)
end

return Vector2
