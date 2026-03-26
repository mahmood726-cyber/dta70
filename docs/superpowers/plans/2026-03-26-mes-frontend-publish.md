# MES Frontend, Manuscripts & Ship — Implementation Plan (Phases B+C+D)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the MES browser-based HTML app (5 tabs, 6 visualizations), write BMJ + F1000 manuscripts using batch results, and ship to GitHub + Zenodo.

**Architecture:** Single-file HTML app (~4,000-6,000 lines) following the established portfolio pattern (CSS vars, tab switching, Plotly.js charts, dark mode, CSV import, localStorage). The app mirrors the Python engine's ASSESS→EXPLORE→MAP pipeline but runs entirely in-browser with Web Workers for parallelism. Manuscripts auto-populated from batch validation results.

**Tech Stack:** HTML5, CSS3, vanilla JS, Plotly.js (CDN), Web Workers, SHA-256 (SubtleCrypto API). No build step.

**Spec:** `C:\Users\user\docs\superpowers\specs\2026-03-25-mes-design.md` (Sections 7, 8)

**Project root:** `C:\Models\MES\`

**Reference apps (established patterns):**
- `C:\Models\MultiverseMA\multiverse-ma.html` (~2,354 lines) — spec curve, Janus plot, multiverse grid
- `C:\Models\CausalSynth\causal-synth.html` (~1,747 lines) — design classification, GRADE mapping
- `C:\Models\RoBAssessor\rob-assessor.html` (~1,463 lines) — RoB traffic light, domain scoring

**Built-in exemplar datasets (from batch validation):**
- ROBUST: CD001431 (k=61, C_sig=1.0)
- FRAGILE: CD014040 (k=14, C_sig=0.59)
- UNSTABLE: CD004871 (k=5, C_sig=0.33)
- Plus BCG vaccine (k=13, C_sig=0.71, MODERATE) — already in `data/built_in/`

**Windows note:** Use `python` not `python3`. `${'<'}/script>` in template literals.

---

## File Structure

```
C:\Models\MES\
├── app/
│   └── mes-app.html              # Single-file HTML frontend (~5,000 lines)
├── data/
│   └── built_in/
│       ├── bcg_vaccine.json       # Already exists (13 studies)
│       ├── robust_example.json    # CD001431 extract
│       ├── fragile_example.json   # CD014040 extract
│       └── unstable_example.json  # CD004871 extract
├── paper/
│   ├── mes_bmj.md                 # BMJ flagship manuscript
│   └── mes_f1000.md               # F1000 software paper
├── tests/
│   └── test_selenium.py           # Browser tests (30+)
└── (existing Python engine files)
```

---

## PHASE B: HTML FRONTEND

### Task 1: Extract Built-in Datasets

**Files:**
- Create: `C:\Models\MES\data\built_in\robust_example.json`
- Create: `C:\Models\MES\data\built_in\fragile_example.json`
- Create: `C:\Models\MES\data\built_in\unstable_example.json`
- Create: `C:\Models\MES\scripts\extract_exemplars.py`

- [ ] **Step 1: Write extraction script**

```python
# scripts/extract_exemplars.py
"""Extract exemplar datasets from Pairwise70 for built-in app data."""
import json, sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from mes_core.io.rda_reader import read_rda

PAIRWISE_DIR = r"C:\Models\Pairwise70\data"
EXEMPLARS = {
    "robust_example": "CD001431",
    "fragile_example": "CD014040",
    "unstable_example": "CD004871",
}

for out_name, review_id in EXEMPLARS.items():
    # Try common extensions
    for ext in (".RData", ".rda"):
        path = os.path.join(PAIRWISE_DIR, review_id + ext)
        if os.path.exists(path):
            studies = read_rda(path)
            if studies:
                out_path = os.path.join("data", "built_in", f"{out_name}.json")
                with open(out_path, "w") as f:
                    json.dump(studies, f, indent=2)
                print(f"Extracted {review_id} -> {out_path} ({len(studies)} studies)")
            break
    else:
        print(f"WARNING: {review_id} not found")
