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

## 4. Version 3 — Group & Multi-Device Features
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
  - `v4.1.0-Localization`
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

## 3. Version 3 — Core Experience (CURRENT)

### Goals
- Make LinguaEar simple, clear, and usable immediately
- Separate core modes cleanly:
  - Translate
  - Practice
  - Nearby Conversations
- Improve navigation and reduce confusion

### Features
- Welcome screen as entry point
- Practice (Listen & Repeat) as a first-class feature
- Category-based phrase practice
- Language selection inside Practice
- Nearby Conversations (multi-device translation)
- Consistent I Speak / I Hear model across all modes

### In Progress
- Auto-detect input in Nearby Conversations
- Phrase chunking cleanup (punctuation filtering)
- UI polish and spacing consistency
- Screenshot preparation for App Store

### Outcome
- App feels simple and obvious
- Users understand what to do without instructions
- Strong foundation for AI (v4)

*Updated: March 2026*

⸻

## 11. Version 4.1 — AI Conversation (FOUNDATION BUILD)

Goals
•	Introduce real conversational intelligence
•	Move from:
•	translation tool ❌
→ to
•	conversation partner ✅
•	Start simple: English-only AI first (controlled environment)

⸻

Core Features

## 🧠 AI Conversation Practice (NEW)
•	Natural back-and-forth conversation
•	User speaks → AI responds naturally
•	No translation required (pure English mode)
•	Focus on:
•	flow
•	realism
•	confidence building

⸻

## 💬 Smart Reply Engine (v1)
•	Context-aware responses (basic memory of last input)
•	Variation system (avoid repeating same replies)
•	Tone:
•	friendly
•	simple
•	conversational (not robotic)

⸻

## 🎯 Conversation Loop
•	Continuous interaction:
•	Speak → AI responds → Speak again
•	No reset between turns
•	Lightweight session memory (last 1–3 messages)

⸻

## UI Additions

New Entry Point
•	“Conversation Practice” button (already added ✅)
•	Dedicated screen (ConversationPracticeView)

## Controls
•	Tap to speak
•	Suggest Answer
•	Hear Translation (optional later)
•	Clear conversation

⸻

Platform Behavior

## iPhone
•	Full experience (primary platform)

## Mac
•	Enable with microphone present
•	Graceful fallback if no mic:
•	disable mic button
•	show message

⸻

# In Progress (Next Steps)
•	Replace static responses with AIConversationService logic
•	Improve response selection (remove obvious patterns)
•	Add basic memory (last user + last AI reply)
•	Tune response tone (short, natural)

⸻

## Next Enhancements (4.1.x)
•	“Another Reply” button (variation generation)
•	Adjustable personality:
•	casual
•	professional
•	helpful tutor
•	Speech speed matching (AI adapts to user speed)
•	Error tolerance (handle broken English better)

⸻

## Future Expansion (4.2+)
•	Multi-language AI conversation
•	Translate + respond (hybrid mode)
•	Real-time bilingual conversation assistant
•	Voice-only continuous mode (hands-free)

⸻

🧠 ADD TO “TECH NOTES / TODO”

## ⚙️ Stability
•	Detect microphone availability (Mac fix)
•	Prevent crash when no input device
•	Disable mic UI when unavailable

⸻

## 🧪 Testing
•	iPhone real conversation flow
•	Mac + headphones validation
•	Nearby + AI coexistence (no conflicts)

*Updated: April 1st 2026*