import Foundation

public struct DailySummary: Equatable, Sendable {
    public let goalKcal: Double
    public let consumed: Nutrition
    public let entriesWithoutData: Int
    public var remainingKcal: Double { goalKcal - consumed.kcal }
}

public enum NutritionCalculator {
    public static func nutrition(for entry: LogEntry) -> Nutrition? {
        entry.food.per100g?.scaled(by: entry.grams / 100)
    }

    public static func summary(entries: [LogEntry], goalKcal: Double) -> DailySummary {
        var total = Nutrition.zero
        var missing = 0
        for entry in entries {
            if let n = nutrition(for: entry) { total = total + n } else { missing += 1 }
        }
        return DailySummary(goalKcal: goalKcal, consumed: total, entriesWithoutData: missing)
    }
}
