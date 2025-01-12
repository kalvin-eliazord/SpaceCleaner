io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

-- Imports file
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
local Vortex = require("Vortex")
local Cleaner = require("Cleaner")
local Stars = require("Stars")

local Game = {}

-- World data init
function GameInit()
    local game = {}

    game.screens = {}
    game.screens[1] = "title"
    game.screens[2] = "inGame"
    game.screens[3] = "menu"
    -- game.screens[3] = "gameOver" TODO
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
    cam = Camera()
    Game = GameInit()
    love.window.setTitle(Game.title)
    love.window.setMode(Game.gSizes.w, Game.gSizes.h)
    UI:Load()
    Map.Load(Game.screens)
    Explosion:Load()
    Hero:Load(Map.list)
    Sound.Load()
    Vortex:Load()
    Waste:Load()
    Laser:Load()
    Enemy:Load()
    Asteroid:Load()
    Cleaner:Load()
    Stars:Load()
end

function love.update(dt)
    if not Game.bPause then
        Sound.Update(Game.currScreen)
        Map.Update(dt)
        Waste:Update(Game, dt)
        Asteroid:Update(dt)
        Stars:Update(dt)

        if Game.currScreen == "inGame" then
            Vec2:Update(dt)
            Vortex:Update(dt)
            --  Sound.streamState = Game.currScreen
            Hero:Update(dt, cam)
            Enemy:Update(dt)
            UI:Update(dt)
            Explosion:Update(dt)
            Cleaner:Update(dt)
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
            --  Waste:Update(dt)  make it disapear in inGame? TODO ?
        end
    end
end

function love.keypressed(pKey)
    -- Fullscreen
    if pKey == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "exclusive")
    end

    -- Keys IN GAME
    if Game.currScreen == "inGame" then
        -- Pause the game
        if pKey == "p" then
            if Game.bPause == false then
                Game.bPause = true
            else
                Game.bPause = false
            end
        end

        if bGameStart then
            -- local currState = hero.img[hero.currState]

            if pKey == "r" then
                Cleaner:New(hero.x + math.random(-20, 20), hero.y + math.random(-20, 20))
            end

            -- ROBOT state
            if hero.bRobot then
                if pKey == "space" then
                    -- Fly process 
                    Hero:ActivateAnimation(hero, "RobotFly")
                elseif pKey == "a" then
                    -- Robot sword process
                    if hero.currState == "RobotSword" then
                        Sound.PlayStatic("RobotSword_" .. math.random(1, 2))
                        hero.listEffect["RobotSword2"].bActive = true
                    else
                        if hero.listEffect["RobotSword"].bReady then
                            Sound.PlayStatic("RobotSword_" .. math.random(1, 2))
                        end
                        Hero:ActivateAnimation(hero, "RobotSword")
                    end
                elseif pKey == "e" then
                    local nearest = Vec2:GetNearest(Enemy.list, hero)
                    if nearest then
                        -- Robot shoot process
                        Hero:ActivateAnimation(hero, "RobotShoot")
                        Laser:New(3, hero, nearest)
                    end
                elseif pKey == "z" then
                    if hero.currState ~= "Transform" then
                        -- Spaceship transformation process
                        if Hero:ActivateAnimation(hero, "Transform") then
                            hero.bRobot = false
                            hero.img["Transform"].iFrame = hero.img["Transform"].iFrameMax
                            hero.img[hero.currState].bReverse = true
                        end
                    end
                end
            else
                -- SPACESHIP state
                if pKey == "space" then
                    -- Dodge process
                    if Hero:ActivateAnimation(hero, "Dodge") then
                        hero.bDodge = true
                    end
                elseif pKey == "a" then
                    -- Dash process
                    Hero:ActivateAnimation(hero, "Dash")
                elseif pKey == "z" then
                    -- Robot transformation process
                    if hero.currState ~= "Transform" then
                        if Hero:ActivateAnimation(hero, "Transform") then
                            hero.bRobot = true
                        end
                    end
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
    Stars:Draw()
    Vortex:Draw()
    Asteroid:Draw()
    Waste:Draw()

    if Game.currScreen == "inGame" then
        Enemy:Draw()
        Laser.Draw()
        Explosion:Draw()
        Vec2:Draw()
        Hero:Draw()
        Cleaner:Draw()
    end

    if Game.currScreen == "inGame" then
        cam:detach()
    end

    if Game.currScreen == "inGame" then
        UI:Draw()
    end
end
