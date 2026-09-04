const hud = document.getElementById('hud');
const formatter = new Intl.NumberFormat('de-DE');

const els = {
  job: document.getElementById('job'),
  grade: document.getElementById('grade'),
  playerId: document.getElementById('playerId'),
  cash: document.getElementById('cash'),
  bank: document.getElementById('bank'),
  voiceChip: document.getElementById('voiceChip'),
  voiceLabel: document.getElementById('voiceLabel'),
  oxygenStat: document.getElementById('oxygenStat'),
  stressStat: document.getElementById('stressStat'),
  vehiclePanel: document.getElementById('vehiclePanel'),
  speed: document.getElementById('speed'),
  vehicleHealthBar: document.getElementById('vehicleHealthBar'),
  vehicleHealthValue: document.getElementById('vehicleHealthValue')
};

const statusNames = ['health', 'armor', 'stamina', 'hunger', 'thirst', 'oxygen', 'stress'];
for (const name of statusNames) {
  els[name + 'Value'] = document.getElementById(name + 'Value');
}

function clamp(value) {
  value = Number(value) || 0;
  return Math.max(0, Math.min(100, Math.round(value)));
}

function money(value) {
  return '$' + formatter.format(Number(value) || 0);
}

function setStatus(name, value, inverseWarnings = false) {
  const v = clamp(value);
  const card = document.querySelector(`[data-status="${name}"]`);
  if (!card) return;

  if (els[name + 'Value']) els[name + 'Value'].textContent = String(v);
  card.style.setProperty('--value', v);

  const warning = inverseWarnings ? v >= 65 : v <= 35;
  const critical = inverseWarnings ? v >= 85 : v <= 15;
  card.classList.toggle('warning', warning);
  card.classList.toggle('critical', critical);
}

window.addEventListener('message', (event) => {
  const data = event.data || {};

  if (data.action === 'visibility') {
    hud.classList.toggle('hidden', !data.visible);
    return;
  }

  if (data.action !== 'update') return;

  hud.classList.toggle('hidden', data.visible === false);

  els.job.textContent = data.job || 'Arbeitslos';
  els.grade.textContent = data.grade || 'Zivilist';
  els.playerId.textContent = data.playerId ?? 0;
  els.cash.textContent = money(data.cash);
  els.bank.textContent = money(data.bank);

  setStatus('health', data.health);
  setStatus('armor', data.armor);
  setStatus('stamina', data.stamina);
  setStatus('hunger', data.hunger);
  setStatus('thirst', data.thirst);
  setStatus('oxygen', data.oxygen);
  setStatus('stress', data.stress, true);

  els.oxygenStat.classList.toggle('show', data.underwater === true);
  els.stressStat.classList.toggle('show', Number(data.stress) > 0);

  els.voiceChip.classList.toggle('talking', data.talking === true);
  els.voiceLabel.textContent = data.talking ? 'TALK' : 'VOICE';

  const vehicleHealth = clamp(data.vehicleHealth);
  els.vehiclePanel.classList.toggle('hidden-panel', data.inVehicle !== true);
  els.speed.textContent = String(Math.max(0, Math.round(Number(data.speed) || 0)));
  els.vehicleHealthValue.textContent = `${vehicleHealth}%`;
  els.vehicleHealthBar.style.width = `${vehicleHealth}%`;
});