```

- [ ] **Step 2: Run extraction**

Run: `cd C:/Models/MES && python scripts/extract_exemplars.py`
Expected: 3 JSON files created in `data/built_in/`

- [ ] **Step 3: Verify JSON files**

Run: `cd C:/Models/MES && python -c "import json; [print(f'{f}: {len(json.load(open(f\"data/built_in/{f}\"))))} studies') for f in ['robust_example.json','fragile_example.json','unstable_example.json']]"`

- [ ] **Step 4: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "data: extract 3 exemplar datasets for built-in examples"
```

---

### Task 2: HTML App — Boilerplate + Tab 1 (Data Input)

**Files:**
- Create: `C:\Models\MES\app\mes-app.html`

This is the biggest task — sets up the entire HTML structure with all 5 tab shells and fully implements Tab 1.

- [ ] **Step 1: Create the HTML app**

Build `app/mes-app.html` with:

**Head section:**
- `<meta charset="UTF-8">`, viewport
- Plotly.js CDN: `<script src="https://cdn.plot.ly/plotly-2.35.0.min.js"><\/script>`
- Full CSS (~400 lines): CSS variables (light/dark), `.tab-bar`, `.tab-panel`, `.card`, `.data-table`, `.traffic-light`, `.badge`, responsive layout
- Skip-to-content link

**Header:**
- Title: "MES — Multiverse Evidence Synthesis"
- Subtitle: "Evidence Landscapes, Not Point Estimates"
- Controls: Import CSV, Export, Dark Mode, About

**Tab bar (5 tabs):**
1. Data Input (active by default)
2. Evidence Assessment
3. Multiverse Explorer
4. Evidence Landscape
5. Report & Certify

**Tab 1 — Data Input (fully implemented):**
- Study data table: editable rows with columns: Study ID, yi (effect), vi (variance), Design, RoB Overall
- Add Row / Remove Row / Clear All buttons
- CSV import with fuzzy header matching (study/author → study_id, effect/yi/lnor → yi, var/vi/sei² → vi)
- JSON import (same format as built-in datasets)
- Built-in dataset selector (dropdown): BCG Vaccine, Robust Example, Fragile Example, Unstable Example
- "Load Dataset" button → populates table
- localStorage persistence (key: `mes_app_studies`)
- Study count + summary stats display
- "Run MES Analysis" button (calls `runAnalysis()` — stub for now)

**Tabs 2-5:** Placeholder panels with "Run analysis first" message.

**JavaScript foundation (~300 lines):**
- `let appState = { studies: [], results: [], verdict: null }`
- `switchTab(tabName)` — tab switching with ARIA
- `toggleTheme()` — dark mode
- `addRow()`, `removeRow(idx)`, `clearAll()`, `syncStudies()`
- `importCSV()`, `handleCSVFile(event)`, `parseCSVData(text)`
- `loadBuiltIn(name)` — fetch from embedded JSON
- `exportCSV()` — export study data
- `runAnalysis()` — stub that calls Tab 2-5 rendering (implemented in later tasks)
- `init()` — load from localStorage or default dataset

**Key patterns to follow (from MultiverseMA/CausalSynth):**
- CSS vars for all colors (light defaults, `body.dark` overrides)
- `role="tablist"`, `role="tab"`, `role="tabpanel"` with `aria-selected`
- Plotly theme-aware: `getCSSVar('--text')` for text color
- All interactive elements keyboard-accessible
- No `</script>` inside `<script>` block — use `${'<'}/script>` if needed

- [ ] **Step 2: Verify the app loads in browser**

Run: `cd C:/Models/MES && start app/mes-app.html`
Expected: App opens in browser with Tab 1 visible, data table functional, built-in datasets loadable

