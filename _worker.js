const STOCKS = (() => {
const LAGOS = new Intl.DateTimeFormat('en-GB', { timeZone: 'Africa/Lagos', hour: '2-digit', minute: '2-digit', hour12: false });
const TTL = 300;
function json(body, status = 200, extra = {}) {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json', ...extra } });
}
function pick(o, keys) {
  for (const k of keys) if (o && o[k] !== undefined && o[k] !== null && o[k] !== '') return o[k];
  return null;
}
function mapScanner(raw) {
  return ((raw && raw.data) || [])
    .map((r) => {
      const [name, close, change, logoid] = r.d || [];
      const s = String(name || (r.s || '').split(':')[1] || '').toUpperCase();
      const p = Number(close);
      const d = Number(change);
      return { s, p, d: Number.isFinite(d) ? Math.round(d * 100) / 100 : null, l: logoid || null };
    })
    .filter((x) => x.s && x.p > 0);
}
function mapMansa(raw) {
  let list = Array.isArray(raw) ? raw : raw.data;
  if (list && !Array.isArray(list)) list = list.stocks || list.items || list.results || [];
  return (list || [])
    .map((o) => {
      const s = String(pick(o, ['ticker', 'symbol', 'code']) || '').toUpperCase();
      const p = Number(pick(o, ['price', 'last_price', 'last', 'close', 'current_price']));
      const dRaw = pick(o, ['change_pct', 'change_percent', 'changePercent', 'percent_change', 'pct_change']);
      const d = dRaw === null ? null : Number(String(dRaw).replace('%', ''));
      return { s, p, d: Number.isFinite(d) ? d : null, l: null };
    })
    .filter((x) => x.s && x.p > 0);
}
async function fromTradingView() {
  const up = await fetch('https://scanner.tradingview.com/nigeria/scan', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Origin: 'https://www.tradingview.com', 'User-Agent': 'Mozilla/5.0' },
    body: JSON.stringify({
      columns: ['name', 'close', 'change', 'logoid'],
      range: [0, 400],
      markets: ['nigeria'],
      symbols: { query: { types: ['stock'] } },
      sort: { sortBy: 'name', sortOrder: 'asc' },
    }),
  });
  if (!up.ok) throw new Error('TradingView answered ' + up.status);
  return mapScanner(await up.json());
}
async function fromMansa(key) {
  const up = await fetch('https://mansaapi.com/api/v1/markets/exchanges/NGX/stocks?limit=200', {
    headers: { Authorization: 'Bearer ' + key, Accept: 'application/json' },
  });
  if (!up.ok) throw new Error('Mansa API answered ' + up.status);
  return mapMansa(await up.json());
}
async function onRequestGet({ env, request, waitUntil }) {
  const cache = caches.default;
  const cacheKey = new Request(new URL('/api/stocks', request.url).toString());
  const hit = await cache.match(cacheKey);
  if (hit) return hit;
  let stocks = [];
  const errors = [];
  try { stocks = await fromTradingView(); } catch (e) { errors.push(String(e.message || e)); }
  if (stocks.length < 20 && env.MANSA_API_KEY) {
    try { stocks = await fromMansa(env.MANSA_API_KEY); } catch (e) { errors.push(String(e.message || e)); }
  }
  if (!stocks.length) return json({ error: 'No price source answered', details: errors }, 502);
  const res = json({ time: LAGOS.format(new Date()), stocks }, 200, { 'Cache-Control': 'public, max-age=' + TTL });
  waitUntil(cache.put(cacheKey, res.clone()));
  return res;
}
return { get: onRequestGet };
})();

