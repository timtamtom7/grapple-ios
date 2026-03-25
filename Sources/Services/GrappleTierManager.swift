import Foundation

/// R10: Subscription tier management
final class GrappleTierManager: @unchecked Sendable {
    static let shared = GrappleTierManager()

    private let freeGrapplesPerMonth = 3
    private let userDefaultsKey = "grapple_tier_monthly_count"
    private let lastResetKey = "grapple_tier_last_reset_month"

    private init() {
        checkAndResetMonth()
    }

    // MARK: - Tier

    var isPro: Bool {
        UserDefaults.standard.bool(forKey: "grapple_is_pro")
    }

    var isFreeTier: Bool {
        !isPro
    }

    // MARK: - Usage Tracking

    var monthlyGrappleCount: Int {
        get { UserDefaults.standard.integer(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }

    var remainingFreeGrapples: Int {
        guard isFreeTier else { return Int.max }
        return max(0, freeGrapplesPerMonth - monthlyGrappleCount)
    }

    var isLimitReached: Bool {
        guard isFreeTier else { return false }
        return monthlyGrappleCount >= freeGrapplesPerMonth
    }

    var usageDescription: String {
        if isPro {
            return "Pro · Unlimited grapples"
        } else {
            return "Free · \(remainingFreeGrapples) grapple\(remainingFreeGrapples == 1 ? "" : "s") remaining this month"
        }
    }

    // MARK: - Record Usage

    func recordGrappleUsed() {
        guard isFreeTier else { return }
        monthlyGrappleCount += 1
    }

    // MARK: - Upgrade

    func setPro(_ isPro: Bool) {
        UserDefaults.standard.set(isPro, forKey: "grapple_is_pro")
    }

    // MARK: - Month Reset

    private func checkAndResetMonth() {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)

        let lastResetMonth = UserDefaults.standard.integer(forKey: lastResetKey)

        if lastResetMonth != currentMonth {
            // New month - reset counter
            monthlyGrappleCount = 0
            UserDefaults.standard.set(currentMonth, forKey: lastResetKey)
        }
    }

    // MARK: - Restore Purchases (placeholder)

    func restorePurchases() async -> Bool {
        // In real app, this would call StoreKit to restore purchases
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return isPro
    }
}

// MARK: - Subscription Tier

enum SubscriptionTier: String, CaseIterable {
    case free = "Free"
    case pro = "Pro"

    var grappleLimit: Int {
        switch self {
        case .free: return 3
        case .pro: return Int.max
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .pro: return "$4.99/mo"
        }
    }
}
