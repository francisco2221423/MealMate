import SwiftUI
import SwiftData

@main
struct MealMateApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [FoodEntry.self, UserProfile.self])
    }
}
