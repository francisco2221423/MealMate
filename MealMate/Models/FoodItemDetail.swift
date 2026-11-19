import Foundation
import SwiftData

// Estrutura unificada para apresentar detalhes de Alimentos (Open Food Facts), Receitas (TheMealDB) ou Sugestões IA
struct FoodItemDetail: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageURL: String?
    let caloriesPer100gOrServing: Double?
    let protein: Double?
    let fat: Double?
    let carbs: Double?
    let ingredients: [String]
    let instructions: String?
    let isEstimated: Bool
    let sourceLabel: String
}