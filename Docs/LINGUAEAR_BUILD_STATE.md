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