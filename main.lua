io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

-- Imports
local Hero = require("Hero")
local Asteroid = require("Asteroid")
local UI = require("UI")
local Waste = require("Waste")
local Laser = require("Laser")
local Vec2 = require("Vector2")
local Enemy = require("Enemy")
local Sound = require("Sound")
local Explosion = require("Explosion")
local Map = require("Map")
local Camera = require("lib/camera")

local Game = {}

function GameInit()
    local game = {}

    game.screens = {}
    game.screens[1] = "title"
    game.screens[2] = "inGame"
    game.screens[3] = "menu"
    -- game.screens[3] = "gameOver" TODO
    game.currScreen = game.screens[1]

    game.sounds = {}
    game.sounds[1] = "title"
    game.sounds[2] = "inGame"

    game.gSizes = {}
    game.gSizes.w = 1024
    game.gSizes.h = 768

    game.title = "SPACE CLEANER!"
    game.bPause = false
    game.score = 0
    return game
end

function love.load()
    cam = Camera()
    Game = GameInit()
    love.window.setTitle(Game.title)
    love.window.setMode(Game.gSizes.w, Game.gSizes.h)
    UI:Load()
    Sound.Load(Game.sounds)
    Map.Load(Game.screens)
    Hero:Load(Map.list)
    Waste:Load()
    Laser:Load()
    Enemy:Load()
    Asteroid:Load()
end

function love.update(dt)
    if not Game.bPause then
        Sound.Update(Game.currScreen)
        Map.Update(dt)
        Waste:Update(Game, dt)
        Asteroid:Update(dt)

        if Game.currScreen == "inGame" then
            Vec2:Update(dt)

            --  Sound.streamState = Game.currScreen
            Hero:Update(dt, cam)
            Enemy:Update(dt)
            UI:Update(dt)
            Explosion:Update(dt)
            cam:lookAt(Hero.hero.x, Hero.hero.y)

            -- Cam collisions
            if cam.x < Map.list[Game.currScreen].img:getWidth() / 5 then
                cam.x = Map.list[Game.currScreen].img:getWidth() / 5
            end

            if cam.x > Map.list[Game.currScreen].img:getWidth() / 1.3 then
                cam.x = Map.list[Game.currScreen].img:getWidth() / 1.3
            end

            if cam.y < Map.list[Game.currScreen].img:getHeight() / 5 then
                cam.y = Map.list[Game.currScreen].img:getHeight() / 5
            end

            if cam.y > Map.list[Game.currScreen].img:getHeight() / 1.3 then
                cam.y = Map.list[Game.currScreen].img:getHeight() / 1.3
            end

            Laser:Update(dt)
        elseif Game.currScreen == "title" then
            --  Waste:Update(dt)  make it dissapear in inGame? TODO ?
        end
    end
end

function love.keypressed(pKey)
    -- Fullscreen
    if pKey == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "exclusive")
    end

    -- IN GAME
    if Game.currScreen == "inGame" then
        -- Pause the game
        if pKey == "p" then
            if Game.bPause == false then
                Game.bPause = true
            else
                Game.bPause = false
            end
        end

        if Vec2.bStart then
            -- ROBOT state
            if hero.bRobot then
                if pKey == "space" then
                -- Dodge process ?

                elseif pKey == "a" then
                    -- Robot sword process
                    hero.oldState = hero.currState
                    hero.currState = "RobotSword"

                elseif pKey == "z" then
                    -- Spaceship transformation process
                    hero.bRobot = false
                    hero.listEffect["Transform"].bActive = true
                    hero.img["Transform"].iFrame = hero.img["Transform"].iFrameMax
                    hero.currState = "Transform"
                end
            else
            -- SPACESHIP state
                if pKey == "space" then
                    -- Dodge process
                    hero.listEffect["Dodge"].bActive = true
                    hero.bDodge = true
                    hero.oldState = hero.currState
                    hero.currState = "Dodge"
                elseif pKey == "a" then
                    -- Dash process
                    hero.listEffect["Dash"].bActive = true
                    --        Hero.hero.iDash = Hero.hero.iDash + 1 NOT USED
                    if hero.iDash >= 2 then
                        hero.iDash = 0
                        hero.bDash = true
                    end
                elseif pKey == "z" then
                    -- Robot transformation process
                    hero.bRobot = true
                    hero.listEffect["Transform"].bActive = true
                    hero.currState = "Transform"
                end
            end
        end

    else
        -- MENU

        -- Start game
        if pKey == "space" then
            Game.currScreen = "inGame"
        end
    end
end

function love.draw()
    if Game.currScreen == "inGame" then
        cam:attach()
    end

    Map.Draw(Game.currScreen)
    Asteroid:Draw()
    Waste:Draw()

    if Game.currScreen == "inGame" then
        Enemy:Draw()
        Laser.Draw()
        Explosion:Draw()
        Vec2:Draw()
        Hero:Draw()
    end

    if Game.currScreen == "inGame" then
        cam:detach()
    end

    if Game.currScreen == "inGame" then
        UI:Draw()
    end
end