- [ ] **Step 3: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): create MES HTML app with Tab 1 (Data Input)"
```

---

### Task 3: Statistical Engine (JS port of Python core)

**Files:**
- Modify: `C:\Models\MES\app\mes-app.html` (add JS inside `<script>`)

Port the Python engine to JS. This goes inside the same HTML file as a new `<script>` section or within the existing one.

- [ ] **Step 1: Port estimators (6 methods)**

Port from `C:\Models\MES\mes_core\explore\estimators.py`. Functions: `fe(yi,vi)`, `dl(yi,vi)`, `reml(yi,vi)`, `pm(yi,vi)`, `sj(yi,vi)`, `ml(yi,vi)`, `poolEstimate(yi,vi,tau2)`. All return `{tau2, theta, se}`.

- [ ] **Step 2: Port CI methods (3 methods)**

Port from `ci_methods.py`: `waldCI(theta,se,alpha)`, `hksjCI(theta,se,yi,vi,tau2,k,alpha)`, `tdistCI(theta,se,k,alpha)`. Return `{ciLo, ciHi, pValue}`.

- [ ] **Step 3: Port bias corrections (3 methods)**

Port from `bias_corrections.py`: `trimFill(yi,vi)`, `petPeese(yi,vi)`, `selectionModel(yi,vi)`.

- [ ] **Step 4: Port statistical utilities**

`normalCDF(x)`, `normalQuantile(p)`, `tCDF(x,df)`, `tQuantile(p,df)`, `chi2Quantile(p,df)` — from `stats-utils.js` patterns in existing apps.

- [ ] **Step 5: Port spec generator + executor**

`generateSpecs(mesSpec, dossiers)` → array of spec objects
`executeMultiverse(mesSpec, dossiers)` → array of SpecResult objects
Use `setTimeout` batching for non-blocking execution with progress callback.

- [ ] **Step 6: Port MAP module**

`computeConcordance(results)`, `classifyRobustness(cSig)`, `conditionalRobustness(results)`, `decomposeInfluence(results)`, `findBoundaries(results)`, `synthesizeVerdict(results)`.

- [ ] **Step 7: Wire runAnalysis()**

```javascript
function runAnalysis() {
    const studies = syncStudies();
    if (studies.length < 2) { alert('Need at least 2 studies'); return; }
    showProgress('Running multiverse...');
    setTimeout(() => {
        const dossiers = buildDossiers(studies);
        const results = executeMultiverse(DEFAULT_SPEC, dossiers);
        const verdict = synthesizeVerdict(results);
        appState.results = results;
        appState.verdict = verdict;
        renderTab2(dossiers);
        renderTab3(results);
        renderTab4(verdict, results);
        renderTab5(verdict, studies, results);
        switchTab('assessment');
        hideProgress();
    }, 50);
}
```

- [ ] **Step 8: Verify BCG analysis matches Python**

Load BCG dataset, run analysis, check console for verdict. Compare theta/tau2 for DL against Python values.

- [ ] **Step 9: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): port statistical engine to JS (6 estimators, 3 CI, 3 bias corrections)"
```

---

### Task 4: Tab 2 — Evidence Assessment

**Files:**
- Modify: `C:\Models\MES\app\mes-app.html`

- [ ] **Step 1: Implement `renderTab2(dossiers)`**

Renders 4 components in the Evidence Assessment tab:

**A) RoB Traffic Light Table** — table with studies as rows, RoB domains as columns. Cells colored green (low), yellow (some concerns), red (high). Overall column with same coloring. Pattern from RoB Assessor app.

**B) Design Classification Matrix** — summary table: how many RCTs, quasi, observational. Tier badges.

**C) Bias Profile Card** — Egger p-value, Begg p-value, excess significance count. Traffic light indicator (green if all non-significant, yellow if one significant, red if multiple).

**D) Study Summary** — k, median year, effect range, variance range.

- [ ] **Step 2: Verify visually with BCG**

Load BCG, run analysis, check Tab 2 displays correctly.

- [ ] **Step 3: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): add Tab 2 (Evidence Assessment) with RoB traffic light + bias profile"
```

---

### Task 5: Tab 3 — Multiverse Explorer

**Files:**
- Modify: `C:\Models\MES\app\mes-app.html`

- [ ] **Step 1: Implement dimension selector**

Checkboxes for each dimension level. Toggle estimators on/off, CI methods on/off, etc. "Select All / Deselect All" per dimension. Live spec count display: "X of 648 specifications selected".

- [ ] **Step 2: Implement specification curve (Plotly)**

Port from MultiverseMA. X-axis = spec index (sorted by theta), Y-axis = theta. Points colored by significance (blue = significant, grey = not). CI whiskers optional toggle. Bottom panel: dimension indicator strips showing which level each spec uses.

- [ ] **Step 3: Implement Janus plot (Plotly)**

X = theta, Y = -log10(p). Quadrant lines at theta=0 and p=0.05. Color by significance.

- [ ] **Step 4: Implement concordance summary card**

C_dir, C_sig, C_full as large numbers with labels. Spec count: "612 of 648 feasible".

- [ ] **Step 5: Verify visually with BCG**

- [ ] **Step 6: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): add Tab 3 (Multiverse Explorer) with spec curve + Janus plot"
```

