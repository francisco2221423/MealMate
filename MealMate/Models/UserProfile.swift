import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var dailyCalorieGoal: Double
    var dailyProteinGoal: Double
    var dailyFatGoal: Double
    var allergies: [String]
    var preferences: [String]
    
    init(
        name: String = "Francisco Santos",
        dailyCalorieGoal: Double = 2200,
        dailyProteinGoal: Double = 150,
        dailyFatGoal: Double = 70,
        allergies: [String] = [],
        preferences: [String] = []
    ) {
        self.name = name
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyFatGoal = dailyFatGoal
        self.allergies = allergies
        self.preferences = preferences
    }
}