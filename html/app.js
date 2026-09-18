/* LXR-WEATHER — the almanac card | © 2026 iBoss21 / LXRCore */
(function () {
  const $ = (id) => document.getElementById(id);
  const card = $('card');
  let L = {}, timer = null;
  const t = (k, vars) => { let s = L[k] || k.split('.').pop().replace(/_/g, ' '); if (vars) for (const v in vars) s = s.replace('%{' + v + '}', vars[v]); return s; };
  const pad = (n) => String(n).padStart(2, '0');
  function applyLocale() { document.querySelectorAll('[data-l]').forEach(el => { const k = 'ui.' + el.dataset.l; if (L[k]) el.textContent = L[k]; }); }
  function show(m) {
    L = m.locale || {}; document.body.classList.toggle('lang-ka', m.lang === 'ka'); applyLocale();
    const c = m.calendar || {}, w = m.weather || {};
    $('clock').textContent = pad(c.hour || 0) + ':' + pad(c.minute || 0);
    $('date').textContent = `${c.day} ${t('month.' + (c.monthName || '').toLowerCase())} ${c.year}`;
    $('season').textContent = t('season.' + (c.season || ''));
    $('sky').textContent = t('sky.' + String(w.type || '').toLowerCase());
    $('wind').textContent = t('ui.wind') + ' ' + Math.round((w.wind || 0) * 100) + '%';
    $('next').textContent = t('sky.' + String(w.next || '').toLowerCase());
    $('when').textContent = w.frozen ? t('ui.frozen') : t('ui.in_minutes', { n: w.minutesLeft || 0 });
    $('light').textContent = c.night ? t('ui.night') : t('ui.day');
    card.classList.remove('lxr-hidden');
    clearTimeout(timer); timer = setTimeout(() => card.classList.add('lxr-hidden'), m.ms || 6000);
  }
  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.brand && m.brand.theme) document.documentElement.dataset.theme = m.brand.theme;
    if (m.action === 'show') show(m);
    if (m.action === 'hide') card.classList.add('lxr-hidden');
  });
  if (window.__LXR_MOCK__) show(window.__LXR_MOCK__);
})();
