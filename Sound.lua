local Sound = {}
Sound.list = {}

function NewSound(pName, pVolume, pType)
    local source = love.audio.newSource("music/" .. pName .. ".mp3", pType)
    source:setVolume(pVolume)

    return source
end

function SoundsInit(pScreens)
    for i, state in ipairs (pScreens) do 
        local volume = 1

        if state == "menu" then
            volume = 0.4
        elseif state == "inGame" then
            volume = 6
        end

        Sound.list[state] = NewSound(state, volume, "stream")
    end
end

function PlayStream(pState)
    if not Sound.list[pState]:isPlaying() then
        love.audio.play(Sound.list[pState])
    end
end

function Sound.Load(pScreens)
    SoundsInit(pScreens)
end

function Sound.Update(pScreen)
    PlayStream(pScreen)
end

return Sound