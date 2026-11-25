--[[

   Credit: Norgumi
   GitHub: https://github.com/Norgumi

]]

------------------------------
--        AC Bypass
--   Bloxspin AC Bypass (I only tested it with Infinite Yield and certain UIs that are detected by the game)
------------------------------

for i,v in pairs(getgc(true)) do
    if typeof(v) == "function" and debug.getinfo(v).source:find("PlayerWellbeingObfuscated") then
        pcall(function()
            hookfunction(v, function(...) return task.wait(9e9) end)
        end)
    end
end

------------------------------
--        Unlock Emotes
-- Just click on the emote and it'll play for you even thoe if showed not unlocked
------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList)
local Net = require(ReplicatedStorage.Modules.Core.Net)

local xpstate = getupvalue(require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI).loaded, 10)

hookfunction(xpstate.get, function()
    return 999999
end)

local function playemote(emoteidx)
    Net.send("start_emote", emoteidx)
end

local function listall()
    local t = {}
    for i, v in pairs(EmotesList) do
        t[i] = v.name
    end
    return t
end

getgenv().playanyemote = playemote
getgenv().listemotes = listall

------------------------------
--    Unlimited Bank Tries
------------------------------

local module = require(ReplicatedStorage.Modules.Game.Minigames.SliderMinigame)
local oldset = module.tries.set

module.tries.set = newcclosure(function(...)
    local args = {...}
    args[1] = 999
    return oldset(unpack(args))
end)

------------------------------
--      Easier Hacking
-- Makes hacking bar larger
------------------------------

local rs = game:GetService("ReplicatedStorage")
local modules = rs:WaitForChild("Modules")
local atmModule = require(modules.Game.ATM.ATM)
local sliderModule = require(modules.Game.Minigames.SliderMinigame)

local oldGetUpgrades = getupvalue(atmModule.loaded, 9)

local function spoofedUpgrades(arg1, arg2)
    if arg1 == "extra_chance" then
        return 999
    elseif arg1 == "bar_percentage_increase" then
        return 1000
    else
        return oldGetUpgrades(arg1, arg2)
    end
end

for i, v in pairs(getgc()) do
    if type(v) == "function" and islclosure(v) and not iscclosure(v) then
        for j, k in pairs(debug.getupvalues(v)) do
            if type(k) == "function" and k == oldGetUpgrades then
                debug.setupvalue(v, j, spoofedUpgrades)
            end
        end
    end
end

hookfunction(oldGetUpgrades, spoofedUpgrades)

local oldHook = sliderModule.tries.hook
sliderModule.tries.hook = function(callback)
    return oldHook(function(value)
        if value < 999 then
            callback(999)
        else
            callback(value)
        end
    end)
end

local oldBarHook = sliderModule.bar_percentage_increase.hook
sliderModule.bar_percentage_increase.hook = function(callback)
    return oldBarHook(function(value)
        if value < 0.9 then
            callback(0.9)
        else
            callback(value)
        end
    end)
end

sliderModule.tries.set(999)
sliderModule.bar_percentage_increase.set(0.9)

------------------------------
--      Claim All Quests
------------------------------

local net = require(ReplicatedStorage.Modules.Core.Net)
local qdata = require(ReplicatedStorage.Modules.Game.Quests.QuestsData)

local function claimall()
    for qid, _ in pairs(qdata.list) do
        net.get("claim_quest", qid)
    end
end

getgenv().forceclaim = claimall
claimall()
