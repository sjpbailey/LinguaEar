# LinguaEar — BUILD STATE (Authoritative)

> This file is the single source of truth for LinguaEar project state.
> Any new work or new chat session MUST resume from here.

---

## PROJECT
- App: LinguaEar
- Platform: iOS + watchOS
- Repo: LinguaEar (Private)
- Primary Branch: main
- Active Dev Branch: v3.1-navigation

---

## CURRENT FOCUS
Version 3.1 — Navigation, Practice, and Core UX Stabilization

Focus:
- Clean navigation and user flow
- Elevate Practice as a first-class feature
- Ensure consistent language model across app
- Prepare foundation for AI (v4)

## CORE APP STRUCTURE (CURRENT)

LinguaEar now has three primary modes:

1. Translate (ContentView)
   - Real-time speech translation
   - Quick phrases
   - Paste & translate

2. Practice (ListenRepeatPracticeView)
   - Listen & repeat learning
   - Category-based phrases
   - Pronunciation helper (Romaji / chunking)

3. Nearby Conversations
   - Multi-device translation
   - Per-device I Speak / I Hear
   - Future: auto-detect input

Design rule:
- Each mode is independent but follows the same language model


---

## LAST KNOWN GOOD STATE
- Version 2.1.0 submitted to App Store review
- TestFlight build installed and verified working
- ConversationPracticeView compiles and runs
- Buttons functional:
  - Listen Phrase
  - Get Reply
  - Speak Reply
- Rule-based reply system implemented (no external AI yet)
- Playback speed adjustable (slow / normal)
- Major brace/scope issues resolved

---

## WHAT IS COMPLETE
- ✅ Practice moved out of ContentView and into Welcome
- ✅ Native navigation (removed custom back button)
- ✅ Practice language selector added
- ✅ Practice category system implemented
- ✅ Romaji / chunking system working across languages
- ✅ Limiter validated across views

---

## WHAT IS IN PROGRESS
- ⏳ Nearby Conversations auto-detect input
- ⏳ Minor UI polish in Practice (spacing, labels)
- ⏳ Phrase chunking cleanup (punctuation filtering)
- ⏳ Final navigation polish consistency across devices

---

## NEXT STEPS (DO NOT SKIP ORDER)

1. Fix punctuation chunking in Practice (remove stray tokens like ",")
2. Add auto-detect input option to Nearby Conversations
3. Verify Nearby limiter behavior matches other views
4. Polish Practice UI (spacing, clarity, labels)
5. Capture new App Store screenshots (new navigation flow)
6. Light usability testing (non-technical users)


---

## HARD RULES
- Do NOT merge v2.2.0-ai into main until stable
- Do NOT mix Conversation Mode with ListenPractice logic
- Do NOT add new features until flow is correct
- Always test like a real user (not developer mindset)
- Always update this file when stopping work

---

## LAST UPDATE
- Date: March 2026
- By: Steven + ChatGPT
- Reason: Introduced Conversation AI mode and restructured app direction

---

## 🔧 ACTIVE DEVELOPMENT NOTES — Conversation AI (v2.2.0-ai)

### CURRENT GOAL
Stabilize and refine Conversation Mode into a natural, continuous AI-assisted conversation experience that feels like talking to a person, not using a tool.

---

### WHAT WAS COMPLETED THIS SESSION

1. **Conversation Mode UI stabilized**
   - ConversationPracticeView now builds and runs reliably
   - Major brace/scope/body issues were resolved
   - Buttons are now positioned near the mic and flow better

2. **Control buttons cleaned up**
   - Removed extra confusing speak button
   - Current active controls are:
     - Hear Translation
     - Suggest Answer
     - Hear Answer
     - Clear

3. **Clear / Reset added**
   - Clear button now resets:
     - messages
     - currentExpectedPhrase
     - aiReply
     - aiReplyTranslation
     - loading state
     - scoring remnants
     - status text

4. **Reply preview improved**
   - Suggested answer now shows in target language
   - Reverse translation back to native language was added under the suggested answer
   - Preview now clears after commit so it does not look like a duplicate bug

5. **Playback state improved**
   - Slow / Normal visual state now works correctly
   - Current view uses .25 / .50 selection model like ListenPractice
   - Remaining chipmunk-speed issue is likely inside TextToSpeechManager or Apple voice behavior, not this screen

