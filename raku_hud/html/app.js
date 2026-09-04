const hud = document.getElementById('hud');

const els = {
  job: document.getElementById('job'),
  grade: document.getElementById('grade'),
  playerId: document.getElementById('playerId'),
  cash: document.getElementById('cash'),
  bank: document.getElementById('bank'),
  healthValue: document.getElementById('healthValue'),
  armorValue: document.getElementById('armorValue'),
  hungerValue: document.getElementById('hungerValue'),
  thirstValue: document.getElementById('thirstValue'),
  healthBar: document.getElementById('healthBar'),
  armorBar: document.getElementById('armorBar'),
  hungerBar: document.getElementById('hungerBar'),
  thirstBar: document.getElementById('thirstBar')
};

const formatter = new Intl.NumberFormat('de-DE');

function clamp(value) {
  value = Number(value) || 0;
  return Math.max(0, Math.min(100, Math.round(value)));
}

function money(value) {
  return '$' + formatter.format(Number(value) || 0);
}

function setStatus(name, value) {
  const v = clamp(value);
  els[name + 'Value'].textContent = `${v}%`;
  els[name + 'Bar'].style.width = `${v}%`;

  const card = document.querySelector(`[data-status="${name}"]`);
  if (!card) return;
  card.classList.toggle('warning', v <= 35);
  card.classList.toggle('critical', v <= 15);
}

window.addEventListener('message', (event) => {
  const data = event.data || {};

  if (data.action === 'visibility') {
    hud.classList.toggle('hidden', !data.visible);
    return;
  }

  if (data.action !== 'update') return;

  hud.classList.toggle('hidden', data.visible === false);

  els.job.textContent = data.job || 'Unemployed';
  els.grade.textContent = data.grade || 'Civilian';
  els.playerId.textContent = data.playerId ?? 0;
  els.cash.textContent = money(data.cash);
  els.bank.textContent = money(data.bank);

  setStatus('health', data.health);
  setStatus('armor', data.armor);
  setStatus('hunger', data.hunger);
  setStatus('thirst', data.thirst);
});
