// Shared plan data and tokens
// Distilled from the original run-plan.yaml

// Design tokens — evolved Sports Data Terminal
const T = {
  bg: '#0a0c0b',
  bg2: '#0f1211',
  surf: '#141816',
  surf2: '#1b201d',
  surf3: '#252b26',
  border: '#252c26',
  border2: '#2f3831',
  text: '#eef2ee',
  muted: '#7a8a7c',
  muted2: '#4a5a4c',
  dim: '#3a453c',
  run: '#4eff91',
  runBg: '#0e1f14',
  runDim: '#1a4a2e',
  intv: '#f1de58',
  intvBg: '#211d08',
  intvDim: '#5b5214',
  mob: '#ffa94d',
  mobBg: '#1e1408',
  mobDim: '#4a3010',
  str: '#5ab0f5',
  strBg: '#0a1824',
  strDim: '#0e2840',
  rec: '#a99bff',
  recBg: '#0f0e1f',
  thr: '#ffa94d',
  race: '#ff6b6b',
  raceBg: '#1f0a0a',
  mono: "'JetBrains Mono', ui-monospace, monospace",
  sans: "'Plus Jakarta Sans', -apple-system, system-ui, sans-serif",
  serif: "'Fraunces', Georgia, serif",
};

// Day-type meta
const DAY_TYPES = {
  rest: { label: 'REST', color: T.dim, bg: T.surf2 },
  easy: { label: 'EASY', color: T.run, bg: T.runBg },
  rec:  { label: 'RECOVERY', color: T.rec, bg: T.recBg },
  intv: { label: 'INTERVAL', color: T.intv, bg: T.intvBg },
  thr:  { label: 'THRESHOLD', color: T.thr, bg: T.mobBg },
  lng:  { label: 'LONG', color: T.str, bg: T.strBg },
  race: { label: 'RACE', color: T.race, bg: T.raceBg },
};

const DAY_ABBR = ['MON','TUE','WED','THU','FRI','SAT','SUN'];

// Phase structure
const PHASES = [
  { id: 'ret', name: 'Injury Return', startWk: 'R1', endWk: 'R2', color: T.muted },
  { id: 'p1', name: 'Phase 1 · Aerobic Base', startWk: '1', endWk: '3', color: T.run },
  { id: 'p2', name: 'Phase 2 · Race Build', startWk: '4', endWk: '9', color: T.run },
  { id: 'p3', name: 'Phase 3 · Peak', startWk: '10', endWk: '11', color: T.run },
  { id: 'taper', name: '10K Taper & Race', startWk: '12', endWk: '13', color: T.race },
  { id: 'hm1', name: 'HM Reset', startWk: '14', endWk: '16', color: T.muted },
  { id: 'hm2', name: 'HM Foundation', startWk: '17', endWk: '20', color: T.run },
  { id: 'hm3', name: 'HM Peak', startWk: '21', endWk: '24', color: T.run },
  { id: 'hm4', name: 'HM Freshen/Taper', startWk: '25', endWk: '27', color: T.str },
  { id: 'hmr', name: 'HM Race', startWk: '28', endWk: '28', color: T.race },
];

// Generated from run-plan.yaml by scripts/generate_plan_data.rb.
const WEEKS = window.RUN_PLAN_WEEKS || [];

// Date helpers
function zonedDateParts(timeZone) {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(new Date());
  const map = Object.fromEntries(parts.map(p => [p.type, p.value]));
  return {
    year: Number(map.year),
    month: Number(map.month),
    day: Number(map.day),
  };
}

function utcDateFromParts(parts) {
  return Date.UTC(parts.year, parts.month - 1, parts.day);
}

function diffWholeDays(fromUtc, toUtc) {
  return Math.floor((toUtc - fromUtc) / 86400000);
}

const JAKARTA_TODAY = zonedDateParts('Asia/Jakarta');
const PLAN_START = { year: 2026, month: 3, day: 30 };
const planStartUtc = utcDateFromParts(PLAN_START);
const todayUtc = utcDateFromParts(JAKARTA_TODAY);
const planDayOffset = diffWholeDays(planStartUtc, todayUtc);
const clampedDayOffset = Math.max(0, Math.min(planDayOffset, (WEEKS.length * 7) - 1));
const TODAY_WEEK_ID = WEEKS[Math.floor(clampedDayOffset / 7)].id;
const TODAY_DAY_INDEX = clampedDayOffset % 7;

// Today's-week reference
function getWeek(id) { return WEEKS.find(w => w.id === id); }
function getTodayWeek() { return getWeek(TODAY_WEEK_ID); }
function getTodayDay() {
  const w = getTodayWeek();
  return w.days[TODAY_DAY_INDEX];
}

const DAYS_TO_10K = Math.max(0, diffWholeDays(todayUtc, utcDateFromParts({ year: 2026, month: 7, day: 12 })));
const DAYS_TO_HM = Math.max(0, diffWholeDays(todayUtc, utcDateFromParts({ year: 2026, month: 10, day: 25 })));

Object.assign(window, {
  T, DAY_TYPES, DAY_ABBR, PHASES, WEEKS,
  TODAY_WEEK_ID, TODAY_DAY_INDEX,
  getWeek, getTodayWeek, getTodayDay,
  DAYS_TO_10K, DAYS_TO_HM,
});
