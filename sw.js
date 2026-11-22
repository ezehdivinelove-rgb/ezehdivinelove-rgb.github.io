/* Naira Floor offline support: opens the app without internet and shows our own message, never the web address. */
const V='nf-v1';
const OFFLINE='<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Naira Floor</title><style>:root{color-scheme:light dark}body{margin:0;min-height:100vh;display:grid;place-items:center;padding:24px;box-sizing:border-box;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:#f4f5f8;color:#1b2230;text-align:center}@media(prefers-color-scheme:dark){body{background:#12151c;color:#eef1f6}}.c{max-width:340px}.i{width:72px;height:72px;border-radius:20px;background:#2f5bd3;color:#fff;display:grid;place-items:center;font-size:34px;font-weight:800;margin:0 auto 20px}h1{font-size:22px;margin:0 0 8px}p{margin:0 0 22px;opacity:.75;line-height:1.5}button{font:inherit;font-weight:700;background:#2f5bd3;color:#fff;border:0;border-radius:14px;padding:14px 28px;width:100%}</style></head><body><div class="c"><div class="i">₦</div><h1>No internet connection</h1><p>Naira Floor needs the internet to load the market. Turn on your mobile data or Wi-Fi, then try again.</p><button onclick="location.reload()">Try again</button></div></body></html>';
self.addEventListener('install',e=>{
  e.waitUntil(caches.open(V).then(c=>Promise.all(['index.html','config.js'].map(u=>c.add(u).catch(()=>0)))).then(()=>self.skipWaiting()));
});
self.addEventListener('activate',e=>{
  e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==V).map(x=>caches.delete(x)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch',e=>{
  const r=e.request;
  if(r.method!=='GET')return;
  const u=new URL(r.url);
  if(u.origin!==location.origin)return;
  if(r.mode==='navigate'){
    e.respondWith(fetch(r).then(res=>{
      if(res.ok){const cp=res.clone();caches.open(V).then(c=>c.put('index.html',cp))}
      return res;
    }).catch(async()=>(await caches.match('index.html'))||new Response(OFFLINE,{headers:{'Content-Type':'text/html; charset=utf-8'}})));
    return;
  }
  e.respondWith(fetch(r).then(res=>{
    if(res.ok){const cp=res.clone();caches.open(V).then(c=>c.put(r,cp))}
    return res;
  }).catch(()=>caches.match(r).then(m=>m||new Response('',{status:504}))));
});