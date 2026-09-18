--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-WEATHER — Shared rules: the calendar and the sky's odds
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRWeather = LXRWeather or {}
local W = LXRWeather

---Advance a calendar table { year, month, day, hour, minute } by n minutes (in place).
function W.Advance(c, n)
    c.minute = c.minute + (n or 1)
    while c.minute >= 60 do
        c.minute = c.minute - 60
        c.hour = c.hour + 1
        if c.hour >= 24 then
            c.hour = 0
            c.day = c.day + 1
            if c.day > Config.DaysPerMonth then
                c.day = 1
                c.month = c.month + 1
                if c.month > #Config.Calendar then c.month = 1 c.year = c.year + 1 end
            end
        end
    end
    return c
end

function W.Month(c) return Config.Calendar[c.month] or Config.Calendar[1] end
function W.Season(c) return W.Month(c).season end
function W.IsNight(c) local m = W.Month(c) local h = c.hour + c.minute / 60 return h < m.dawn or h >= m.dusk end
function W.MsPerMinute(c)
    if Config.Clock.nightMsPerMinute and (c.hour >= 22 or c.hour < 5) then return Config.Clock.nightMsPerMinute end
    return Config.Clock.msPerMinute
end

---Is this a weather type the sky tables know.
function W.Known(kind)
    kind = tostring(kind or ''):upper()
    if Config.Weather.wind[kind] ~= nil then return kind end
    return nil
end

---Roll the next sky for a season, honouring what may follow the current one.
---@param rnd fun(n:number):number  (1..n) — injectable for tests
function W.Next(season, current, rnd)
    rnd = rnd or math.random
    local table_ = Config.Weather.seasons[season] or Config.Weather.seasons.spring
    local allowed = Config.Weather.after[current]
    local pool, total = {}, 0
    for kind, weight in pairs(table_) do
        local ok = true
        if allowed then
            ok = false
            for _, a in ipairs(allowed) do if a == kind then ok = true end end
        end
        if ok and weight > 0 then pool[#pool + 1] = { kind = kind, weight = weight } total = total + weight end
    end
    if #pool == 0 then
        -- the season has none of the allowed follow-ups: take the first allowed that exists at all
        for _, a in ipairs(allowed or {}) do if Config.Weather.wind[a] then return a end end
        for kind in pairs(table_) do return kind end
        return 'SUNNY'
    end
    table.sort(pool, function(a, b) return a.kind < b.kind end)
    local r = rnd(total)
    for _, p in ipairs(pool) do r = r - p.weight if r <= 0 then return p.kind end end
    return pool[#pool].kind
end

function W.HoldMinutes(rnd)
    rnd = rnd or math.random
    local h = Config.Weather.holdMinutes
    return h.min + rnd(math.max(1, h.max - h.min)) - 1
end

---What a client at `y` should render (deserts never see snow).
function W.ForPosition(kind, y)
    if Config.Weather.noSnowBelowY and y and y < Config.Weather.noSnowBelowY then return Config.Weather.noSnowSwap[kind] or kind end
    return kind
end

function W.Wind(kind) return Config.Weather.wind[kind] or 0.2 end
function W.Snow(kind) return Config.Weather.snow[kind] or 0.0 end

---Time of day label for a calendar.
function W.Clock(c) return ('%02d:%02d'):format(c.hour, c.minute) end
function W.Date(c) return ('%d %s %d'):format(c.day, W.Month(c).name, c.year) end
