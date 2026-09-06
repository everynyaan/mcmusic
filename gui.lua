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
print("\n\nPress any key to exit test...")
os.pullEvent("key")
term.clear()
term.setCursorPos(1,1)
