--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-WEATHER — Server: the calendar and the sky
     ═══════════════════════════════════════════════════════════════════════════
     One tick per game minute advances the calendar; every game hour and
     every sky change is published through GlobalState so clients and other
     resources (shops' hours, the HUD's clock, farming's seasons) read one
     truth. Staff set, freeze and forecast through core commands.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local W = LXRWeather
local RES = GetCurrentResourceName()

local cal = {}            -- { year, month, day, hour, minute }
local sky = { type = 'SUNNY', next = 'SUNNY', minutesLeft = 60 }
local frozenClock = Config.Clock.freeze
local frozenSky = Config.Weather.freeze

LXRCore.DB.RegisterMigration(RES, '0001_weather', [[
CREATE TABLE IF NOT EXISTS `lxr_weather` (
  `k` VARCHAR(16) NOT NULL,
  `v` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`k`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])

local function publishClock()
    GlobalState.hour = cal.hour
    GlobalState.minute = cal.minute
    GlobalState.calendar = { year = cal.year, month = cal.month, day = cal.day, hour = cal.hour, minute = cal.minute, season = W.Season(cal), monthName = W.Month(cal).name, night = W.IsNight(cal), frozen = frozenClock }
end
local function publishSky()
    GlobalState.weather = { type = sky.type, next = sky.next, minutesLeft = sky.minutesLeft, wind = W.Wind(sky.type), snow = W.Snow(sky.type), frozen = frozenSky, transition = Config.Weather.transitionSeconds }
end

local function save()
    if not Config.Clock.persist then return end
    LXRCore.DB.UpdateAsync('INSERT INTO lxr_weather (k, v) VALUES (?, ?), (?, ?) ON DUPLICATE KEY UPDATE v = VALUES(v)', { 'calendar', json.encode(cal), 'sky', json.encode(sky) })
end

local function load()
    local s = Config.Clock.start
    cal = { year = s.year, month = s.month, day = s.day, hour = s.hour, minute = s.minute }
    if Config.Clock.persist then
        for _, r in ipairs(LXRCore.DB.Query('SELECT k, v FROM lxr_weather') or {}) do
            local ok, v = pcall(json.decode, r.v)
            if ok and type(v) == 'table' then
                if r.k == 'calendar' and v.year then cal = v elseif r.k == 'sky' and v.type then sky = v end
            end
        end
    end
    if not W.Known(sky.type) then sky.type = 'SUNNY' end
    if not W.Known(sky.next) then sky.next = W.Next(W.Season(cal), sky.type) end
end

local function setSky(kind, reason)
    kind = W.Known(kind)
    if not kind then return false end
    sky.type = kind
    sky.next = W.Next(W.Season(cal), kind)
    sky.minutesLeft = W.HoldMinutes()
    publishSky()
    save()
    LXRCore.Emit('lxr:weather:changed', nil, kind, sky.next, reason)
    return true
end

local function setTime(h, m, reason)
    h, m = math.floor(tonumber(h) or -1), math.floor(tonumber(m) or 0)
    if h < 0 or h > 23 or m < 0 or m > 59 then return false end
    cal.hour, cal.minute = h, m
    publishClock()
    save()
    LXRCore.Emit('lxr:clock:set', nil, h, m, reason)
    return true
end

CreateThread(function()
    load()
    publishClock() publishSky()
    if Config.Debug.printBanner then print(('^1[lxr-weather]^7 v%s — %s %s, %s, sky %s → %s'):format(GetResourceMetadata(RES, 'version', 0), W.Date(cal), W.Clock(cal), W.Season(cal), sky.type, sky.next)) end
    local lastHour, sinceSave = cal.hour, 0
    while true do
        Wait(W.MsPerMinute(cal))
        if not frozenClock then
            W.Advance(cal, 1)
            if cal.hour ~= lastHour then lastHour = cal.hour LXRCore.Emit('lxr:clock:hour', nil, cal.hour, W.Season(cal)) end
            publishClock()
        end
        if Config.Weather.enabled and not frozenSky then
            sky.minutesLeft = sky.minutesLeft - 1
            if sky.minutesLeft <= 0 then setSky(sky.next, 'roll') else GlobalState.weather = GlobalState.weather end
        end
        sinceSave = sinceSave + 1
        if sinceSave >= 10 then sinceSave = 0 save() end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎛️ STAFF
-- ═══════════════════════════════════════════════════════════════════════════════
local C = Config.Security.commands
LXR.Commands.Register({ name = C.weather, help = Lang:t('command.weather'), permission = 'admin', args = { { name = 'type', help = 'SUNNY, RAIN, THUNDERSTORM, SNOW …' } },
    handler = function(src, args)
        if not setSky(args[1], 'staff') then return LXRCore.Notify(src, Lang:t('error.unknown_weather'), 'error') end
        LXRCore.Notify(src, Lang:t('info.weather_set', { type = sky.type }), 'success')
    end })
LXR.Commands.Register({ name = C.time, help = Lang:t('command.time'), permission = 'admin', args = { { name = 'hour', help = '0–23' }, { name = 'minute', help = '0–59' } },
    handler = function(src, args)
        if not setTime(args[1], args[2] or 0, 'staff') then return LXRCore.Notify(src, Lang:t('error.bad_time'), 'error') end
        LXRCore.Notify(src, Lang:t('info.time_set', { time = W.Clock(cal) }), 'success')
    end })
LXR.Commands.Register({ name = C.freezetime, help = Lang:t('command.freezetime'), permission = 'admin', args = {},
    handler = function(src) frozenClock = not frozenClock publishClock() LXRCore.Notify(src, Lang:t(frozenClock and 'info.time_frozen' or 'info.time_running'), 'inform') end })
LXR.Commands.Register({ name = C.freezeweather, help = Lang:t('command.freezeweather'), permission = 'admin', args = {},
    handler = function(src) frozenSky = not frozenSky publishSky() LXRCore.Notify(src, Lang:t(frozenSky and 'info.sky_frozen' or 'info.sky_running'), 'inform') end })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS
-- ═══════════════════════════════════════════════════════════════════════════════
exports('GetCalendar', function() return { year = cal.year, month = cal.month, day = cal.day, hour = cal.hour, minute = cal.minute, season = W.Season(cal) } end)
exports('GetWeather', function() return sky.type, sky.next, sky.minutesLeft end)
exports('SetWeather', function(kind) return setSky(kind, 'export') end)
exports('SetTime', function(h, m) return setTime(h, m, 'export') end)
exports('FreezeTime', function(on) frozenClock = on == true publishClock() end)
exports('FreezeWeather', function(on) frozenSky = on == true publishSky() end)
exports('IsNight', function() return W.IsNight(cal) end)
exports('Season', function() return W.Season(cal) end)
