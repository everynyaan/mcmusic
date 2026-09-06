local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")

if not speaker then
    print("No speaker found.")
    return
end

local args = { ... }
local targetSong = nil
local mode = "all"

for _, arg in ipairs(args) do
    if arg == "repeat" then
        mode = "repeat"
    elseif arg == "shuffle" then
        mode = "shuffle"
    else
        targetSong = arg
    end
end

local files = fs.list(shell.dir())
local playlist = {}
for _, file in ipairs(files) do
    if file:sub(-6) == ".dfpwm" then
        table.insert(playlist, file)
    end
end

if #playlist == 0 then
    print("No .dfpwm files found. Download some with wget first.")
    return
end

math.randomseed(os.epoch("utc"))

local function playSong(filename)
    if not fs.exists(filename) then
        print("File not found: " .. filename)
        return
    end
    print("Playing: " .. filename)
    local decoder = dfpwm.make_decoder()
    for chunk in io.lines(filename, 16 * 1024) do
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

if targetSong then
    if targetSong:sub(-6) ~= ".dfpwm" then
        targetSong = targetSong .. ".dfpwm"
    end
    
    if mode == "repeat" then
        while true do
            playSong(targetSong)
        end
    else
        playSong(targetSong)
    end
else
    if mode == "shuffle" then
        while true do
            playSong(playlist[math.random(1, #playlist)])
        end
    elseif mode == "repeat" then
        while true do
            for _, song in ipairs(playlist) do
                playSong(song)
            end
        end
    else
        for _, song in ipairs(playlist) do
            playSong(song)
        end
    end
end