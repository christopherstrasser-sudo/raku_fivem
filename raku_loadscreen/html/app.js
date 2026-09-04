const progressBar = document.getElementById('progressBar');
const percent = document.getElementById('percent');
const status = document.getElementById('status');
const stage = document.getElementById('stage');

const stages = [
  [0.00, 'Verbindung wird vorbereitet', 'Initialisierung'],
  [0.15, 'Serverdaten werden geladen', 'Netzwerk'],
  [0.35, 'Ressourcen werden synchronisiert', 'Resources'],
  [0.60, 'Los Santos wird vorbereitet', 'Welt'],
  [0.82, 'Charakterdaten werden geladen', 'Spielerdaten'],
  [0.96, 'Fast geschafft', 'Finalisierung']
];

let currentProgress = 0;
let hasRealProgress = false;

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function setProgress(value) {
  currentProgress = clamp(value, 0, 1);
  const display = Math.round(currentProgress * 100);

  progressBar.style.width = `${display}%`;
  percent.textContent = `${display}%`;

  let active = stages[0];
  for (const item of stages) {
    if (currentProgress >= item[0]) active = item;
  }

  status.textContent = active[1];
  stage.textContent = active[2];
}

window.addEventListener('message', (event) => {
  const data = event.data || {};

  if (data.eventName === 'loadProgress') {
    hasRealProgress = true;
    setProgress(Number(data.loadFraction) || 0);
  }
});

// Browser preview fallback only. In FiveM the real loading events take over.
setInterval(() => {
  if (hasRealProgress) return;
  if (currentProgress < 0.92) {
    setProgress(currentProgress + (Math.random() * 0.018 + 0.004));
  }
}, 550);

setProgress(0.03);
