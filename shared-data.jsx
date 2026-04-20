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

// Compact weeks — id, dates, km, phase, days[7]
// Each day: {t: type, s: short-label, l: long-detail}
const WEEKS = [
  { id: 'R1',  dates: 'Mar 30–Apr 5',  km: 20, phase: 'ret', days: [
    {t:'rest',s:'Rest'}, {t:'easy',s:'5km Z2'}, {t:'rest',s:'Rest'},
    {t:'easy',s:'5km Z2'}, {t:'rest',s:'Rest'}, {t:'easy',s:'5km Z2'},
    {t:'easy',s:'5km Z2',l:'Optional'}
  ]},
  { id: 'R2',  dates: 'Apr 6–12',  km: 38, phase: 'ret', days: [
    {t:'rest',s:'Rest'}, {t:'easy',s:'6km +strides'}, {t:'rest',s:'X-train'},
    {t:'thr',s:'15min thr',l:'WU 1.5 · 15min @ HR 165-170 · CD 1.5 (~6km)'},
    {t:'rec',s:'5km rec'}, {t:'easy',s:'7km Z2'},
    {t:'lng',s:'12km long'}
  ]},
  { id: '1',   dates: 'Apr 13–19', km: 49, phase: 'p1', days: [
    {t:'rest',s:'Rest'}, 
    {t:'intv',s:'8×400m',l:'WU 2km · 8×400m @ 4:45, 75s jog · CD 1.5 (~7.5km)'},
    {t:'rec',s:'6km rec'},
    {t:'thr',s:'22min thr',l:'WU 1.5 · 22min @ 5:20 (HR 165-170) · CD 1.5 (~7km)'},
    {t:'rec',s:'X-train'},
    {t:'easy',s:'8km +hills'},
    {t:'lng',s:'16km long'}
  ]},
  { id: '2',   dates: 'Apr 20–26', km: 54, phase: 'p1', days: [
    {t:'rest',s:'Rest',l:'Full rest day. Light mobility only if needed.'},
    {t:'intv',s:'6×800m',l:'WU 2km + 4×100m strides · 6×800m @ 4:50/km, 90s jog (target 155-160 bpm) · CD 1.5km (~10km total). HR override: if HR >170 before rep ends, slow down.'},
    {t:'rec',s:'6km rec',l:'Recovery 6km · HR cap 140-145 bpm'},
    {t:'thr',s:'26min thr',l:'WU 1.5km @ 6:40 · 26min continuous @ 5:15/km (HR 165-170) · CD 1.5km (~8km total). Continue the aerobic build — smoother and longer than Wk 1.'},
    {t:'rec',s:'X-train',l:'Cross-train or recovery 5km. If legs heavy from Tue+Thu, take the bike.'},
    {t:'easy',s:'8km +hills',l:'Easy 8km @ Z2 HR + 8×10s hill sprints (treadmill 8-10%, max effort, 2min full walk rest)'},
    {t:'lng',s:'18km long',l:'Long run — 18km easy @ Z2 HR'}
  ]},
  { id: '3',   dates: 'Apr 27–May 3', km: 58, phase: 'p1', days: [
    {t:'rest',s:'Rest'}, 
    {t:'intv',s:'5×1km',l:'WU 2km · 5×1km @ 4:45-4:48, 90s jog · CD 1.5 (~10km)'},
    {t:'rec',s:'6km rec'},
    {t:'thr',s:'30min thr',l:'30min continuous @ 5:10/km (HR 165-172) (~8.8km)'},
    {t:'rec',s:'6km rec'},
    {t:'easy',s:'8km +hills'},
    {t:'lng',s:'19km long'}
  ]},
  { id: '4',   dates: 'May 4–10', km: 49, phase: 'p2', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×1.2km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'4×6min'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'16km long'}
  ]},
  { id: '5',   dates: 'May 11–17', km: 56, phase: 'p2', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×1.5km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'2×15min'}, {t:'rec',s:'6km rec'}, {t:'easy',s:'7km +hills'}, {t:'lng',s:'18km prog'}
  ]},
  { id: '6',   dates: 'May 18–24', km: 55, phase: 'p2', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×2km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'2×15min'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'7km +hills'}, {t:'lng',s:'18km long'}
  ]},
  { id: '7',   dates: 'May 25–31', km: 54, phase: 'p2', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'2×3km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'25min thr'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'7km +hills'}, {t:'lng',s:'19km long'}
  ]},
  { id: '8',   dates: 'Jun 1–7', km: 48, phase: 'p2', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×1km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'20min thr'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'16km long'}
  ]},
  { id: '9',   dates: 'Jun 8–14', km: 55, phase: 'p2', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×2km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'3×10min'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'7km +hills'}, {t:'lng',s:'18km prog'}
  ]},
  { id: '10',  dates: 'Jun 15–21', km: 52, phase: 'p3', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'6×1km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'2×12min'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'16km long'}
  ]},
  { id: '11',  dates: 'Jun 22–28', km: 48, phase: 'p3', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'5×1km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'22min thr'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'15km long'}
  ]},
  { id: '12',  dates: 'Jun 29–Jul 5', km: 40, phase: 'taper', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×800m'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'18min thr'}, {t:'rec',s:'4km rec'}, {t:'easy',s:'5km'}, {t:'lng',s:'12km long'}
  ]},
  { id: '13',  dates: 'Jul 6–12', km: 17, phase: 'taper', race: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×400m'}, {t:'easy',s:'5km'},
    {t:'easy',s:'4km +strides'}, {t:'rest',s:'Rest'}, {t:'easy',s:'3km jog'},
    {t:'race',s:'LOMBOK 10K',l:'RACE DAY · Pocari Sweat Lombok 10K · Target Sub 48:00 · Pace 4:48/km'}
  ]},
  { id: '14',  dates: 'Jul 13–19', km: 27, phase: 'hm1', days: [
    {t:'rest',s:'Rest'}, {t:'easy',s:'5km Z2'}, {t:'rest',s:'Rest'},
    {t:'easy',s:'5km Z2'}, {t:'rest',s:'X-train'}, {t:'easy',s:'5km +strides'}, {t:'lng',s:'12km long'}
  ]},
  { id: '15',  dates: 'Jul 20–26', km: 45, phase: 'hm1', days: [
    {t:'rest',s:'Rest'}, {t:'easy',s:'7km +strides'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'2×10min'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'14km long'}
  ]},
  { id: '16',  dates: 'Jul 27–Aug 2', km: 50, phase: 'hm1', days: [
    {t:'rest',s:'Rest'}, {t:'easy',s:'8km +strides'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'3×8min'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'7km +hills'}, {t:'lng',s:'16km long'}
  ]},
  { id: '17',  dates: 'Aug 3–9', km: 57, phase: 'hm2', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×2km HM'}, {t:'rec',s:'6km rec'},
    {t:'thr',s:'25min thr'}, {t:'rec',s:'6km rec'}, {t:'easy',s:'8km +hills'}, {t:'lng',s:'18km long'}
  ]},
  { id: '18',  dates: 'Aug 10–16', km: 61, phase: 'hm2', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'2×3km HM'}, {t:'rec',s:'6km rec'},
    {t:'thr',s:'3×10min'}, {t:'rec',s:'6km rec'}, {t:'easy',s:'8km +hills'}, {t:'lng',s:'20km prog'}
  ]},
  { id: '19',  dates: 'Aug 17–23', km: 25, phase: 'hm2', race: true, days: [
    {t:'rest',s:'Rest'}, {t:'easy',s:'7km +strides'}, {t:'rec',s:'5km rec'},
    {t:'easy',s:'6km +strides'}, {t:'rec',s:'4km rec'}, {t:'easy',s:'3km jog'},
    {t:'race',s:'BALI HM',l:'BALI HALF MARATHON · Controlled long session'}
  ]},
  { id: '20',  dates: 'Aug 24–30', km: 48, phase: 'hm2', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×1.5km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'20min thr'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'18km long'}
  ]},
  { id: '21',  dates: 'Aug 31–Sep 6', km: 64, phase: 'hm3', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×3km HM'}, {t:'rec',s:'6km rec'},
    {t:'thr',s:'2×15min'}, {t:'rec',s:'6km rec'}, {t:'easy',s:'8km +hills'}, {t:'lng',s:'22km long'}
  ]},
  { id: '22',  dates: 'Sep 7–13', km: 64, phase: 'hm3', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'2×4km HM'}, {t:'rec',s:'6km rec'},
    {t:'thr',s:'28min thr'}, {t:'rec',s:'6km rec'}, {t:'easy',s:'7km +hills'}, {t:'lng',s:'24km prog'}
  ]},
  { id: '23',  dates: 'Sep 14–20', km: 68, phase: 'hm3', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×3km HM'}, {t:'rec',s:'6km rec'},
    {t:'thr',s:'2×15min'}, {t:'rec',s:'6km rec'}, {t:'easy',s:'8km +hills'}, {t:'lng',s:'24km long'}
  ]},
  { id: '24',  dates: 'Sep 21–27', km: 54, phase: 'hm3', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×2km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'20min thr'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'6km +hills'}, {t:'lng',s:'18km long'}
  ]},
  { id: '25',  dates: 'Sep 28–Oct 4', km: 48, phase: 'hm4', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×1km'}, {t:'rec',s:'5km rec'},
    {t:'thr',s:'24min HM'}, {t:'rec',s:'5km rec'}, {t:'easy',s:'5km +hills'}, {t:'lng',s:'16km long'}
  ]},
  { id: '26',  dates: 'Oct 5–11', km: 37, phase: 'hm4', cutback: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×800m'}, {t:'rec',s:'5km rec'},
    {t:'easy',s:'5km +strides'}, {t:'easy',s:'4km'}, {t:'easy',s:'4km'}, {t:'lng',s:'12km long'}
  ]},
  { id: '27',  dates: 'Oct 12–18', km: 21, phase: 'hm4', days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'3×1km'}, {t:'rec',s:'5km rec'},
    {t:'easy',s:'5km +strides'}, {t:'rest',s:'Rest'}, {t:'easy',s:'4km jog'}, {t:'rest',s:'Rest'}
  ]},
  { id: '28',  dates: 'Oct 19–25', km: 17, phase: 'hmr', race: true, days: [
    {t:'rest',s:'Rest'}, {t:'intv',s:'4×400m'}, {t:'easy',s:'5km'},
    {t:'easy',s:'4km +strides'}, {t:'rest',s:'Rest'}, {t:'easy',s:'3km jog'},
    {t:'race',s:'HM RACE',l:'HALF MARATHON · Target Sub 1:45:00 · Pace 4:58/km'}
  ]},
];

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
