local Sound = {}
Sound.staticList = {}
Sound.streamList = {}
Sound.oldStream = nil
Sound.currStream = nil
Sound.heroOldSound = nil
Sound.heroOldSound = nil

function InitSounds(pSoundList)
    for i, sound in pairs(pSoundList) do
        print("[-] Error: Sound " .. sound.name .. " doesn't exist.")
    end
end

function NewSound(pName, pVolume, pType)
    if pType == "stream" then
        Sound.streamList[pName] = {}
        Sound.streamList[pName].name = pName
        Sound.streamList[pName].source = love.audio.newSource("sounds/" .. pName .. ".mp3", pType)
        Sound.streamList[pName].volume = pVolume
    else
        Sound.staticList[pName] = {}
        Sound.staticList[pName].name = pName
        Sound.staticList[pName].source = love.audio.newSource("sounds/" .. pName .. ".mp3", pType)
        Sound.staticList[pName].volume = pVolume
    end
end

function PlayStream(pStreamChanged)
    local currStream = Sound.streamList[Sound.currStream]

    if Sound.currStream and currStream then
        local currStream = Sound.streamList[Sound.currStream]
        local oldStream = Sound.streamList[Sound.oldStream]

        if Sound.oldStream and pStreamChanged then
            if oldStream.source:isPlaying() then
                oldStream.source:stop()
            end
            love.audio.play(currStream.source)
            currStream.source:setVolume(currStream.volume)
        else
            love.audio.play(currStream.source)
            currStream.source:setVolume(currStream.volume)
        end
    end
end

function Sound.PlayStatic(pStatic)
    local currStatic = Sound.staticList[pStatic]
    if currStatic.source then
        love.audio.play(currStatic.source)
        currStatic.source:setVolume(currStatic.volume)
    end
end

function Sound.StopStatic(pStatic)
    local currStatic = Sound.staticList[pStatic]
    if currStatic and currStatic.source:isPlaying() then
        currStatic.source:stop()
        return true
    end
    return false
end

function Sound.Load()
    NewSound("title", 0.4, "stream")
    NewSound("inGame", 6, "stream")
    for i=1, 6 do
        NewSound("laserShoot_"..i, 1, "static")
    end
    for i=1, 2 do
        NewSound("explosion_"..i, 1, "static")
    end
    NewSound("ship_start", 0.5, "static")
    Sound.bStreamChanged = false
    -- InitSounds(pScreens)
end

function Sound.Update(pCurrScreen)
    if pCurrScreen ~= Sound.currStream then
        Sound.oldStream = Sound.currStream
        Sound.currStream = pCurrScreen
        Sound.bStreamChanged = true
    end

    PlayStream(Sound.bStreamChanged)
end

return Sound