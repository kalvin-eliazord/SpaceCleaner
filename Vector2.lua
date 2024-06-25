local Vector2 = {}
Vector2.__index = Vector2

local w = 1024
local h = 768

function Vector2:New(x, y)
    local vec2 = {}
    vec2.x = x
    vec2.y = x
    vec2.r = 0
    vec2.img = nil
    vec2.hp = 1
    vec2.vx = 0
    vec2.vy = 0
    vec2.vr = 400
    vec2.bDelete = false
    setmetatable(vec2, self)
    return vec2
end

function Vector2:SetImage(pImgName)
    self.img = love.graphics.newImage("images/".. pImgName)
end

function Vector2:IsCollide(pVec1, pVec2)
    if pVec1 == nil or pVec2 == nil then
        return false
    end
    if pVec1 == pVec2 then
        return false
    end
    local deltaX = pVec1.x - pVec2.x
    local deltaY = pVec1.y - pVec2.y
    if math.abs(deltaX) < pVec1.img:getWidth() + pVec2.img:getWidth() and math.abs(deltaY) < pVec1.img:getHeight() +
        pVec2.img:getHeight() then
        return true
    end

    return false
end

function Vector2:PursueTarget(pEnemy, pHero, dt, pSpeed)
    function math.angle(x1, y1, x2, y2)
        return math.atan2(y2 - y1, x2 - x1)
    end

    local dist = math.sqrt((pEnemy.x - pHero.x) ^ 2 + (pEnemy.y - pHero.y) ^ 2)
    local toHeroAng = math.angle(pEnemy.x, pEnemy.y, pHero.x, pHero.y)

    if pSpeed > 0 then
        speed = pSpeed
    else
        speed = love.math.random(50, 200)
    end
    
    local angX = math.cos(toHeroAng)
    local angY = math.sin(toHeroAng)

    pEnemy.vx = angX * speed
    pEnemy.vy = angY * speed
    pEnemy.x = pEnemy.x + pEnemy.vx * dt
    pEnemy.y = pEnemy.y + pEnemy.vy * dt
end

function Vector2:SetVelocity(pVec, dt)
    pVec.x = pVec.x + pVec.vx
    pVec.y = pVec.y + pVec.vy
end

function Vector2:Load()
    Vector2.bStart = false
end

function Vector2:IsOutScreen(pVec)
    if pVec.x < 0 or pVec.x > w 
    or pVec.y < 0 or pVec.y > h then
        return true
    end

    return false
end

function Vector2:Destroy(pIndex)
    table.remove(self.list, pIndex)
end

return Vector2