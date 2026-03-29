# GrappleMac — Launch Checklist

> Last updated: R13 — 2026-03-29

---

## ✅ Pre-Launch (R13)

### App Store Listing
- [x] Created `Marketing/APPSTORE.md`
- [x] Tagline: "Sharpen your thinking through debate."
- [x] Full description written (4 stages, features, privacy)
- [x] Keywords researched
- [ ] Screenshots captured from running app
- [ ] Preview text submitted

### Academic Aesthetic Audit
- [x] Typography audit — serif for arguments (monospaced), clean sans for UI (system default) ✅
- [x] Debate stages visually distinguished — input → challenge → rebuttal → synthesis → done ✅
- [x] Colors: navy background (#0F1419, #1A2332), cream secondary (#8B9BB4), gold accent (added to MacTheme)
- [ ] Gold accent color verified in actual UI usage

### Code Audit
- [x] No `TODO:` or `FIXME:` comments left in production views
- [x] All SwiftUI previews render without crashes
- [x] Build succeeds (Release, arm64, ad-hoc signing)
- [ ] Localization strings extracted for future i18n

---

## 🚀 Launch Day

### Build & Sign
- [ ] `xcodegen generate` runs cleanly
- [ ] `xcodebuild -scheme GrappleMac -configuration Release` succeeds
- [ ] Code signing: App Store Distribution certificate configured
- [ ] Provisioning profile created for GrappleMac (macOS)
- [ ] Hardened Runtime enabled for notarization

### App Store Connect
- [ ] New app entry created for GrappleMac
- [ ] Primary category set: Productivity
- [ ] Secondary category (optional): Education
- [ ] Age rating: 4+
- [ ] Copyright: © 2026 Tommaso Mauriello
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] App website URL added
- [ ] App Store screenshots uploaded (5 required for Mac):
  - [ ] Screenshot 1: New Grapple / input screen
  - [ ] Screenshot 2: Counter-arguments in progress
  - [ ] Screenshot 3: Synthesis card
  - [ ] Screenshot 4: Challenge of the Week
  - [ ] Screenshot 5: Tournament bracket
- [ ] App preview video (optional but recommended)
- [ ] Localized metadata prepared for additional territories

### Metadata
- [ ] Name: GrappleMac
- [ ] Subtitle: Rigorous debate for thinkers, writers, and decision-makers
- [ ] Description pasted from `Marketing/APPSTORE.md`
- [ ] Keywords added (debate, thinking, argument, reasoning, philosophy, critical thinking, writing, AI, productivity, logic, strategy)
- [ ] Promotional text (optional)

### Binary Delivery
- [ ] Archive built: `xcodebuild -scheme GrappleMac -configuration Release archive`
- [ ] App validated: `xcodebuild -exportArchive`
- [ ] Uploaded to App Store Connect: `xcodebuild -exportArchive -archive path -exportOptionsPlist ...`
- [ ] Build appears in App Store Connect

### Review Submission
- [ ] All App Store information complete
- [ ] Demo account credentials provided (if required — N/A for local AI app)
- [ ] Notes to reviewer: "GrappleMac uses local AI inference. No backend or account required. All data stored locally."
- [ ] Contact email verified
- [ ] Submitted for review

---

## 📋 Post-Launch

### Monitoring
- [ ] App Store Connect: Monitor for "Ready for Sale" status
- [ ] Set up TestFlight beta track for future external testing
- [ ] Monitor for any crash reports or feedback

### Announcements
- [ ] Announce on social media (X, LinkedIn, etc.)
- [ ] Update any personal website or portfolio
- [ ] Consider posting in relevant communities (philosophy, productivity, indie dev)

### Future Features (Backlog)
- [ ] i18n / localization
- [ ] Custom debate templates
- [ ] Export debates as PDF
- [ ] iOS companion app
- [ ] Cloud sync (optional, privacy-preserving)
- [ ] GrappleMac Lite (menu bar only mode)
- [ ] Custom model support (connect local Ollama, etc.)

---

## 📐 Design QA Notes

### Aesthetic Direction: Academic Court
- **Navy** (#0F1419 dark, #1A2332 surface, #243044 elevated) — authority, gravity
- **Cream** (#8B9BB4 as secondary text) — parchment warmth, timelessness
- **Gold** (#D4AF37 accent) — achievement, intellectual merit, champion status

### Typography Rules
- **Arguments & rebuttals**: `.system(size:, design: .monospaced)` — precision, code-like rigor
- **UI labels, headers**: `.system(size:, weight:, design: .default)` — clean, authoritative
- **Never mix serif body + sans UI** — keep reading context consistent within a card

### Debate Stage Colors
| Stage | Accent Color | Meaning |
|-------|-------------|---------|
| Input | none | Neutral — you're in control |
| Challenge | `#E63946` (red) | Attack — your claim is being tested |
| Rebuttal | `#4A90D9` (blue) | Defense — respond to the challenge |
| Synthesis | `#52B788` (green) | Resolution — verdict rendered |

### Gold Accent Usage
- Champion badges and tournament winner highlights
- "Featured" badges on Challenge leaderboard
- Outcome badge for `.strong` sessions
- Prize/achievement indicators

---

*GrappleMac R13 — Polish & Launch*