6. **Rule-based bot upgraded**
   - AIConversationService was replaced with a smarter rule-based reply engine
   - Added better categories for:
     - greeting
     - how are you
     - love / affection
     - thanks
     - help
     - directions
     - compliments
     - weather / day
     - yes / no
     - questions
   - Reverse translation of bot replies is now working

7. **Conversation Mode direction clarified**
   - This screen is NOT ListenPractice
   - This screen is a conversation helper / AI talker
   - Scoring should remain in ListenPractice, not main Conversation flow

---

### IMMEDIATE TASKS (NEXT SESSION, IN ORDER FOR AI)

1. **Improve Bot Intelligence**
   - Reduce generic overuse of:
     - "Buena pregunta."
     - "Entiendo. Cuéntame más."
   - Add stronger intent buckets for:
     - directions
     - opinions
     - plans
     - weather
     - compliments
     - confirmations
     - apologies
     - small talk
   - Add 3–5 reply variations per bucket

2. **Improve Reply Quality**
   - Make replies fit meaning more naturally
   - Example goals:
     - "What do you think?" → opinion-style answer
     - "Where do you turn to get to the theater?" → directional answer
     - "It’s a great day..." → weather/day answer
   - Avoid smart-aleck generic fallback unless truly needed

3. **Improve Conversation Continuity**
   - Continue building true back-and-forth behavior
   - Store light context:
     - last user input
     - last translated phrase
     - last bot reply
     - optional last intent
   - Use that context to shape next reply

4. **Clean Remaining UI Text**
   - Replace old text such as:
     - "I might say"
     - "Tap Listen Phrase, Get Reply..."
   - Make all wording match final controls:
     - Hear Translation
     - Suggest Answer
     - Hear Answer

5. **TTS Speed Investigation**
   - Confirm TextToSpeechManager is not overriding rate unexpectedly
   - Check whether selected Spanish voice is inherently too fast
   - Clamp real utterance rates if necessary

---

### NEXT FEATURES (SHORT TERM)

6. **Auto-Detect Input Language**
   - Add toggle: I Speak = Auto / Manual
   - Reuse existing ContentView auto-detect logic
   - Apply to:
     - Conversation Mode
     - Nearby Conversations

7. **Unify Language Model (CORE RULE)**
   - Every mode MUST use the same model:

     **I Speak**
     - Manual language selection OR
     - Auto-detect (when enabled)

     **I Hear**
     - User-selected target language (NEVER auto-changed)

   - Behavior:
     - Input → detect or use I Speak
     - Output → ALWAYS convert to I Hear

   - Applies to:
     - Conversation Mode
     - Nearby Conversations
     - Main Translator

   - RULES:
     - Auto-detect ONLY affects input
     - I Hear ALWAYS controls output
     - Never override user’s I Hear selection

8. **Improve Reply System Further**
   - Add "Another Answer" button
   - Add optional suggested follow-up:
     - "You could say..."
   - Prepare for real AI backend integration later

---

### NEARBY CONVERSATIONS ALIGNMENT

9. **Enhance Nearby Conversations**
   - Add auto-detect input option
   - Maintain per-device:
     - I Speak
     - I Hear
   - Improve connection clarity and reliability

---

### DESIGN PRINCIPLES (DO NOT BREAK)

- Conversation Mode ≠ ListenPractice
- Do NOT mix scoring into main conversation flow
- Keep UI simple and understandable
- App should feel like talking to a person, not using a tool
- Always test like a real user, not a developer
- Bot preview should help, not confuse
- Reverse translation should clarify, not clutter

---

### TESTING CHECKLIST

- Can user:
  - Speak → get translation → get suggested answer → hear answer?
- Does reverse translation help user understand the bot reply?
- Are buttons clear and non-redundant?
- Does Clear reliably reset session state?
- Is playback speed visually correct?
- Does flow feel natural without explanation?
- Are replies more specific than generic fallback?

---

### NOTES

- Conversation Mode is still DEV ONLY and NOT in App Store release 2.1.0
- Safe to iterate freely in `v2.2.0-ai`
- App Store description/support text for AI helper should wait until feature is stable
- Current milestone achieved:
  - UI shell works
  - controls work
  - reverse translation works
  - next focus = smarter bot brain

  ### COMPLETED (v3.1-navigation Navigation Work)