---

### Task 6: Tab 4 — Evidence Landscape

**Files:**
- Modify: `C:\Models\MES\app\mes-app.html`

- [ ] **Step 1: Implement robustness traffic light**

Large visual verdict: colored circle (green/yellow/orange/red) with class name (ROBUST/MODERATE/FRAGILE/UNSTABLE) + C_sig percentage. Conditional robustness cards below: one per quality/design filter, each with its own mini traffic light.

- [ ] **Step 2: Implement influence sunburst (Plotly)**

Plotly sunburst chart: inner ring = dimensions, outer ring = levels within each dimension. Values = η². Shows what drives the fragility.

- [ ] **Step 3: Implement decision stability map**

Heatmap (Plotly): rows = dimension levels (e.g., "DL", "REML", "trim-fill", "low-rob-only"), columns = metrics (concordance rate, flip rate). Red cells = "this choice breaks the conclusion."

- [ ] **Step 4: Implement fragility boundary cards**

For each dimension with boundaries: text description of what flips and when. E.g., "Bias correction: trim-fill flips significance (agree rate = 0.32)".

- [ ] **Step 5: Implement prediction interval summary**

"X% of specifications have prediction intervals crossing the null." Bar showing the split.

- [ ] **Step 6: Verify with BCG**

- [ ] **Step 7: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): add Tab 4 (Evidence Landscape) with traffic light + sunburst + stability map"
```

---

### Task 7: Tab 5 — Report & Certify

**Files:**
- Modify: `C:\Models\MES\app\mes-app.html`

- [ ] **Step 1: Implement auto-generated methods text**

Paragraph describing the MES analysis: which dimensions were active, how many specs, which estimators, which CI methods, which bias corrections, which quality/design filters. Selectable text with "Copy" button. Pattern from MultiverseMA methods text.

- [ ] **Step 2: Implement R code export**

Generate metafor-compatible R script that reproduces the analysis. Copy button.

- [ ] **Step 3: Implement TruthCert bundle**

SHA-256 hash of input data + spec + results (using SubtleCrypto API). Display: provenance chain, timestamps, certification status (PASS/WARN/REJECT). Export as JSON button.

- [ ] **Step 4: Implement print-ready report**

"Generate Report" button → opens print dialog with formatted HTML report (landscape verdict, key visualizations as embedded SVGs, methods text). CSS `@media print` styles.

- [ ] **Step 5: Verify with BCG**

- [ ] **Step 6: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): add Tab 5 (Report & Certify) with methods text + R export + TruthCert"
```

---

### Task 8: Polish + Accessibility + Testing

**Files:**
- Modify: `C:\Models\MES\app\mes-app.html`
- Create: `C:\Models\MES\tests\test_selenium.py`

- [ ] **Step 1: Keyboard accessibility**

Arrow keys for tab navigation, Enter/Space to activate buttons, Escape to close modals. ARIA labels on all interactive elements.

- [ ] **Step 2: localStorage persistence**

Save/restore: active tab, theme, last dataset, dimension selections.

- [ ] **Step 3: About modal**

Version, author placeholder, methodology summary, citation.

- [ ] **Step 4: Div balance check**

Run: Count `<div` vs `</div>` in the HTML file. Must match.

- [ ] **Step 5: Write Selenium tests (30+)**

```python
# tests/test_selenium.py
"""Browser tests for MES HTML app."""
import pytest, time, os, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

@pytest.fixture(scope="module")
def driver():
    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    d = webdriver.Chrome(options=opts)
    d.get("file:///" + os.path.abspath("app/mes-app.html").replace("\\", "/"))
    time.sleep(2)
    yield d
    d.quit()

# Test groups:
# - Tab navigation (5 tests)
# - Data input: add/remove rows, CSV import (5 tests)
# - Built-in datasets load correctly (4 tests)
# - Analysis runs without errors (3 tests)
# - Tab 2 renders assessment (3 tests)
# - Tab 3 renders spec curve (3 tests)
# - Tab 4 renders verdict (3 tests)
# - Tab 5 renders report (2 tests)
# - Dark mode toggle (1 test)
# - Export functions (1 test)
# Total: 30 tests
```

