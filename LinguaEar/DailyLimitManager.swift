import Foundation

final class DailyLimitManager {

    static let shared = DailyLimitManager()

    // MARK: - Config

    /// Free translations per day, per device
    private let maxPerDay = 150

    // MARK: - Storage keys

    private let countKey = "LE_DailyTranslationCount"
    private let dateKey  = "LE_DailyTranslationDate"

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Public API

    /// Try to consume one translation from today's quota.
    /// - Returns: `true` if allowed (and increments count), `false` if limit already reached.
    @discardableResult
    func consumeOneIfAvailable() -> Bool {
        resetIfNewDay()

        let current = defaults.integer(forKey: countKey)
        guard current < maxPerDay else {
            return false
        }

        defaults.set(current + 1, forKey: countKey)
        return true
    }

    /// How many translations are left for today on this device.
    func remainingToday() -> Int {
        resetIfNewDay()
        let current = defaults.integer(forKey: countKey)
        return max(0, maxPerDay - current)
    }

    /// The configured maximum per-day
    func maxPerDayLimit() -> Int {
        return maxPerDay
    }

    // MARK: - Helpers

    /// Reset count if the stored date is not "today".
    private func resetIfNewDay() {
        let todayString = Self.dayString(for: Date())

        if let storedDate = defaults.string(forKey: dateKey),
           storedDate == todayString {
            // same day, nothing to do
            return
        }

        // new day or first run: reset
        defaults.set(0, forKey: countKey)
        defaults.set(todayString, forKey: dateKey)
    }

    private static func dayString(for date: Date) -> String {
        // YYYY-MM-DD; we don't care about time, only day boundary
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
