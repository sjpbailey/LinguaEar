LinguaEar – BUILD STATE

Last updated: 2025-12-17

⸻

Overall Status (Source of Truth)
    •    LinguaEar v1 (Free)
    •    App Store submission: 1.0.1 (Build 4)
    •    Status: Waiting for Apple review / processing
    •    Azure credentials: updated and working
    •    Live store build prior to approval may still reference old keys (expected until approval)
    •    LinguaEar v2 (Practice / Paid path)
    •    TestFlight: Active and working
    •    Azure credentials: updated and working
    •    Not yet submitted to App Store (intentional)
    •    BreathingBP (separate app)
    •    Bluetooth removed (BLEManager deleted)
    •    Resolution Center response sent
    •    New build archived and submitted
    •    Status: Waiting on Apple review

⸻

LinguaEar – Version Details

App Store (Production)
    •    Version: 1.0.1
    •    Build: 4
    •    Platforms:
    •    iPhone: ✅
    •    watchOS companion: ✅
    •    iPad: ❌ removed
    •    visionOS: ❌ removed
    •    Encryption: Standard (declared)
    •    Status: Processing / Waiting for Review

TestFlight
    •    LinguaEar v2 builds: Available
    •    State: Confirmed working (translation + TTS)

⸻

Azure / Backend
    •    Translator resource: Re-created on paid tier
    •    Keys: Stored in Secrets.swift (gitignored)
    •    Status: Stable
    •    No action required unless billing is disabled or keys are manually regenerated

⸻

What NOT To Do
    •    ❌ Do not regenerate Azure keys
    •    ❌ Do not change bundle IDs
    •    ❌ Do not submit LinguaEar v2 to App Store yet
    •    ❌ Do not re-add iPad or visionOS targets

⸻

Next Actions (When Apple Responds)

When LinguaEar 1.0.1 (Build 4) Is Approved
    1.    Verify App Store live version updates
    2.    Confirm Azure translation works in production
    3.    No further action required for v1

After LinguaEar v1 Is Live (Planned)
    •    Add Filipino / Tagalog (tl) language support
    •    Prepare LinguaEar v2 (practice-focused)
    •    Decide pricing model (likely yearly with trial)
    •    Archive and submit v2 as paid upgrade

⸻

Notes / Ground Rules
    •    This file is the single source of truth
    •    Resume from here if a chat resets
    •    Do not revisit Azure/App Store history unless status changes

⸻

End of BUILD_STATE.md
