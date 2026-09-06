local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")

if not speaker then
    print("No speaker found! Place it next to the computer.")
    return
end

local playlist = {
    { name = "Cage", url = "https://raw.githubusercontent.com/everynyaan/mcmusic/main/cage.dfpwm" },
    { name = "Outer Main", url = "https://raw.githubusercontent.com/everynyaan/mcmusic/main/outermain.dfpwm" },
    { name = "Outer River", url = "https://raw.githubusercontent.com/everynyaan/mcmusic/main/outerriver.dfpwm" }
}

local shuffleEnabled = false
local repeatEnabled = false
local currentSongIndex = 0
local statusText = "Stopped"
local isPlaying = false
local exitRequested = false

local function drawButton(x, y, text, active)
    term.setCursorPos(x, y)
    if active then
        term.setBackgroundColor(colors.lime)
        term.setTextColor(colors.black)
    else
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
    end
    term.write(" " .. text .. " ")
    term.setBackgroundColor(colors.black)
end

local function drawUI()
    term.setBackgroundColor(colors.black)
    term.clear()

    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.clearLine()
    term.write(" Music Player UI")

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    for i, track in ipairs(playlist) do
        term.setCursorPos(3, 2 + i)
        if i == currentSongIndex then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end
        term.write(i .. ". " .. track.name)
    end

    drawButton(2, 16, "Shuffle", shuffleEnabled)
    drawButton(12, 16, "Repeat", repeatEnabled)
    drawButton(43, 16, "Stop", false)

    term.setCursorPos(2, 18)
    term.setTextColor(colors.lightGray)
    term.clearLine()
    local trackName = "None"
    if currentSongIndex > 0 then trackName = playlist[currentSongIndex].name end
    term.write("Status: " .. statusText .. " | Track: " .. trackName)
end

local function musicLoop()
    while not exitRequested do
        if currentSongIndex > 0 and isPlaying then
            local activeSongIndex = currentSongIndex
            local url = playlist[activeSongIndex].url
            statusText = "Buffering..."
            drawUI()
            
            local request = http.get(url, nil, true)
            if request then
                statusText = "Playing"
                drawUI()
                local decoder = dfpwm.make_decoder()
                
                while isPlaying and activeSongIndex == currentSongIndex do
                    local chunk = request.read(16 * 1024)
                    if not chunk or chunk == "" then break end
                    
                    local buffer = decoder(chunk)
                    while not speaker.playAudio(buffer) do
                        os.pullEvent("speaker_audio_empty")
                    end
                end
                request.close()
            else
                statusText = "Net Error"
                drawUI()
                os.sleep(2)
            end
            
            if isPlaying and activeSongIndex == currentSongIndex then
                if shuffleEnabled then
                    currentSongIndex = math.random(1, #playlist)
                elseif repeatEnabled then
                    currentSongIndex = currentSongIndex + 1
                    if currentSongIndex > #playlist then currentSongIndex = 1 end
                else
                    isPlaying = false
                    currentSongIndex = 0
                    statusText = "Stopped"
                    drawUI()
                end
            end
        else
            os.pullEvent("update_music")
        end
    end
end

local function uiLoop()
    drawUI()
    while not exitRequested do
        local event, button, x, y = os.pullEvent()
        
        if event == "mouse_click" and button == 1 then
            if y >= 3 and y <= 2 + #playlist and x >= 3 then
                currentSongIndex = y - 2
                isPlaying = true
                os.queueEvent("update_music")
                drawUI()
            end
            
            if y == 16 and x >= 2 and x <= 10 then
                shuffleEnabled = not shuffleEnabled
                drawUI()
            end
            
            if y == 16 and x >= 12 and x <= 19 then
                repeatEnabled = not repeatEnabled
                drawUI()
            end
            
            if y == 16 and x >= 43 and x <= 50 then
                isPlaying = false
                currentSongIndex = 0
                statusText = "Stopped"
                drawUI()
            end
        elseif event == "key" then
            exitRequested = true
            isPlaying = false
            os.queueEvent("update_music")
        end
    end
end

parallel.waitForAny(uiLoop, musicLoop)

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
