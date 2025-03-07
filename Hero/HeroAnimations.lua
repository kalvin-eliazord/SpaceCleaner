-- HeroAnimations.lua
local HeroAnimations = {}

function HeroAnimations:Init(hero, sprite, tileSize)
    local img = {}
    img["Idle"] = Hero:InitAnimList(img, sprite, "Idle", nil, nil, tileSize, tileSize)
    img["Dash"] = Hero:InitAnimList(img, sprite, "Dash", nil, nil, tileSize, tileSize)
    return img
end

function HeroAnimations:Update(hero, dt)
    local currState = hero.img[hero.currState]
    if currState and currState.iFrameMax then
        currState.iFrame = currState.iFrame + (dt * currState.frameV)
        if math.floor(currState.iFrame) == currState.iFrameMax then
            currState.iFrame = 1
        end
    end
end

function HeroAnimations:Draw(hero)
    local currState = hero.img[hero.currState]
    if currState and currState.imgSheet then
        love.graphics.draw(currState.imgSheet, hero.x, hero.y, math.rad(hero.r), hero.sx, hero.sy, currState.w / 2, currState.h / 2)
    end
end

return HeroAnimations
