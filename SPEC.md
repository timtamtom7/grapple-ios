# Grapple — Product Specification

## 1. Concept & Vision

Grapple is an AI thinking partner that challenges and sharpens your ideas. Paste a thought, belief, plan, or writing — Grapple finds the strongest counter-arguments and tests your thinking from every angle. Not contrarian — genuinely rigorous. It feels like having a sharp debate partner in your pocket: precise, fair, relentless, but ultimately on your side.

The experience should feel like a **debate court** — cerebral, focused, slightly austere. No fluff, no cheerleading. When Grapple challenges you, it's because the challenge matters.

---

## 2. Design Language

### Aesthetic Direction
**Academic debate court** — the visual language of a law review, a philosophy seminar, or a competitive debate chamber. Not warm, not friendly. Precise and purposeful.

### Color Palette
| Role | Color | Hex |
|------|-------|-----|
| Background | Dark Slate | `#0F1419` |
| Surface | Slate Gray | `#1A2332` |
| Surface Elevated | Lighter Slate | `#243044` |
| Primary Text | White | `#FFFFFF` |
| Secondary Text | Cool Gray | `#8B9BB4` |
| Challenge / Danger | Deep Red | `#E63946` |
| Rebuttal / Trust | Steel Blue | `#4A90D9` |
| Success / Synthesis | Muted Green | `#52B788` |
| Divider | Slate Border | `#2D3F54` |

### Typography
- **Headings:** SF Pro Display, Semibold — clean, authoritative
- **Body:** SF Pro Text, Regular — readable
- **Arguments / Monospace:** SF Mono, Regular — precision, code-like rigor
- **Sizes:**
  - Title: 28pt
  - Section: 20pt
  - Body: 16pt
  - Caption: 13pt
  - Argument text: 15pt (monospace)

### Spacing System
- Base unit: 8pt
- Content padding: 16pt horizontal, 24pt vertical
- Section spacing: 32pt
- Card padding: 16pt

### Motion Philosophy
**Snap, don't flow.** Animations are quick and purposeful — 200ms max. Elements snap into place rather than gliding. Think: a card dealing onto a table, not a balloon floating.

- Page transitions: 200ms ease-out slide
- Card appearance: 200ms opacity + 8pt vertical offset
- Button press: 100ms scale to 0.97
- No looping, no ambient, no decorative motion

### Visual Assets
- SF Symbols for icons (consistent, system-native)
- No illustrations — pure typography and color
- Dividers as thin 1pt lines, not shadows

---

## 3. Layout & Structure

### Navigation
Tab-based navigation at the bottom:
1. **New** — Start a new Grapple session (input → grapple → rebuttal → synthesis)
2. **History** — Past sessions, organized by topic

No hamburger menus, no settings complexity in Round 1.

### Screen Flow
```
[New] Tab
  └── InputView (paste/type/voice)
        └── GrappleView (counter-arguments presented)
              └── RebuttalView (type rebuttals, get AI judgment)
                    └── SynthesisView (AI summarizes)
                         └── Done (saves to history)

[History] Tab
  └── SessionListView (grouped by topic)
        └── SessionDetailView (read-only past session)
```

### Responsive
Single-column layout throughout. iPhone only for Round 1 (no iPad optimization).

---

## 4. Features & Interactions

### 4.1 Input (InputView)
- Large text area for pasting or typing a thought/belief/plan
- Placeholder: "What's on your mind? Paste a thought, belief, plan, or piece of writing you want to test..."
- Voice input button (speech-to-text via Speech framework)
- "Start Grapple" button — disabled until at least 20 characters entered
- Topic auto-detection from input (first noun phrase or user can override)
- Loading state while AI generates counter-arguments

### 4.2 Grapple View (GrappleView)
- Displays 3-5 counter-arguments, each tagged by type:
  - 🔴 **Factual** — challenges the accuracy of claims
  - 🔴 **Logical** — challenges reasoning structure
  - 🔴 **Emotional** — challenges emotional assumptions or appeals
  - 🔴 **Practical** — challenges feasibility or real-world application
- Each argument displayed in a card with:
  - Type badge (color-coded)
  - Argument text (monospace, 15pt)
  - Severity indicator (1-3, subtle)
- "Respond to All" button to proceed to rebuttal phase
- Can tap individual argument to expand/collapse detail

### 4.3 Rebuttal View (RebuttalView)
- One text field per counter-argument
- Placeholder: "Your rebuttal..."
- As user types, AI provides inline judgment:
  - ✅ (green) — Strong rebuttal
  - ⚠️ (yellow) — Partial, could be stronger
  - ❌ (red) — Weak, doesn't address the challenge
- "Submit Rebuttals" button when all fields have content
- Progress indicator: "3 of 5 rebuttals entered"

