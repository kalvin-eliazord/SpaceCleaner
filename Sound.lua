local Sound = {}
Sound.list = {}

function NewSound(pName, pVolume, pType)
    local source = love.audio.newSource("music/" .. pName .. ".mp3", pType)
    if source then
        source:setVolume(pVolume)
        return source
    end
end

function SoundsInit(pScreens)
    for i, state in ipairs(pScreens) do
        local volume = 1

        if state == "menu" then
            volume = 0.4
        elseif state == "inGame" then
            volume = 6
        end

        Sound.list[state] = NewSound(state, volume, "stream")
    end

    Sound.list["curr"] = nil
end

function PlayStream(pState)
    if not Sound.list[pState]:isPlaying() then
        if Sound.list["curr"] and Sound.list["curr"]:isPlaying() then
            Sound.list["curr"]:stop()
        end

        love.audio.play(Sound.list[pState])
        Sound.list["curr"] = Sound.list[pState]
    end
end

function Sound.Load(pScreens)
    SoundsInit(pScreens)
end

function Sound.Update(pScreen)
    PlayStream(pScreen)
end

return Sound
