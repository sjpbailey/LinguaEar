# LinguaEar — BUILD STATE (Authoritative)

> This file is the single source of truth for LinguaEar project state.
> Any new work or new chat session MUST resume from here.

---

## PROJECT
- App: LinguaEar
- Platform: iOS + watchOS
- Repo: LinguaEar (Private)
- Primary Branch: main
- Active Dev Branch: v2.2.0-ai

---

## CURRENT FOCUS
Version 2.2 — Conversation Mode (AI Talker)

Transform LinguaEar from a translator into a **conversation assistant**:
- Speak naturally
- Translate
- Suggest replies
- Continue conversation

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
- ✅ Translation pipeline (Azure)
- ✅ Speech recognition working
- ✅ TTS playback working
- ✅ ConversationPracticeView UI functional
- ✅ Reply suggestion system (rule-based)
- ✅ Navigation to Conversation screen added
- ✅ Support.md updated for Conversation Mode
- ✅ Roadmap updated to include Conversation AI

---

## WHAT IS IN PROGRESS
- ⏳ Conversation loop (continuous back-and-forth without reset)
- ⏳ Remove duplicate / confusing buttons
- ⏳ Improve reply naturalness (remove robotic phrasing)
- ⏳ Fix TTS speed consistency across views
- ⏳ Clarify UI flow (reduce cognitive load)

---

## NEXT STEPS (DO NOT SKIP ORDER)
1. Fix duplicate "Speak" buttons (keep only one)
2. Implement conversation loop:
   - After reply → allow immediate continued input
3. Clean UI labels:
   - Remove "I might say"
   - Simplify instructions
4. Verify TTS speed matches ListenPractice
5. Test real conversation flow (multi-turn)
6. Decide when to introduce real AI backend (optional)

---

## FUTURE (NEAR TERM)
- Auto-detect input language in Conversation Mode
- Multi-language conversation support
- “Another Reply” button (variation generation)
- Suggested follow-up phrases
- Context-aware replies (multi-turn memory)

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

### IMMEDIATE TASKS (NEXT SESSION, IN ORDER)

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