### 4.4 Synthesis View (SynthesisView)
- AI-generated summary after grappling completes
- Sections:
  - **What Survived:** Arguments that held up under pressure
  - **What Collapsed:** Arguments that fell apart
  - **What Needs Evidence:** Claims that need more support
  - **Final Verdict:** One-sentence synthesis of the thinking's robustness
- "Save Session" button (auto-saves on appear)
- "New Grapple" to start over

### 4.5 History (SessionListView)
- List of past sessions, most recent first
- Each row shows:
  - Topic name
  - Date
  - Number of arguments grappled
  - Outcome badge: "Strong" / "Mixed" / "Weak"
- Tap to view full session detail (read-only)
- Swipe to delete
- Grouped by topic cluster (simple string matching for now)

---

## 5. Component Inventory

### ArgumentCard
- States: default, expanded, responded
- Type badge (color-coded pill)
- Monospace argument text
- Expand/collapse chevron
- Subtle left border in challenge red

### RebuttalField
- States: empty, typing, judged
- TextEditor with border that changes color based on AI judgment
- Inline judgment icon appears after 2+ seconds of typing pause

### TopicBadge
- Small pill showing detected/categorized topic
- Tappable to edit

### SessionRow
- Topic, date, argument count, outcome badge
- Chevron right

### LoadingIndicator
- Centered spinner with "Grappling..." text
- Pulsing opacity animation (200ms)

### TabBar
- Two tabs: "New" and "History"
- SF Symbols: `square.and.pencil` and `clock.arrow.circlepath`
- Active state: steel blue tint
- Inactive: cool gray

---

## 6. Technical Approach

### Framework & Architecture
- **SwiftUI** for all UI
- **iOS 26** target
- **MVVM** architecture with ObservableObject ViewModels
- **SQLite.swift** for local persistence
- **Apple Intelligence** (AppIntents + AppleScript bridge) for AI generation in Round 1
- **CloudKit** — stub for future (no implementation in Round 1)

### Data Model

```swift
struct GrappleSession {
    let id: UUID
    var topic: String
    var originalInput: String
    var counterArguments: [CounterArgument]
    var rebuttals: [Rebuttal]
    var synthesis: Synthesis?
    var outcome: SessionOutcome
    let createdAt: Date
}

struct CounterArgument {
    let id: UUID
    let type: ArgumentType  // factual, logical, emotional, practical
    let text: String
    let severity: Int  // 1-3
}

struct Rebuttal {
    let id: UUID
    let argumentId: UUID
    var text: String
    var judgment: RebuttalJudgment  // strong, partial, weak
}

struct Synthesis {
    var whatSurvived: String
    var whatCollapsed: String
    var needsEvidence: String
    var verdict: String
}

enum ArgumentType: String { case factual, logical, emotional, practical }
enum RebuttalJudgment: String { case strong, partial, weak }
enum SessionOutcome: String { case strong, mixed, weak }
```

### Database Schema (SQLite)
```sql
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    topic TEXT NOT NULL,
    original_input TEXT NOT NULL,
    outcome TEXT NOT NULL,
    created_at REAL NOT NULL
);

CREATE TABLE counter_arguments (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    type TEXT NOT NULL,
    text TEXT NOT NULL,
    severity INTEGER NOT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

CREATE TABLE rebuttals (
    id TEXT PRIMARY KEY,
    argument_id TEXT NOT NULL,
    text TEXT NOT NULL,
    judgment TEXT NOT NULL,
    FOREIGN KEY (argument_id) REFERENCES counter_arguments(id)
);

CREATE TABLE synthesis (
    session_id TEXT PRIMARY KEY,
    what_survived TEXT NOT NULL,
    what_collapsed TEXT NOT NULL,
    needs_evidence TEXT NOT NULL,
    verdict TEXT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);
```

### AI Service Interface
Round 1 AI service uses Apple Intelligence via a structured prompt pattern. The service:
1. Accepts the user's original input
2. Returns 3-5 counter-arguments with types
3. Accepts rebuttals and judges each
4. Generates a synthesis

### File Structure
```
Sources/
├── GrappleApp.swift
├── Models/
│   ├── GrappleSession.swift
│   ├── CounterArgument.swift
│   ├── Rebuttal.swift
│   └── Enums.swift
├── ViewModels/
│   ├── GrappleViewModel.swift
│   └── HistoryViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── NewSession/
│   │   ├── InputView.swift
│   │   ├── GrappleView.swift
│   │   ├── RebuttalView.swift
│   │   └── SynthesisView.swift
│   └── History/
│       ├── SessionListView.swift
│       └── SessionDetailView.swift
├── Services/
│   ├── AIService.swift
│   └── DatabaseService.swift
└── Components/
    ├── ArgumentCard.swift
    ├── RebuttalField.swift
    ├── TopicBadge.swift
    ├── SessionRow.swift
    └── LoadingView.swift
Resources/
└── Assets.xcassets
```
