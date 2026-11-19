import Foundation

public enum MealType: String, Codable, CaseIterable, Sendable {
    case breakfast, lunch, snack, dinner
}

public struct Nutrition: Codable, Equatable, Sendable {
    public var kcal: Double
    public var protein: Double
    public var carbs: Double
    public var fat: Double

    public init(kcal: Double, protein: Double, carbs: Double, fat: Double) {
        self.kcal = kcal; self.protein = protein; self.carbs = carbs; self.fat = fat
    }

    public static let zero = Nutrition(kcal: 0, protein: 0, carbs: 0, fat: 0)

    public func scaled(by factor: Double) -> Nutrition {
        Nutrition(kcal: kcal * factor, protein: protein * factor,
                  carbs: carbs * factor, fat: fat * factor)
    }

    public static func + (a: Nutrition, b: Nutrition) -> Nutrition {
        Nutrition(kcal: a.kcal + b.kcal, protein: a.protein + b.protein,
                  carbs: a.carbs + b.carbs, fat: a.fat + b.fat)
    }
}

public struct FoodItem: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public var name: String
    public var brand: String?
    public var per100g: Nutrition?
    public var imageURL: URL?

    public init(id: String, name: String, brand: String? = nil,
                per100g: Nutrition? = nil, imageURL: URL? = nil) {
        self.id = id; self.name = name; self.brand = brand
        self.per100g = per100g; self.imageURL = imageURL
    }
}

public struct LogEntry: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var food: FoodItem
    public var grams: Double
    public var meal: MealType
    public var date: Date

    public init(id: UUID = UUID(), food: FoodItem, grams: Double,
                meal: MealType, date: Date = Date()) {
        self.id = id; self.food = food; self.grams = grams
        self.meal = meal; self.date = date
    }
}
