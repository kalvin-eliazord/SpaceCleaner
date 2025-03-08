-- enemysEffects.lua
local EnemyEffects = {}

function enemysEffects:InitEffects()
    return {
        ["Dash"] = { bActive = false },
        ["Shoot"] = { bActive = false },
    }
end

function enemysEffects:ApplyStartupEffects(enemies)
    enemies.listEffect["StartGame"].bActive = true
end

function enemysEffects:Update(enemies, dt)
    if enemies.listEffect["Dash"].bActive then
        enemies.vx = enemies.vx + dt * 2
    end
end

return enemysEffects
