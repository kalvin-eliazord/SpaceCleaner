io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

local Hero = require("Hero")
local Health = require("Health")
local Waste = require("Waste")
local Laser = require("Laser")
local Vec2 = require("Vector2")
local Enemy = require("Enemy")
local Sound = require("Sound")
local Map = require("Map")


local Game = {}

function GameInit()
    local game = {}

    game.screens = {}
    game.screens[1] = "menu"
    game.screens[2] = "inGame"
    --game.screens[3] = "gameOver" TODO
    game.currScreen = game.screens[1]

    game.gSizes = {}
    game.gSizes.w = 1024
    game.gSizes.h = 768

    game.title = "SPACE CLEANER!"
    game.bPause = false
    game.score = 0
    return game
end

function love.load()
    Game = GameInit()
    love.window.setTitle(Game.title)
    love.window.setMode(Game.gSizes.w, Game.gSizes.h)
    Sound.Load(Game.screens)
    Map.Load(Game.screens)
    
    Hero:Load(Game.gSizes)
    Waste:Load()
    Laser:Load()
    Enemy:Load()
end

function love.update(dt)
--    if not Game.bPause then
    Sound.Update(Game.currScreen)
    Map.Update(dt)
    Waste:Update(dt)

    if Game.currScreen == "inGame" then
            Sound.streamState = Game.currScreen
            Hero:Update(dt)
            Laser:Update(dt)

            if Vec2.bStart then
                Waste:Update(dt)
                Enemy:Update(dt)
            end

            
    elseif Game.currScreen == "menu" then
        Map.TitleUpdate(dt)
      --  Waste:Update(dt)  make it dissapear in inGame? TODO ?
    end
-- end
end

function love.keypressed(pKey)
    -- Fullscreen
    if pKey == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "exclusive")
    end

    if Game.currScreen == "inGame" then
        -- Pause the game
        if pKey == "p" then
            if Game.bPause == false then
                Game.bPause = true
            else
                Game.bPause = false
            end
        end

        if pKey == "space" then
            Hero.hero.iDash = Hero.hero.iDash + 1

            if Hero.hero.iDash >= 2 then
                Hero.hero.iDash = 0
                Hero.hero.bDash = true
            end
        end
    else
        if pKey == "space" then
            Game.currScreen = "inGame"
        end
    end
end

function love.draw()
    Map.Draw(Game.currScreen)
    Waste:Draw()
    if Game.currScreen == "inGame" then
        Hero:Draw()
    end

    Laser:Draw()
    Enemy:Draw()

end
