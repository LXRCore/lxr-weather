--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-WEATHER — Locale: Georgian (ქართული)
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale.Register('ka', {
    command = { weather = 'ამინდის დაყენება', time = 'საათის დაყენება', freezetime = 'საათის გაჩერება / გაშვება', freezeweather = 'ამინდის გაჩერება / გაშვება' },
    error = { unknown_weather = 'ასეთი ამინდი არ არსებობს.', bad_time = 'საათი 0–23, წუთი 0–59.' },
    info = { weather_set = 'ამინდი იცვლება: %{type}.', time_set = 'საათი დაყენდა: %{time}.', time_frozen = 'საათი გაჩერებულია.', time_running = 'საათი მიდის.', sky_frozen = 'ამინდი გაჩერებულია.', sky_running = 'ამინდი იცვლება.' },
    ui = { almanac = 'ალმანახი', sky_now = 'ამინდი', forecast = 'პროგნოზი', daylight = 'დღის სინათლე', wind = 'ქარი', frozen = 'გაჩერებული', in_minutes = '%{n} წუთში', night = 'ღამე', day = 'დღე' },
    season = { spring = 'გაზაფხული', summer = 'ზაფხული', autumn = 'შემოდგომა', winter = 'ზამთარი' },
    month = { january = 'იანვარი', february = 'თებერვალი', march = 'მარტი', april = 'აპრილი', may = 'მაისი', june = 'ივნისი', july = 'ივლისი', august = 'აგვისტო', september = 'სექტემბერი', october = 'ოქტომბერი', november = 'ნოემბერი', december = 'დეკემბერი' },
    sky = {
        sunny = 'მოწმენდილი', highpressure = 'ცხელი და მოწმენდილი', clouds = 'ღრუბლები', overcast = 'მოღრუბლული', overcastdark = 'ბნელი მოღრუბლული', misty = 'ბურუსი', fog = 'ნისლი', drizzle = 'ჟინჟვლა', rain = 'წვიმა', shower = 'თავსხმა',
        thunderstorm = 'ჭექა-ქუხილი', thunder = 'ქუხილი', sleet = 'თოვლჭყაპი', snowlight = 'მსუბუქი თოვლი', snow = 'თოვლი', blizzard = 'ქარბუქი', whiteout = 'თეთრი წყვდიადი', groundblizzard = 'მიწისპირა ქარბუქი', snowclearing = 'თოვლი იწმინდება', hail = 'სეტყვა', sandstorm = 'ქვიშის ქარიშხალი',
    },
})
