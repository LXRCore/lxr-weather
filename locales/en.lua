--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-WEATHER — Locale: English (canonical)
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale.Register('en', {
    command = { weather = 'Set the sky', time = 'Set the clock', freezetime = 'Freeze / run the clock', freezeweather = 'Freeze / run the sky' },
    error = { unknown_weather = 'No such sky.', bad_time = 'Hour 0–23, minute 0–59.' },
    info = { weather_set = 'The sky turns to %{type}.', time_set = 'The clock is set to %{time}.', time_frozen = 'The clock is frozen.', time_running = 'The clock runs.', sky_frozen = 'The sky is frozen.', sky_running = 'The sky runs.' },
    ui = { almanac = 'Almanac', sky_now = 'the sky', forecast = 'forecast', daylight = 'daylight', wind = 'wind', frozen = 'held', in_minutes = 'in %{n} min', night = 'Night', day = 'Day' },
    season = { spring = 'Spring', summer = 'Summer', autumn = 'Autumn', winter = 'Winter' },
    month = { january = 'January', february = 'February', march = 'March', april = 'April', may = 'May', june = 'June', july = 'July', august = 'August', september = 'September', october = 'October', november = 'November', december = 'December' },
    sky = {
        sunny = 'Clear', highpressure = 'Hot and clear', clouds = 'Clouds', overcast = 'Overcast', overcastdark = 'Dark overcast', misty = 'Mist', fog = 'Fog', drizzle = 'Drizzle', rain = 'Rain', shower = 'Showers',
        thunderstorm = 'Thunderstorm', thunder = 'Thunder', sleet = 'Sleet', snowlight = 'Light snow', snow = 'Snow', blizzard = 'Blizzard', whiteout = 'Whiteout', groundblizzard = 'Ground blizzard', snowclearing = 'Clearing snow', hail = 'Hail', sandstorm = 'Sandstorm',
    },
})
