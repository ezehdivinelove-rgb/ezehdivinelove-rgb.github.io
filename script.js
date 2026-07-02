const coins = [
  { id:1, name:'Bitcoin',   sym:'BTC',  price:67420, change:+2.34, cap:'$1.33T', color:'#f7931a', bg:'rgba(247,147,26,0.15)',  spark:[60,55,62,70,65,80,78] },
  { id:2, name:'Ethereum',  sym:'ETH',  price:3521,  change:+1.87, cap:'$423B',  color:'#627eea', bg:'rgba(98,126,234,0.15)',  spark:[50,55,48,60,72,68,74] },
  { id:3, name:'BNB',       sym:'BNB',  price:589,   change:-0.95, cap:'$88B',   color:'#f3ba2f', bg:'rgba(243,186,47,0.15)',  spark:[80,72,68,65,70,62,60] },
  { id:4, name:'Solana',    sym:'SOL',  price:174,   change:+5.12, cap:'$81B',   color:'#9945ff', bg:'rgba(153,69,255,0.15)',  spark:[40,48,55,50,65,70,80] },
  { id:5, name:'Cardano',   sym:'ADA',  price:0.61,  change:-1.43, cap:'$21B',   color:'#0d4ae3', bg:'rgba(13,74,227,0.15)',   spark:[70,65,60,55,58,52,50] },
  { id:6, name:'Avalanche', sym:'AVAX', price:38.5,  change:+3.21, cap:'$16B',   color:'#e84142', bg:'rgba(232,65,66,0.15)',   spark:[45,50,55,60,58,65,70] },
  { id:7, name:'Chainlink', sym:'LINK', price:18.9,  change:+0.78, cap:'$11B',   color:'#375bd2', bg:'rgba(55,91,210,0.15)',   spark:[55,58,60,57,62,65,63] },
  { id:8, name:'Polkadot',  sym:'DOT',  price:9.1,   change:-2.11, cap:'$12B',   color:'#e6007a', bg:'rgba(230,0,122,0.15)',   spark:[65,60,55,50,48,45,43] },
];

const rates   = { BTC:67420, ETH:3521, BNB:589, SOL:174, ADA:0.61 };
const fxRates = { USD:1, EUR:0.92, GBP:0.79 };

const holdings = [
  { sym:'BTC', amount:0.42, price:67420 },
  { sym:'ETH', amount:3.8,  price:3521  },
  { sym:'SOL', amount:25,   price:174   },
  { sym:'ADA', amount:1500, price:0.61  },
];

function renderTable() {
  const tbody = document.getElementById('market-tbody');
  tbody.innerHTML = coins.map(c => {
    const cls  = c.change >= 0 ? 'up' : 'down';
    const sign = c.change >= 0 ? '+' : '';
    const sparkClass = c.change >= 0 ? '' : 'neg';
    const max  = Math.max(...c.spark);
    const bars = c.spark.map(v => `<span style="height:${(v/max*100)}%"></span>`).join('');
    const priceFmt = c.price >= 1
      ? '$' + c.price.toLocaleString()
      : '$' + c.price.toFixed(4);
    return `
      <tr>
        <td style="color:var(--muted)">${c.id}</td>
        <td>
          <div class="coin-cell">
            <div class="coin-icon" style="background:${c.bg};color:${c.color}">${c.sym.slice(0,2)}</div>
            <div><div class="coin-name">${c.name}</div><div class="coin-sym">${c.sym}</div></div>
          </div>
        </td>
        <td style="font-weight:700">${priceFmt}</td>
        <td class="${cls}">${sign}${c.change}%</td>
        <td style="color:var(--muted)">${c.cap}</td>
        <td><div class="sparkline ${sparkClass}">${bars}</div></td>
      </tr>`;
  }).join('');
}

