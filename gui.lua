local playlist = {}
local shuffleEnabled = false
local repeatEnabled = false
local currentSong = "None"
local statusText = "Stopped"

local files = fs.list(shell.dir())
for _, file in ipairs(files) do
    if file:sub(-6) == ".dfpwm" then
        table.insert(playlist, file)
    end
end

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
    if #playlist == 0 then
        term.setCursorPos(3, 3)
        term.write("No .dfpwm files found.")
    else
        for i = 1, math.min(#playlist, 12) do
            term.setCursorPos(3, 2 + i)
            if playlist[i] == currentSong then
                term.setTextColor(colors.yellow)
            else
                term.setTextColor(colors.white)
            end
            term.write(i .. ". " .. playlist[i])
        end
    end

    drawButton(2, 16, "Shuffle", shuffleEnabled)
    drawButton(12, 16, "Repeat", repeatEnabled)
    drawButton(43, 16, "Stop", false)

    term.setCursorPos(2, 18)
    term.setTextColor(colors.lightGray)
    term.clearLine()
    term.write("Status: " .. statusText .. " | Track: " .. currentSong)
end

drawUI()

-- Event Loop
while true do
    local event, button, x, y = os.pullEvent()
    
    if event == "mouse_click" and button == 1 then
        -- Song list clicks
        if y >= 3 and y <= 2 + math.min(#playlist, 12) and x >= 3 then
            local index = y - 2
            currentSong = playlist[index]
            statusText = "Playing"
            drawUI()
        end
        
        -- Shuffle button (X: 2-10, Y: 16)
        if y == 16 and x >= 2 and x <= 10 then
            shuffleEnabled = not shuffleEnabled
            drawUI()
        end
        
        -- Repeat button (X: 12-19, Y: 16)
        if y == 16 and x >= 12 and x <= 19 then
            repeatEnabled = not repeatEnabled
            drawUI()
        end
        
        -- Stop button (X: 43-50, Y: 16)
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