const ACCOUNT = (() => {
function json(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' } });
}
const PHONE = /^0\d{10}$/;
async function onRequestGet({ env, request }) {
  if (!env.ACCOUNTS) return json({ error: 'KV binding ACCOUNTS is missing' }, 500);
  const phone = new URL(request.url).searchParams.get('phone') || '';
  if (!PHONE.test(phone)) return json({ error: 'bad phone' }, 400);
  const acct = await env.ACCOUNTS.get('u:' + phone, 'json');
  return json({ acct: acct || null });
}
async function onRequestPut({ env, request }) {
  if (!env.ACCOUNTS) return json({ error: 'KV binding ACCOUNTS is missing' }, 500);
  let body;
  try { body = await request.json(); } catch (e) { return json({ error: 'bad json' }, 400); }
  const phone = String((body && body.phone) || '');
  const a = body && body.acct;
  if (!PHONE.test(phone) || !a || typeof a !== 'object' || typeof a.name !== 'string' || typeof a.cash !== 'number') {
    return json({ error: 'bad account' }, 400);
  }
  const raw = JSON.stringify(a);
  if (raw.length > 200000) return json({ error: 'too big' }, 413);
  const old = await env.ACCOUNTS.get('u:' + phone, 'json');
  if (old) {
    const used = new Set([...(old.redeemed || []), ...(a.redeemed || [])]);
    a.redeemed = [...used];
    if (old.id) a.id = old.id;
    if (typeof old.topups === 'number' && (a.topups || 0) < old.topups) return json({ acct: old, kept: true });
  }
  a.u = Date.now();
  await env.ACCOUNTS.put('u:' + phone, JSON.stringify(a));
  return json({ ok: true });
}
return { get: onRequestGet, put: onRequestPut };
})();

const USERS = (() => {
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
async function onRequestGet({ env, request }) {
  const key = new URL(request.url).searchParams.get('key') || '';
  if (!env.ADMIN_KEY || key !== env.ADMIN_KEY) return new Response('Not allowed', { status: 403 });
  if (!env.ACCOUNTS) return new Response('KV binding ACCOUNTS is missing', { status: 500 });
  const rows = [];
  let cursor;
  do {
    const page = await env.ACCOUNTS.list({ prefix: 'u:', cursor });
    for (const k of page.keys) {
      const a = await env.ACCOUNTS.get(k.name, 'json');
      if (a) rows.push({ phone: k.name.slice(2), name: a.name, id: a.id || '', cash: a.cash, since: a.since || 0, u: a.u || 0 });
    }
    cursor = page.list_complete ? undefined : page.cursor;
  } while (cursor);
  rows.sort((x, y) => y.since - x.since);
  const fmt = (t) => (t ? new Date(t).toLocaleString('en-GB', { timeZone: 'Africa/Lagos', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) : '');
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Naira Floor users</title>
<style>body{font-family:system-ui,sans-serif;margin:0;padding:16px;background:#fff;color:#1c2433}h1{font-size:22px}table{border-collapse:collapse;width:100%;font-size:14px}th,td{text-align:left;padding:8px 6px;border-bottom:1px solid #e3e7ee}th{color:#64708a;font-weight:600}@media(prefers-color-scheme:dark){body{background:#0b0f15;color:#e7ecf4}th,td{border-color:#232d3b}}</style></head>
<body><h1>${rows.length} registered users</h1><div style="overflow-x:auto"><table><tr><th>Name</th><th>Phone</th><th>ID</th><th>Cash</th><th>Joined</th></tr>${rows
    .map((r) => `<tr><td>${esc(r.name)}</td><td>${esc(r.phone)}</td><td>${esc(r.id)}</td><td>₦${Number(r.cash).toLocaleString('en-US')}</td><td>${fmt(r.since)}</td></tr>`)
    .join('')}</table></div></body></html>`;
  return new Response(html, { headers: { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' } });
}
return { get: onRequestGet };
})();

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const c = { env, request, waitUntil: (p) => ctx.waitUntil(p) };
    const m = request.method;
    if (url.pathname === '/api/stocks' && m === 'GET') return STOCKS.get(c);
    if (url.pathname === '/api/account' && m === 'GET') return ACCOUNT.get(c);
    if (url.pathname === '/api/account' && m === 'PUT') return ACCOUNT.put(c);
    if (url.pathname === '/api/users' && m === 'GET') return USERS.get(c);
    if (url.pathname.startsWith('/api/')) return new Response('Not found', { status: 404 });
    return env.ASSETS.fetch(request);
  },
};