1. **Add Practice Speaking button to Welcome**
   - Add a new visible button on `WelcomeView`
   - Place it above `Nearby Conversations`
   - Use a different color from Translate and Nearby
   - Goal: expose Listen & Repeat as a first-class feature

2. **Test Welcome → Listen & Repeat launch**
   - Confirm the new button opens `ListenRepeatPracticeView`
   - Do not remove old entry point yet
   - Verify app still builds and runs cleanly

3. **Comment out old Listen & Repeat entry in `ContentView`**
   - Leave code in place, just `//` it out first
   - Rebuild and test
   - Confirm Practice is now reached from Welcome only

4. **Fix navigation / back behavior**
   - Current issue: Done/dismiss returns to `ContentView`
   - Update presentation flow so Practice entered from Welcome returns correctly
   - Prefer clean navigation behavior over temporary hacks

5. **Add language control to Listen & Repeat**
   - Practice should not rely only on language state from `ContentView`
   - Add its own language selector or clean passed-in setting
   - Goal: make Practice more independent and easier to launch directly

6. **Keep Quick Phrases in `ContentView`**
   - Do not move Quick Phrases
   - Only expose Listen & Repeat separately from Welcome

7. **Review Nearby Conversations flow after navigation changes**
   - Keep current Nearby working
   - Later goal: consider auto-detect for spoken language in Nearby
   - Do not touch Nearby auto-detect until navigation and Practice are stable

8. **Prepare screenshot-worthy navigation flow**
   - Once Welcome + Practice are working cleanly, capture new screenshots
   - Focus on clearer product story:
     - Start Translating
     - Practice Speaking
     - Nearby Conversations

### RELEASE TRACK NOTE

- `v3.1-navigation` = navigation, Practice visibility, language control, Nearby polish, screenshot prep
- `v4.0-ai` = AI conversation rebuild and future bot work
- Do not mix v4 AI scope into v3.1 navigation work


---

## FUTURE (v4 — AI Conversation Layer)

Conversation AI will transform LinguaEar from a translator into a true conversation assistant.

Planned capabilities:
- Speak naturally → translate → suggest replies → continue conversation
- Multi-turn conversation with context memory
- Intent-based reply generation
- “Another Reply” variations
- Suggested follow-up phrases

Future enhancements:
- Auto-detect input language in Conversation Mode
- Multi-language conversation support
- Context-aware replies across multiple turns

Notes:
- This is NOT part of v3.1-navigation
- This work remains in branch: v2.2.0-ai
- Do not mix AI work into navigation / Practice branch


## DAILY LOG — March 27, 2026

- Worked on navigation + Practice separation
- Added Practice to Welcome and removed from ContentView
- Added language + category to Practice
- Fixed romaji / chunking behavior
- Validated limiter across views and Pro upgrade
- Cleaned up navigation (native back arrow)

Next:
- Fix punctuation chunking
- Add auto-detect to Nearby
- UI polish + screenshots

Notes:
- Korean chunking works (not romaji)
- Limiter clamps around 5–6 (acceptable for now)

Yes — 100% do this. This is exactly what Build State is for 👍
I’ll give you a clean section you can paste at the bottom.

⸻

🔧 ADD THIS TO BUILD STATE

🚀 RELEASE STATUS — Version 3.1.0

## CURRENT STATE
•	Version 3.1.0 (Build 1) uploaded to App Store Connect
•	Submitted for TestFlight Beta Review
•	Testers added (internal group ready)

⸻

## WHAT WAS COMPLETED
•	Navigation fully restructured and stabilized
•	Practice mode elevated to primary feature (from Welcome)
•	Nearby Conversations validated and stable
•	Translation pipeline verified (manual + auto-detect)
•	Auto-response mode tested and functional
•	Daily limiter tested across multiple views
•	Screenshot set created and finalized:
•	Nearby Conversations (4)
•	Practice (3)
•	Translator (3)
•	Quick Phrases (2)

⸻

## WHAT IS BEING VALIDATED (TestFlight)
•	Real-device Nearby Conversations (multi-phone)
•	Practice flow across languages and categories
•	Translator behavior (auto-detect ON/OFF)
•	Auto-response usability
•	UI/UX clarity for new users
•	Limiter behavior under normal usage

