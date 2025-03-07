-- HeroEffects.lua
local HeroEffects = {}

function HeroEffects:InitEffects()
    return {
        ["StartGame"] = { bActive = false },
        ["Dash"] = { bActive = false },
        ["Shoot"] = { bActive = false },
    }
end

function HeroEffects:ApplyStartupEffects(hero)
    hero.listEffect["StartGame"].bActive = true
end

function HeroEffects:Update(hero, dt)
    if hero.listEffect["Dash"].bActive then
        hero.vx = hero.vx + dt * 2
    end
end

return HeroEffects
