-- HeroMovement.lua
local HeroMovement = {}

function HeroMovement:Update(hero, dt)
    local shipAngRad = math.rad(hero.r)
    hero.vx = hero.vx + math.cos(shipAngRad) * (dt * 100)
    hero.vy = hero.vy + math.sin(shipAngRad) * (dt * 100)

    -- Apply friction
    hero.vx = hero.vx * 0.98
    hero.vy = hero.vy * 0.98

    -- Cap max speed
    if hero.vx > hero.vMax then hero.vx = hero.vMax end
    if hero.vy > hero.vMax then hero.vy = hero.vMax end

    -- Update position
    hero.x = hero.x + hero.vx * dt
    hero.y = hero.y + hero.vy * dt
end

return HeroMovement
