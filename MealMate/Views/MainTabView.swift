import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }
            
            FoodSearchView()
                .tabItem {
                    Label("Diário", systemImage: "magnifyingglass")
                }
            
            AIChatView()
                .tabItem {
                    Label("IA", systemImage: "sparkles")
                }
            
            ProfileHistoryView()
                .tabItem {
                    Label("Histórico", systemImage: "person.crop.circle")
                }
        }
        .onAppear {
            if profiles.isEmpty {
                modelContext.insert(UserProfile())
            }
        }
    }
}