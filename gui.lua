local playlist = {
    { name = "Cage", url = "https://raw.githubusercontent.com/everynyaan/mcmusic/main/cage.dfpwm" },
    { name = "Outer Main", url = "https://raw.githubusercontent.com/everynyaan/mcmusic/main/outermain.dfpwm" },
    { name = "Outer River", url = "https://raw.githubusercontent.com/everynyaan/mcmusic/main/outerriver.dfpwm" }
}

local shuffleEnabled = false
local repeatEnabled = false
local currentSongIndex = 0
local statusText = "Stopped"

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

drawUI()

while true do
    local event, button, x, y = os.pullEvent()
    
    if event == "mouse_click" and button == 1 then
        if y >= 3 and y <= 2 + #playlist and x >= 3 then
            currentSongIndex = y - 2
            statusText = "Selected"
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
            statusText = "Stopped"
            drawUI()
        end
    elseif event == "key" then
        break
    end
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
