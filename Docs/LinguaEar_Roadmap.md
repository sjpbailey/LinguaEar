# LinguaEar Project Roadmap

---

## 1. Version 1.0 — Completed
- iPhone real-time translator (manual + auto-detect)
- Watch translator (simple version)
- Azure translator integration
- TTS speech playback
- Daily usage limit system
- Privacy Policy / Support Pages
- GitHub repository + .gitignore
- App Store metadata + screenshots
- TestFlight submission

---

## 2. Version 2 — Conversation Mode (NEW CORE FEATURE)
### Goals
- Turn LinguaEar into a **conversation assistant**, not just a translator
- Allow users to:
  - Speak naturally (even imperfectly)
  - Get translations
  - Receive natural reply suggestions
  - Continue a conversation without restarting

### Current Features
- Speak → translate → suggest reply
- Listen to translated phrase
- Speak reply back
- Adjustable playback speed (learning vs natural)

### In Progress
- Conversation loop (continuous back-and-forth)
- Button simplification (Listen / Reply / Speak Reply)
- Remove duplicate controls
- Improve natural phrasing (remove robotic prompts)

### Next Enhancements
- “Another Reply” (multiple variations)
- Conversation continuity (context-aware replies)
- Better anticipation of user intent
- Cleaner UI separation (you vs AI response)

---

## 3. Version 2 — Watch “Walkie-Talkie Mode”
### Goals
- Live voice stream from Watch A → translate → Watch B
- Push-to-talk UI
- Auto-detect spoken language
- Fast, short-phrase optimized translation
- Reliable in noisy environments

### Components
- WatchConnectivity pipeline
- Streaming / chunked translation
- Mini-TTS playback
- Visual indicators (listening / sending / receiving)

---

## 4. Version 2 — iOS Enhancements
### UI/UX
- Larger microphone UI (primary interaction)
- Cleaner conversation layout
- Reduced button clutter
- Clear conversation vs learning modes

### Functionality
- Auto-detect input language in Conversation Mode
- Multi-language support (speak one → reply in another)
- Improved speech clarity and playback tuning
- Tap-to-hear word (future)

---

## 5. Version 3 — Group & Multi-Device Features
- Multi-person conversation mode (2–4 users)
- Nearby Conversations expansion
- Per-device language settings (I Speak / I Hear)
- Wi-Fi direct fallback
- Priority speaker handling

---

## 6. Future Ideas
- AI tutoring assistant (guided learning)
- Conversation summaries
- Context-aware replies (multi-turn memory)
- Live call translation (VoIP)
- Passive listening mode (meetings/restaurants)
- Travel mode / kid mode presets

---

## 7. Business Model
- Premium subscription unlocks:
  - Unlimited translations
  - Faster processing
  - Advanced conversation features (AI replies, multi-turn)
  - Offline phrasebook (future)
- Free tier:
  - Daily translation limit (100–150)
  - Core features
- Annual pricing option

---

## 8. GitHub Development Workflow
- `main` → stable release
- `v2.2.0-ai` → conversation AI development
- Feature branches for enhancements
- Pull requests with review checklist
- Tagged releases:
  - `v2.1.0`
  - `v2.2.0-ai`
  - future versions

---

## 9. Tracking & Documentation
- `/Docs` folder:
  - Roadmap.md
  - ArchitectureDiagram.md
  - APINotes.md
  - AppStoreMetadata.md
  - PrivacyPolicy.md
- GitHub Projects / Kanban (optional)
- Milestones per release

---

## 10. Long-Term Vision
- Real-time conversation assistant across devices
- “Talk naturally anywhere” experience
- Multi-language understanding (auto-detect + reply)
- On-device intelligence (future)
- Expand to iPad, Mac, Vision Pro

---

*Updated: March 2026*