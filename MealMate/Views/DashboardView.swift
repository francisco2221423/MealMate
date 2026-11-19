import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \FoodEntry.date, order: .reverse) private var allEntries: [FoodEntry]
    
    @State private var selectedMealForAdd: MealType?
    
    private var profile: UserProfile {
        profiles.first ?? UserProfile()
    }
    
    private var todayEntries: [FoodEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var consumedCalories: Double {
        todayEntries.reduce(0) { $0 + $1.calories }
    }
    
    private var remainingCalories: Double {
        max(0, profile.dailyCalorieGoal - consumedCalories)
    }
    
    private var consumedProtein: Double {
        todayEntries.reduce(0) { $0 + ($1.protein ?? 0) }
    }
    
    private var consumedFat: Double {
        todayEntries.reduce(0) { $0 + ($1.fat ?? 0) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Cartão de Progresso Diário
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Objetivo Diário")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(Int(profile.dailyCalorieGoal)) kcal")
                                    .font(.title2.bold())
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Restantes")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(Int(remainingCalories)) kcal")
                                    .font(.title2.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        // 3 Arcos de Progresso (Calorias, Proteínas, Gorduras)
                        HStack(spacing: 20) {
                            MacroGaugeView(
                                title: "Calorias",
                                current: consumedCalories,
                                goal: profile.dailyCalorieGoal,
                                unit: "kcal",
                                color: .red
                            )
                            MacroGaugeView(
                                title: "Proteínas",
                                current: consumedProtein,
                                goal: profile.dailyProteinGoal,
                                unit: "g",
                                color: .blue
                            )
                            MacroGaugeView(
                                title: "Gorduras",
                                current: consumedFat,
                                goal: profile.dailyFatGoal,
                                unit: "g",
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Secção "As minhas refeições"
                    VStack(alignment: .leading, spacing: 12) {
                        Text("As minhas refeições")
                            .font(.headline)
                        
                        ForEach(MealType.allCases) { meal in
                            let mealEntries = todayEntries.filter { $0.mealType == meal }
                            let mealCalories = mealEntries.reduce(0) { $0 + $1.calories }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Label(meal.rawValue, systemImage: meal.icon)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(mealCalories)) kcal")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.secondary)
                                    
                                    Button {
                                        selectedMealForAdd = meal
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                    }
                                }
                                
                                if mealEntries.isEmpty {
                                    Text("Sem alimentos registados")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(mealEntries) { entry in
                                        HStack {
                                            Text(entry.name)
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(Int(entry.calories)) kcal")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                modelContext.delete(entry)
                                            } label: {
                                                Label("Apagar", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("MealMate")
            .sheet(item: $selectedMealForAdd) { meal in
                NavigationStack {
                    FoodSearchView(preselectedMeal: meal)
                }
            }
        }
    }
}

struct MacroGaugeView: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(color.opacity(0.2), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(180))
                
                Circle()
                    .trim(from: 0.0, to: 0.5 * progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(180))
                
                Text("\(Int(current))\(unit)")
                    .font(.caption.bold())
                    .offset(y: -4)
            }
            .frame(height: 60)
            
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}