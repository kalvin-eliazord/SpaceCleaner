local Laser = {}

function GetAngle(pVec1, pVec2)
    if pVec1 and pVec2 then
        return math.atan2(pVec2.y - pVec1.y, pVec2.x - pVec1.x)
    end
end

function Laser.New(pType, pSrc, pDst)
    if not Laser.list then
        Laser.list = {}
    end

    local laser = {}
    laser.x = pSrc.x
    laser.y = pSrc.y

    laser.r = pSrc.r
    laser.sx = 1
    laser.sy = 1
    laser.vx = 0
    laser.vy = 0
    laser.target = pDst
    laser.type = pType
    laser.bDist = false

    laser.img = love.graphics.newImage("images/lasers/laser" .. pType .. ".png")
    table.insert(Laser.list, laser)
end

function Laser.SetGuidedLaser(pLaser, dt)
    --  if not pLaser.target then return end
    -- local dist = math.sqrt((pLaser.x - pLaser.target.x) ^ 2 + (pLaser.y - pLaser.target.y) ^ 2)
    local toTargetAng = GetAngle(pLaser, pLaser.target)

    local heroSpeed = 400
    local angX = math.cos(toTargetAng)
    local angY = math.sin(toTargetAng)

    pLaser.vx = angX * heroSpeed * dt
    pLaser.vy = angY * heroSpeed * dt
    pLaser.x = pLaser.x + pLaser.vx
    pLaser.y = pLaser.y + pLaser.vy
end

function Laser.SetLaser(pLaser, dt)
    if not pLaser.target then
        return
    end
    local currDist = math.sqrt((pLaser.x - pLaser.target.x) ^ 2 + (pLaser.y - pLaser.target.y) ^ 2)
    local heroSpeed = 400

    if currDist > 200 and not pLaser.bDist then
        local toTargetAng = GetAngle(pLaser, pLaser.target)
        local angX = math.cos(toTargetAng)
        local angY = math.sin(toTargetAng)
        pLaser.vx = angX * heroSpeed
        pLaser.vy = angY * heroSpeed
    else
        pLaser.bDist = true
    end

    pLaser.x = pLaser.x + pLaser.vx * dt
    pLaser.y = pLaser.y + pLaser.vy * dt
end

function Laser.Load()
    maxSpawnCDR = 3
    heroSpawnCDR = maxSpawnCDR
    enemSpawnCDR = maxSpawnCDR
end

function OnScreen(pNearest)
    if not pNearest then
        return false
    end
    if pNearest.x >= 0 and pNearest.x <= w and pNearest.y >= 0 and pNearest.y <= h then
        return true
    end
    return false
end

function table.clear(t)
    for i = #t, 1, -1 do
        table.remove(t, i)
    end
end

function Laser.Update(dt)
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]

            if laser.vx == 0 or laser.vy == 0 then
                laser.bDelete = true
            end
            
            if laser.bDelete then
                table.remove(Laser.list, i)
            end
        end
    end
end

function Laser.Draw()
    if Laser.list then
        for i, laser in ipairs(Laser.list) do
            love.graphics.draw(laser.img, laser.x, laser.y, laser.r, laser.sx, laser.sy)
        end
    end

end

return Laser