⸻

## NEXT STEP (AFTER TESTFLIGHT APPROVAL)
1.	Install and test build via TestFlight
2.	Final UI/UX sanity pass (real-user perspective)
3.	Move to App Store Distribution
4.	Replace screenshots with new finalized set
5.	Finalize App Store metadata (title, subtitle, description)
6.	Submit for App Review

⸻

## FUTURE TRACKS (LOCKED)
•	Localization (Welcome + Quick Phrases + core UI)
•	Pro / Professional tier:
•	AI Conversation Mode (v4)
•	Advanced Watch features
•	Smarter phrase system (multi-language input)

⸻

## NOTES
•	This release marks transition from:
•	“Translator app”
•	→ Communication + Learning platform
•	Do not introduce new features until 3.1.0 is fully validated and released

⸻

🟢 Why this is important

## This does 3 things:
1.	You can resume instantly in any new chat
2.	You don’t lose release context
3.	You stay disciplined (no scope creep)

⸻

 *March 30th 2026*


⸻

### 🚀 RELEASE UPDATE — Version 3.1.0 (APPROVED & LIVE)

## CURRENT STATE

• Version 3.1.0 approved by App Review
• Status: Ready for Distribution → LIVE
• Verified on:
• iPhone (App Store + device install)
• Mac (desktop install + runtime validation)

⸻

## WHAT WAS COMPLETED (POST-SUBMISSION)

• App successfully passed App Review (fast approval)
• Final screenshots accepted (no rejection issues)
• App Store metadata validated live
• Navigation and UI confirmed stable in production build
• New Welcome screen + button layout verified
• Conversation Practice entry point added (v4 foundation)

⸻

## VALIDATION RESULTS

• iPhone:
• Translation working (manual + auto-detect)
• Practice mode working
• Nearby Conversations working across devices
• Mac:
• App runs successfully
• Nearby Conversations confirmed working
• Microphone-dependent features require input device (expected behavior)

⸻

## KNOWN ISSUES / NOTES

• Mac:
• App requires microphone input device (headphones or external mic)
• No-mic condition can cause failure → needs graceful handling
• UI:
• Button sizing issue resolved (modifier scope fix)
• Dev:
• Xcode diff mode caused false duplicate line behavior (resolved)

⸻

## NEXT STEP (ACTIVE DEVELOPMENT — v4.1)
	1.	Begin AI Conversation integration (English-only first)
	2.	Replace static replies with AIConversationService
	3.	Implement conversation loop (multi-turn)
	4.	Add mic availability guard (Mac stability fix)
	5.	Improve Conversation Practice UX (flow + realism)
   🚧 PARALLEL TRACKS (ADDED)

## 🌍 Localization (IN PROGRESS)
	• Expand beyond English-only UI
	• Localize:
	• Welcome screen
	• Quick Phrases (all categories)
	• Core UI labels (I Speak / I Hear / buttons)
	• Goal:
	• App feels native in each language
	• Strategy:
	• Start with phrase system → expand to UI strings

⸻

## 🔄 Nearby Conversations — Auto Detect (PLANNED)
	• Add auto-detect spoken language in Nearby mode
	• Remove need for strict I Speak setting
	• Improve real-world usability:
	• Mixed-language conversations
	• Faster onboarding (no setup friction)
	• Maintain per-device “I Hear” output

⸻

## ⌚ Watch 2.0 — WOW FEATURE (PLANNED)
	• Upgrade Watch app from:
	• simple translator → real-time conversation tool

	• Goals:
	• Walkie-talkie style interaction
	• Push-to-talk translation between devices
	• Fast response loop (low latency)
	• Minimal UI (tap, speak, hear)

	• Role in product:
	• Key differentiator for Pro tier
	• “Show people → instant wow”

⸻

## FUTURE TRACKS (UPDATED)

• AI Conversation Mode now ACTIVE (v4.1 branch)
• Localization expansion (phrases + welcome)
• Pro tier refinement (AI + limits + features)

⸻

## NOTES

• This marks transition from:
• “Working release”
→ “Live product with active user experience”
• First successful full cycle:
• Build → Submit → Approve → Live → Validate
• Foundation for AI now in place (Conversation Practice entry)

⸻

*April 1st 2026*

