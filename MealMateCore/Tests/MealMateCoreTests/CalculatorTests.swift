import XCTest
@testable import MealMateCore

final class CalculatorTests: XCTestCase {
    func testSummary() {
        let rice = FoodItem(id: "1", name: "Arroz",
                            per100g: Nutrition(kcal: 130, protein: 2.7, carbs: 28, fat: 0.3))
        let unknown = FoodItem(id: "2", name: "Desconhecido")
        let entries = [
            LogEntry(food: rice, grams: 200, meal: .lunch),
            LogEntry(food: unknown, grams: 100, meal: .snack),
        ]
        let s = NutritionCalculator.summary(entries: entries, goalKcal: 2000)
        XCTAssertEqual(s.consumed.kcal, 260, accuracy: 0.01)
        XCTAssertEqual(s.remainingKcal, 1740, accuracy: 0.01)
        XCTAssertEqual(s.entriesWithoutData, 1)
    }
}
