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
Stabilize and refine Conversation Mode into a natural, continuous AI-assisted conversation experience.

---

### IMMEDIATE TASKS (IN ORDER)

1. **Fix Conversation Loop**
   - After "Speak Reply", allow immediate continued input
   - Do NOT reset conversation state
   - Ensure user can speak again without restarting

2. **Remove Duplicate Buttons**
   - Remove "Speak This..." button
   - Keep only:
     - Listen Phrase
     - Reply
     - Speak Reply

3. **Simplify UI Text**
   - Remove "I might say"
   - Use natural phrasing only (no robotic prompts)
   - Improve statusText guidance

4. **Fix TTS Speed Consistency**
   - Match ListenPractice behavior (.25 / .50)
   - Verify TextToSpeechManager is not overriding rate
   - Ensure Spanish voice is understandable at normal speed

5. **Clean Conversation Flow**
   - Speak → Translate → Reply → Continue
   - No forced practice or scoring in main flow
   - Practice remains optional and secondary

---

### NEXT FEATURES (SHORT TERM)

6. **Auto-Detect Input Language**
   - Add toggle: I Speak = Auto / Manual
   - Use existing ContentView auto-detect logic
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
     - Conversation Mode (AI talker)
     - Nearby Conversations (multi-device)
     - Main Translator

   - Example:
     - I Speak: Auto
     - I Hear: Spanish
     - User speaks English → Spanish output
     - User speaks Spanish → Spanish stays Spanish (or optionally normalized)

   - RULES:
     - Auto-detect ONLY affects input
     - I Hear ALWAYS controls output
     - Never override user’s I Hear selection
     
8. **Improve Reply System**
   - Expand rule-based replies (short-term)
   - Add "Another Reply" button
   - Prepare for real AI backend integration (later)

9. **Add Suggested Follow-Up (Optional)**
   - Small hint under reply:
     - "You could say..."
   - Helps users continue conversation naturally

---

### NEARBY CONVERSATIONS ALIGNMENT

10. **Enhance Nearby Conversations**
   - Add auto-detect input option
   - Maintain per-device:
     - I Speak
     - I Hear
   - Improve reliability and clarity of connection flow

---

### DESIGN PRINCIPLES (DO NOT BREAK)

- Conversation Mode ≠ ListenPractice
- Do NOT mix scoring into main conversation flow
- Keep UI simple (max 3 main buttons)
- App should feel like talking to a person, not using a tool
- Always test like a real user (not developer mindset)

---

### TESTING CHECKLIST

- Can user:
  - Speak → get translation → get reply → continue?
- Does conversation continue without reset?
- Are buttons clear and not redundant?
- Is speech speed understandable?
- Does flow feel natural without explanation?

---

### NOTES

- Conversation Mode is NOT yet in App Store release (2.1.0)
- Safe to iterate freely in v2.2.0-ai branch
- App Store description will be updated AFTER feature is stable