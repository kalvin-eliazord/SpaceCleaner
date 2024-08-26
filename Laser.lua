-- Imports
local Vec2 = require("Vector2")

local Laser = {}
Laser.__index = Laser
setmetatable(Laser, {
    __index = Vec2
})

function Laser:New(pType, pSrc, pDst)
    if not Laser.list then
        Laser.list = {}
    end

    local laser = Vec2:New(pSrc.x, pSrc.y)
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
    laser.bShine = false

    if pType == 3 then
        -- Blast laser animation
        local animName = "RobotShootBlast"
        laser.img = {}
        laser.img[animName] = Vec2:NewAnimation(laser.img, "laser", animName, 4, 7, 51, 18)
        laser.img[animName] = Vec2:NewLineFrameList(laser.img[animName])
    else
        laser.img = Laser.imgList[pType]
    end

    setmetatable(laser, self)
    table.insert(Laser.list, laser)
end

function Laser.SetGuidedLaser(pLaser, dt)
    if not pLaser.target then
        return
    end
    local toTargetAng = Vec2:GetAngle(pLaser, pLaser.target)

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
    Vec2:NewImgList(Laser, "lasers/laser", 2)
end

function Laser.Update(dt)
    if Laser.list then
        for i = #Laser.list, 1, -1 do
            local laser = Laser.list[i]

            if laser.vx == 0 or laser.vy == 0 then
                laser.bDelete = true
            end

            -- Robot Blast
            if laser.type == 3 then
            end

            if Vec2:IsOutScreen(laser) then
                laser.bDelete = true
            end

            if laser.bDelete then
                table.remove(Laser.list, i)
            end
        end
    end
end

function SetColor(pVec2, dt)
    -- Enlarge
    if not pVec2.bShine then
        love.graphics.setColor(50)

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

function Laser.Draw()
    if Laser.list then
        for i, laser in ipairs(Laser.list) do
            --  love.graphics.setColor(255, 255, 0, 10)
            if laser.type == 3 then
                local laserState = laser.img["RobotShootBlast"]
                local laserImg = laserState.frames[math.floor(laserState.iFrame)]
                if laserState.imgSheet and laserImg then
                    love.graphics.draw(laserState.imgSheet, laserImg, laser.x, laser.y, math.rad(laser.r), laser.sx,
                        laser.sy, laserState.w / 2, laserState.h / 2)
                end
            else
                love.graphics.draw(laser.img, laser.x, laser.y, laser.r, laser.sx, laser.sy)
            end
            love.graphics.setColor(255, 255, 255)
        end
    end

end

return Laser
