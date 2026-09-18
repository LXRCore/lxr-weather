--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-WEATHER — Offline tests: calendar, seasons, sky odds, locale parity
     Requires a sibling checkout of lxr-core (../lxr-core).
     Usage (from the lxr-weather folder):  lua tests/run.lua [--mock out.js en|ka]
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE .. ' (set LXR_CORE_PATH)') os.exit(2) end
local Shim = require('tests.lib.fxshim')

Shim.load(CORE .. '/shared/main.lua')
Config = nil
Locale = nil
Shim.load('shared/locale.lua')
Shim.load('locales/en.lua')
Shim.load('locales/ka.lua')
Shim.load('config.lua')
Shim.load('shared/rules.lua')
local W = LXRWeather

local passed, failed = 0, 0
local function test(name, fn)
    local okT, err = xpcall(fn, debug.traceback)
    if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end
end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-weather offline tests')

test('the calendar rolls minutes, hours, days, months and years', function()
    local c = { year = 1899, month = 12, day = 30, hour = 23, minute = 58 }
    W.Advance(c, 3)
    eq(c.minute, 1) eq(c.hour, 0) eq(c.day, 1) eq(c.month, 1) eq(c.year, 1900)
    eq(W.Season(c), 'winter')
    eq(W.Date({ year = 1899, month = 5, day = 12 }), '12 May 1899')
    eq(W.Clock({ hour = 8, minute = 5 }), '08:05')
    eq(#Config.Calendar, 12)
end)

test('night and clock speed', function()
    assert(W.IsNight({ month = 6, hour = 22, minute = 0 }))
    assert(not W.IsNight({ month = 6, hour = 12, minute = 0 }))
    assert(W.IsNight({ month = 1, hour = 7, minute = 0 }), 'January dawn is late')
    eq(W.MsPerMinute({ hour = 23 }), Config.Clock.nightMsPerMinute or Config.Clock.msPerMinute)
    eq(W.MsPerMinute({ hour = 12 }), Config.Clock.msPerMinute)
end)

test('every sky in the seasons, the after table and the swaps is a known type with wind, and labelled', function()
    local en = Locale.Bundles.en
    local function check(kind) assert(W.Known(kind), 'unknown sky ' .. kind) assert(en['sky.' .. kind:lower()], 'no label for ' .. kind) end
    for _, tbl in pairs(Config.Weather.seasons) do for kind in pairs(tbl) do check(kind) end end
    for kind, list in pairs(Config.Weather.after) do check(kind) for _, k in ipairs(list) do check(k) end end
    for kind, to in pairs(Config.Weather.noSnowSwap) do check(kind) check(to) end
    for _, m in ipairs(Config.Calendar) do assert(en['month.' .. m.name:lower()] and en['season.' .. m.season], m.name) end
end)

test('the next sky honours what may follow; the roll is weighted and deterministic under a fixed rng', function()
    local nxt = W.Next('spring', 'THUNDERSTORM', function(n) return 1 end)
    assert(nxt == 'OVERCAST' or nxt == 'RAIN' or nxt == 'SHOWER', nxt)
    local seen = {}
    for i = 1, 200 do seen[W.Next('winter', 'SUNNY', function(n) return (i * 7919) % n + 1 end)] = true end
    assert(seen.SNOW and seen.SUNNY, 'winter rolls both snow and sun')
    assert(not seen.RAIN, 'no rain in winter')
    eq(W.Next('summer', 'WHITEOUT', function(n) return n end), 'BLIZZARD', 'falls back to an allowed follow-up the season lacks')
    local h = W.HoldMinutes(function(n) return 1 end)
    eq(h, Config.Weather.holdMinutes.min)
end)

test('the desert stays dry', function()
    eq(W.ForPosition('SNOW', -3000), 'OVERCAST')
    eq(W.ForPosition('SNOW', 500), 'SNOW')
    eq(W.ForPosition('SUNNY', -3000), 'SUNNY')
    assert(W.Wind('THUNDERSTORM') > W.Wind('SUNNY'))
    assert(W.Snow('BLIZZARD') > W.Snow('SNOWLIGHT'))
end)

test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)

print(('%d passed, %d failed'):format(passed, failed))

if arg and arg[1] == '--mock' and arg[2] then
    Config.Lang = arg[3] or 'en'
    local m = { action = 'show', ms = 999999, lang = Config.Lang, locale = Lang.bundle(), brand = { name = 'The Land of Wolves', theme = 'night' },
        calendar = { year = 1899, month = 10, day = 3, hour = 17, minute = 42, season = 'autumn', monthName = 'October', night = false, frozen = false },
        weather = { type = 'OVERCAST', next = 'RAIN', minutesLeft = 38, wind = 0.35, snow = 0, frozen = false, transition = 30 } }
    local f = assert(io.open(arg[2], 'w'))
    f:write('window.__LXR_MOCK__ = ' .. json.encode(m) .. ';\n')
    f:close()
    print('mock written to ' .. arg[2])
end
os.exit(failed == 0 and 0 or 1)
