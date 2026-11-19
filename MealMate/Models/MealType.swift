import Foundation
import SwiftData

enum MealType: String, CaseIterable, Codable, Identifiable {
    case breakfast = "Pequeno-Almoço"
    case lunch = "Almoço"
    case snack = "Lanche"
    case dinner = "Jantar"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .snack: return "cup.and.saucer.fill"
        case .dinner: return "moon.stars.fill"
        }
    }
}