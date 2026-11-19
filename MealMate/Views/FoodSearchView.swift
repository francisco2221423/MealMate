import SwiftUI
import SwiftData

struct FoodSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var preselectedMeal: MealType = .lunch
    
    @State private var searchText = ""
    @State private var showCustomEntrySheet = false
    
    // Dados de exemplo para testar a UI antes da ligação às APIs REST
    private let sampleItems: [FoodItemDetail] = [
        FoodItemDetail(
            name: "Omelete com Legumes",
            imageURL: nil,
            caloriesPer100gOrServing: 320,
            protein: 22,
            fat: 21,
            carbs: 8,
            ingredients: ["3 Ovos", "50g Espinafres", "40g Cogumelos", "1 colher de chá de azeite"],
            instructions: "1. Bater os ovos.\n2. Saltear os legumes numa frigideira antiaderente.\n3. Juntar os ovos e cozinhar em lume brando.",
            isEstimated: false,
            sourceLabel: "Receita (TheMealDB)"
        ),
        FoodItemDetail(
            name: "Peito de Frango Grelhado",
            imageURL: nil,
            caloriesPer100gOrServing: 165,
            protein: 31,
            fat: 3.6,
            carbs: 0,
            ingredients: ["100g Peito de Frango"],
            instructions: nil,
            isEstimated: false,
            sourceLabel: "Alimento (Open Food Facts)"
        ),
        FoodItemDetail(
            name: "Iogurte Grego Natural",
            imageURL: nil,
            caloriesPer100gOrServing: 97,
            protein: 9,
            fat: 5,
            carbs: 3.6,
            ingredients: ["100g Iogurte Grego"],
            instructions: nil,
            isEstimated: false,
            sourceLabel: "Alimento (Open Food Facts)"
        )
    ]
    
    private var filteredItems: [FoodItemDetail] {
        if searchText.isEmpty { return sampleItems }
        return sampleItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List(filteredItems) { item in
                    NavigationLink(destination: FoodDetailView(item: item, defaultMeal: preselectedMeal)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.name)
                                    .font(.headline)
                                Spacer()
                                if let kcal = item.caloriesPer100gOrServing {
                                    Text("\(Int(kcal)) kcal")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.blue)
                                } else {
                                    Text("Informação incompleta")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            
                            Text(item.sourceLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let p = item.protein, let g = item.fat {
                                Text("Proteína: \(String(format: "%.1f", p))g • Gordura: \(String(format: "%.1f", g))g")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .searchable(text: $searchText, prompt: "Pesquisar alimento ou receita...")
                
                // Botão flutuante '+' previsto no mockup
                Button {
                    showCustomEntrySheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
            .navigationTitle("Pesquisa")
            .sheet(isPresented: $showCustomEntrySheet) {
                QuickAddFoodSheet(defaultMeal: preselectedMeal)
            }
        }
    }
}

struct QuickAddFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var fat = ""
    @State private var selectedMeal: MealType
    
    init(defaultMeal: MealType) {
        _selectedMeal = State(initialValue: defaultMeal)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informação Básica") {
                    TextField("Nome do alimento", text: $name)
                    Picker("Refeição", selection: $selectedMeal) {
                        ForEach(MealType.allCases) { meal in
                            Text(meal.rawValue).tag(meal)
                        }
                    }
                }
                
                Section("Valores Nutricionais") {
                    TextField("Calorias (kcal)", text: $calories)
                        .keyboardType(.decimalPad)
                    TextField("Proteínas (g) - opcional", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Gorduras (g) - opcional", text: $fat)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Novo Registo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let entry = FoodEntry(
                            name: name,
                            calories: Double(calories) ?? 0,
                            protein: Double(protein),
                            fat: Double(fat),
                            mealType: selectedMeal
                        )
                        modelContext.insert(entry)
                        dismiss()
                    }
                    .disabled(name.isEmpty || calories.isEmpty)
                }
            }
        }
    }
}