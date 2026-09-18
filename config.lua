--[[
    ██╗     ██╗  ██╗██████╗       ██╗    ██╗███████╗ █████╗ ████████╗██╗  ██╗███████╗██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║    ██║██╔════╝██╔══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
    ██║      ╚███╔╝ ██████╔╝█████╗██║ █╗ ██║█████╗  ███████║   ██║   ███████║█████╗  ██████╔╝
    ██║      ██╔██╗ ██╔══██╗╚════╝██║███╗██║██╔══╝  ██╔══██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
    ███████╗██╔╝ ██╗██║  ██║      ╚███╔███╔╝███████╗██║  ██║   ██║   ██║  ██║███████╗██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

    LXR Core - Weather

    One clock and one sky for everybody. The server keeps the calendar
    (year, month, day, hour, minute) and the weather (what it is, what comes
    next, when), publishes them through global state, and every client
    mirrors them into the game. Seasons come from the calendar; the sky
    follows a seasonal table with real transitions. Staff can set, freeze
    and forecast.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/ZHMKVYyhBa (development)
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (state bag handlers; one server tick per game minute)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE CLOCK ═════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Clock = {
    msPerMinute = 2000,          -- 2 s per game minute → a 48-minute day
    nightMsPerMinute = 1000,     -- faster nights (22:00–05:00); nil = same as the day
    start = { year = 1899, month = 5, day = 12, hour = 8, minute = 0 },
    persist = true,              -- the calendar survives restarts (lxr_weather table)
    freeze = false,
    transitionMs = 1500,         -- how long the client eases into a corrected time
}

-- game months, the season they belong to, and daylight hours (dawn, dusk)
Config.Calendar = {
    { name = 'January',   season = 'winter', dawn = 7.5, dusk = 17.0 },
    { name = 'February',  season = 'winter', dawn = 7.0, dusk = 17.5 },
    { name = 'March',     season = 'spring', dawn = 6.5, dusk = 18.0 },
    { name = 'April',     season = 'spring', dawn = 6.0, dusk = 18.5 },
    { name = 'May',       season = 'spring', dawn = 5.5, dusk = 19.0 },
    { name = 'June',      season = 'summer', dawn = 5.0, dusk = 19.5 },
    { name = 'July',      season = 'summer', dawn = 5.0, dusk = 19.5 },
    { name = 'August',    season = 'summer', dawn = 5.5, dusk = 19.0 },
    { name = 'September', season = 'autumn', dawn = 6.0, dusk = 18.5 },
    { name = 'October',   season = 'autumn', dawn = 6.5, dusk = 18.0 },
    { name = 'November',  season = 'autumn', dawn = 7.0, dusk = 17.5 },
    { name = 'December',  season = 'winter', dawn = 7.5, dusk = 17.0 },
}
Config.DaysPerMonth = 30

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE SKY ═══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
-- Weather types are the game's. Each season lists what may come with a weight; `after`
-- narrows what may follow a given type so a thunderstorm clears through rain, not to snow.
Config.Weather = {
    enabled = true,
    holdMinutes = { min = 45, max = 120 },   -- game minutes a sky lasts before the next roll
    transitionSeconds = 30,                  -- real seconds the client blends between skies
    freeze = false,
    seasons = {
        spring = { SUNNY = 30, CLOUDS = 25, OVERCAST = 15, MISTY = 8, DRIZZLE = 8, RAIN = 8, SHOWER = 4, THUNDERSTORM = 2 },
        summer = { SUNNY = 45, HIGHPRESSURE = 15, CLOUDS = 20, OVERCAST = 6, DRIZZLE = 3, RAIN = 4, THUNDERSTORM = 5, SANDSTORM = 2 },
        autumn = { SUNNY = 25, CLOUDS = 25, OVERCAST = 18, MISTY = 10, FOG = 8, RAIN = 8, DRIZZLE = 4, THUNDERSTORM = 2 },
        winter = { SUNNY = 20, CLOUDS = 20, OVERCAST = 20, FOG = 8, SNOWLIGHT = 12, SNOW = 10, SLEET = 5, BLIZZARD = 3, WHITEOUT = 2 },
    },
    after = {
        THUNDERSTORM = { 'RAIN', 'SHOWER', 'OVERCAST' }, THUNDER = { 'RAIN', 'OVERCAST' }, BLIZZARD = { 'SNOW', 'SNOWLIGHT', 'OVERCAST' }, WHITEOUT = { 'BLIZZARD', 'SNOW' },
        RAIN = { 'DRIZZLE', 'OVERCAST', 'CLOUDS', 'MISTY' }, SNOW = { 'SNOWLIGHT', 'OVERCAST', 'CLOUDS' }, FOG = { 'MISTY', 'CLOUDS', 'SUNNY' }, SANDSTORM = { 'HIGHPRESSURE', 'SUNNY' },
    },
    wind = { SUNNY = 0.1, HIGHPRESSURE = 0.05, CLOUDS = 0.25, OVERCAST = 0.35, MISTY = 0.1, FOG = 0.05, DRIZZLE = 0.3, RAIN = 0.5, SHOWER = 0.6, THUNDERSTORM = 1.0, THUNDER = 0.9, SLEET = 0.6, SNOWLIGHT = 0.3, SNOW = 0.5, BLIZZARD = 1.0, WHITEOUT = 1.0, SANDSTORM = 1.0, HAIL = 0.7, GROUNDBLIZZARD = 0.9, SNOWCLEARING = 0.2, OVERCASTDARK = 0.4 },
    snow = { SNOWLIGHT = 0.4, SNOW = 0.8, BLIZZARD = 1.0, WHITEOUT = 1.0, GROUNDBLIZZARD = 1.0, SNOWCLEARING = 0.6, SLEET = 0.2 },
    -- regions that never see snow (the desert): position-based swap on the client
    noSnowBelowY = -2400.0, noSnowSwap = { SNOWLIGHT = 'CLOUDS', SNOW = 'OVERCAST', BLIZZARD = 'SANDSTORM', WHITEOUT = 'SANDSTORM', SLEET = 'RAIN', GROUNDBLIZZARD = 'OVERCAST' },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ALMANAC (NUI) ═════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Almanac = { command = 'almanac', key = nil, showSeconds = 6000 }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Security = { adminAce = 'lxrcore.admin', commands = { weather = 'weather', time = 'time', freezetime = 'freezetime', freezeweather = 'freezeweather' } }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG ═════════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Debug = { printBanner = true, log = false }