function renderTicker() {
  const items = [...coins, ...coins].map(c => {
    const cls  = c.change >= 0 ? 'up' : 'down';
    const sign = c.change >= 0 ? '+' : '';
    const p    = c.price >= 1
      ? '$' + c.price.toLocaleString()
      : '$' + c.price.toFixed(4);
    return `<span class="ticker-item">
      <span class="sym">${c.sym}</span>
      <span class="price">${p}</span>
      <span class="change ${cls}">${sign}${c.change}%</span>
    </span>`;
  }).join('');
  document.getElementById('ticker').innerHTML = items;
}

function renderPortfolio() {
  const grid = document.getElementById('portfolio-grid');
  let total = 0;
  grid.innerHTML = holdings.map(h => {
    const val = h.amount * h.price;
    total += val;
    const pct = (Math.random() * 8 - 2).toFixed(2);
    const cls  = pct >= 0 ? 'up' : 'down';
    const sign = pct >= 0 ? '+' : '';
    return `
      <div class="port-card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:0.3rem">
          <span style="font-weight:700;font-size:0.9rem">${h.sym}</span>
          <span class="pct ${cls}">${sign}${pct}%</span>
        </div>
        <div class="port-val">$${val.toLocaleString(undefined,{maximumFractionDigits:0})}</div>
        <div class="port-label">${h.amount} ${h.sym}</div>
      </div>`;
  }).join('');

  document.getElementById('total-balance').textContent =
    '$' + total.toLocaleString(undefined, { maximumFractionDigits: 0 });
  const pnl = (total * 0.023).toFixed(0);
  document.getElementById('total-pnl').textContent =
    `+$${Number(pnl).toLocaleString()} today`;

  const colors = ['#6c63ff','#00d4aa','#f7931a','#9945ff','#e84142','#f3ba2f','#627eea'];
  const days   = [72, 68, 75, 80, 77, 85, 91];
  const maxv   = Math.max(...days);
  document.getElementById('portfolio-chart').innerHTML =
    days.map((v, i) =>
      `<div class="bar" style="height:${(v/maxv*100)}%;background:${colors[i % colors.length]}"></div>`
    ).join('');
}

function convert() {
  const amount = parseFloat(document.getElementById('conv-amount').value) || 0;
  const from   = document.getElementById('conv-from').value;
  const to     = document.getElementById('conv-to').value;
  const usd    = amount * (rates[from] || 1);
  const el     = document.getElementById('conv-result');

  if (fxRates[to]) {
    const sym = to === 'USD' ? '$' : to === 'EUR' ? '€' : '£';
    const res = (usd * fxRates[to]).toLocaleString(undefined,
      { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    el.textContent = `= ${sym}${res} ${to}`;
  } else {
    const res = (usd / (rates[to] || 1)).toFixed(6);
    el.textContent = `= ${res} ${to}`;
  }
}

function fluctuatePrices() {
  coins.forEach(c => {
    const delta = (Math.random() - 0.5) * 0.004;
    c.price  = +(c.price * (1 + delta)).toFixed(c.price >= 1 ? 2 : 6);
    c.change = +(c.change + (Math.random() - 0.5) * 0.1).toFixed(2);
  });
  renderTable();
  renderTicker();
}

function openModal()  { document.getElementById('modal-overlay').classList.add('open'); }
function closeModal() { document.getElementById('modal-overlay').classList.remove('open'); }
function closeModalOutside(e) { if (e.target.id === 'modal-overlay') closeModal(); }
function fakeSignup() {
  closeModal();
  alert('Welcome to CryptoX! Your account has been created.');
}

function subscribe() {
  const v   = document.getElementById('email-input').value;
  const msg = document.getElementById('sub-msg');
  if (!v || !v.includes('@')) {
    msg.style.color = 'var(--down)';
    msg.textContent = 'Please enter a valid email.';
    return;
  }
  msg.style.color = 'var(--up)';
  msg.textContent = '✓ You\'re subscribed! Check your inbox.';
  document.getElementById('email-input').value = '';
}

renderTable();
renderTicker();
renderPortfolio();
convert();
setInterval(fluctuatePrices, 4000);