- [ ] **Step 6: Run Selenium tests**

Run: `cd C:/Models/MES && python -m pytest tests/test_selenium.py -v --timeout=120`

- [ ] **Step 7: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "feat(app): add accessibility, persistence, Selenium tests (30+)"
```

---

## PHASE C: MANUSCRIPTS

### Task 9: BMJ Flagship Manuscript

**Files:**
- Create: `C:\Models\MES\paper\mes_bmj.md`

- [ ] **Step 1: Write manuscript skeleton**

Structure (from spec Section 8.1):
- Title: "Multiverse Evidence Synthesis: A Framework for Robust Meta-Analysis Applied to 403 Cochrane Reviews"
- Abstract (structured: Objective, Design, Data Sources, Methods, Results, Conclusion)
- Introduction: The crisis (fragility + prediction gap + model dependence)
- Methods §1: MES framework (ASSESS → EXPLORE → MAP)
- Methods §2: Specification space (6 dimensions, 648+ specs)
- Methods §3: Robustness classification + conditional robustness
- Methods §4: Application to Pairwise70 dataset
- Results §1: Traditional vs MES reclassification
- Results §2: Robustness distribution (32.3% Robust, 27.8% Moderate, 36.5% Fragile, 3.5% Unstable)
- Results §3: Influence decomposition (bias correction η²=0.93 dominant)
- Results §4: Conditional robustness findings
- Results §5: 3 case studies (Robust/Fragile/Unstable exemplars)
- Discussion: Implications for guideline panels, GRADE integration
- Conclusion: "Report landscapes, not point estimates"
- References (~30)

- [ ] **Step 2: Populate results from batch data**

Read `C:/Models/MES/validation/results/batch_results.csv` and compute all statistics for the Results section.

- [ ] **Step 3: Add author placeholders**

```
Author: AUTHOR_NAME
Affiliation: AFFILIATION
Email: EMAIL
ORCID: ORCID
```

- [ ] **Step 4: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "docs: BMJ manuscript draft with batch validation results"
```

---

### Task 10: F1000 Software Paper

**Files:**
- Create: `C:\Models\MES\paper\mes_f1000.md`

- [ ] **Step 1: Write software paper**

Structure:
- Title: "MES: An Open-Access Tool for Multiverse Evidence Synthesis in Meta-Analysis"
- Abstract
- Introduction: Software landscape (RevMan, MetaXL, metafor), gap in multiverse tools
- Implementation: Python engine + HTML frontend, architecture
- Use case: Worked example with BCG dataset
- Validation: R parity (6 estimators at 1e-4), Selenium tests
- Availability: GitHub URL, Zenodo DOI
- References (~20)

- [ ] **Step 2: Add author placeholders**

- [ ] **Step 3: Commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "docs: F1000 software paper draft"
```

---

## PHASE D: SHIP

### Task 11: GitHub + Zenodo + Submit

**Files:**
- Create: `C:\Models\MES\README.md`
- Create: `C:\Models\MES\LICENSE`
- Create: `C:\Models\MES\.github\CITATION.cff`

- [ ] **Step 1: Create README.md**

Project title, badges, one-paragraph description, installation (`pip install .`), quick start (Python + HTML), screenshot placeholder, citation, license.

- [ ] **Step 2: Create LICENSE (MIT)**

- [ ] **Step 3: Create CITATION.cff**

- [ ] **Step 4: Create GitHub repo**

Run: `cd C:/Models/MES && gh repo create mahmood726-cyber/mes --public --source . --push`

- [ ] **Step 5: Tag release**

Run: `cd C:/Models/MES && git tag -a v1.0.0 -m "MES v1.0.0: Multiverse Evidence Synthesis" && git push --tags`

- [ ] **Step 6: Zenodo DOI**

Create Zenodo deposit (manual — provide instructions to user).

- [ ] **Step 7: Update manuscripts with DOI + GitHub URL**

- [ ] **Step 8: Final commit**

```bash
cd C:/Models/MES && git add -A && git commit -m "chore: ready for submission — README, LICENSE, CITATION.cff"
```

- [ ] **Step 9: Update project index**

Update `C:\ProjectIndex\INDEX.md` with final MES status.
