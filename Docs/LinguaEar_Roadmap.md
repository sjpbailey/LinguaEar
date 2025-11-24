
# LinguaEar Project Roadmap

## 1. Version 1.0 — Completed
- iPhone real-time translator (manual + auto-detect)
- Watch translator (simple version)
- Azure translator integration
- TTS speech playback
- Daily usage limit system
- Privacy Policy / Support Pages
- GitHub repository + .gitignore
- App Store metadata + screenshots
- TestFlight submission (pending approval)

---

## 2. Version 2 — Watch “Walkie-Talkie Mode”
### Goals
- Live voice stream from Watch A → translate → Watch B
- Auto-detect spoken language
- Push-to-talk UI
- Automatic switching (they speak → translate → send)
- Background audio session improvements
- Reliability in noisy environments

### Components
- WatchConnectivity pipeline
- New translator microflow (short sentence optimized)
- Mini-TTS on receiver side
- Visual signal indicators (listening / sending / receiving)

---

## 3. Version 2 — iOS Enhancements
### UI/UX
- Larger microphone UI
- Animated Bud icon intro animation
- Improved quick-phrase layout
- Handoff between phone ↔ watch

### Functionality
- Offline phrasebook engine
- Phrase learning mode (“repeat after me”)
- Correct pronunciation scoring

---

## 4. Version 3 — Group Features
- Multi-person Walkie-Talkie mode
- Group translation bubble (up to 4)
- Wi-Fi direct fallback when LTE unavailable
- Priority speaker mode

---

## 5. Future Ideas
- Language tutoring assistant
- Conversation summary logs
- Live call translation (VoIP)
- Share translations with AirDrop
- “Auto Listen” passive mode for restaurants/meetings
- Kid mode + travel mode presets

---

## 6. Business Model
- Premium subscription unlocks:
  - Unlimited translations
  - Faster Azure tier
  - Walkie-Talkie mode
  - Offline phrasebook
- Free tier:
  - 50–150 translations/day
  - Core features
- Annual discount pricing

---

## 7. GitHub Development Workflow
- `main` → V1 stable
- `walkie-talkie-v2` → Watch V2 branch
- `ios-enhancements-v2` → iPhone V2 branch
- Pull requests with checklists
- Automatic test scaffolding (later)
- Release tags:
  - `v1.0.0`
  - `v2.0.0-beta`
  - etc.

---

## 8. Tracking & Documentation
- `/Docs` folder:
  - Roadmap.md (this file)
  - ArchitectureDiagram.md
  - APINotes.md
  - AppStoreMetadata.md
  - PrivacyPolicy.md
- GitHub Projects Kanban
- Weekly milestones (optional)

---

## 9. Long-Term Vision
- Wearable-to-wearable universal translator
- Offline neural translation (on-device)
- Multi-device sync
- Expand to iPad, Mac, VisionPro

---

*Updated: November 23, 2025*
