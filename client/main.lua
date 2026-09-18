--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-WEATHER — Client: the game follows the server's calendar and sky
     ═══════════════════════════════════════════════════════════════════════════
     No loops for the sky: state bag handlers apply the clock and blend the
     weather. One slow thread keeps the desert dry (position-based swap) and
     re-asserts the override after the game tries to drift.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local W = LXRWeather
local N = Citizen.InvokeNative
local applied = nil     -- weather type currently rendered
local shown = nil

local function calendar() return GlobalState.calendar or {} end
local function weather() return GlobalState.weather or { type = 'SUNNY' } end

local function applyClock(instant)
    local c = calendar()
    if c.hour == nil then return end
    NetworkClockTimeOverride(c.hour, c.minute or 0, 0, instant and 0 or Config.Clock.transitionMs, c.frozen == true)
end

local function applySky(instant)
    local s = weather()
    local kind = W.ForPosition(s.type, GetEntityCoords(PlayerPedId()).y)
    if kind == applied and not instant then return end
    applied = kind
    SetWeatherOwnedByNetwork(false)
    SetWeatherTypeFrozen(false)
    SetWeatherType(joaat(kind), true, true, not instant, instant and 0.0 or (s.transition or Config.Weather.transitionSeconds) + 0.0, false)
    SetWeatherTypeFrozen(true)
    SetWindSpeed((s.wind or W.Wind(kind)) * 1.0)
    SetSnowLevel(W.Snow(kind))
    TriggerEvent('lxr-weather:client:changed', kind, s.next)
end

AddStateBagChangeHandler('calendar', 'global', function() applyClock(false) end)
AddStateBagChangeHandler('weather', 'global', function() applySky(false) end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(500) end
    Wait(1000)
    applyClock(true) applySky(true)
    while true do
        Wait(10000)
        if LocalPlayer.state.isLoggedIn then
            applyClock(false)
            local s = weather()
            if W.ForPosition(s.type, GetEntityCoords(PlayerPedId()).y) ~= applied then applySky(false) end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📖 THE ALMANAC
-- ═══════════════════════════════════════════════════════════════════════════════
local function almanac()
    local c, s = calendar(), weather()
    if c.hour == nil then return end
    SendNUIMessage({ action = 'show', calendar = c, weather = s, locale = Lang.bundle(), brand = LXRCore.Brand, lang = Config.Lang, ms = Config.Almanac.showSeconds })
end
RegisterCommand(Config.Almanac.command, almanac, false)
if Config.Almanac.key then RegisterKeyMapping(Config.Almanac.command, 'Almanac', 'keyboard', Config.Almanac.key) end

exports('GetCalendar', calendar)
exports('GetWeather', function() return weather().type, weather().next end)
exports('IsNight', function() return calendar().night == true end)
exports('Season', function() return calendar().season end)
exports('Almanac', almanac)
