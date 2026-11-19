import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var brand: String?
    var calories: Double
    var protein: Double?
    var fat: Double?
    var carbs: Double?
    var quantityGrams: Double
    var mealTypeRaw: String
    var date: Date
    var isEstimated: Bool
    
    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .lunch }
        set { mealTypeRaw = newValue.rawValue }
    }
    
    init(
        name: String,
        brand: String? = nil,
        calories: Double,
        protein: Double? = nil,
        fat: Double? = nil,
        carbs: Double? = nil,
        quantityGrams: Double = 100,
        mealType: MealType,
        date: Date = .now,
        isEstimated: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.quantityGrams = quantityGrams
        self.mealTypeRaw = mealType.rawValue
        self.date = date
        self.isEstimated = isEstimated
    }
}