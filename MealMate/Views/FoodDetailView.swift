import SwiftUI
import SwiftData

struct FoodDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: FoodItemDetail
    @State var defaultMeal: MealType
    @State private var quantity: Double = 100
    @State private var showAddedAlert = false
    
    private var calculatedCalories: Double {
        let base = item.caloriesPer100gOrServing ?? 0
        return (base * quantity) / 100.0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Área de Imagem
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 180)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)
                }
                
                // Cabeçalho e Aviso de Estimativa
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.title2.bold())
                    
                    HStack {
                        Text("\(Int(calculatedCalories)) kcal")
                            .font(.title3.bold())
                            .foregroundStyle(.blue)
                        
                        if item.isEstimated {
                            Text("• Valores estimados")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Tabela de Informação Nutricional
                VStack(alignment: .leading, spacing: 10) {
                    Text("Informação Nutricional (por 100g / porção)")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        NutritionRow(label: "Calorias", value: item.caloriesPer100gOrServing != nil ? "\(Int(item.caloriesPer100gOrServing!)) kcal" : "N/D")
                        Divider()
                        NutritionRow(label: "Proteínas", value: item.protein != nil ? "\(String(format: "%.1f", item.protein!)) g" : "N/D")
                        Divider()
                        NutritionRow(label: "Gorduras", value: item.fat != nil ? "\(String(format: "%.1f", item.fat!)) g" : "N/D")
                        Divider()
                        NutritionRow(label: "Hidratos de Carbono", value: item.carbs != nil ? "\(String(format: "%.1f", item.carbs!)) g" : "N/D")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Lista de Ingredientes
                if !item.ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredientes")
                            .font(.headline)
                        ForEach(item.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                                .font(.subheadline)
                        }
                    }
                }
                
                // Instruções de Preparação
                if let instructions = item.instructions, !instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instruções de Preparação")
                            .font(.headline)
                        Text(instructions)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Configuração para Adicionar ao Diário
                VStack(spacing: 12) {
                    Picker("Refeição", selection: $defaultMeal) {
                        ForEach(MealType.allCases) { meal in
                            Text(meal.rawValue).tag(meal)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack {
                        Text("Quantidade (g / % porção):")
                        Spacer()
                        TextField("100", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button {
                        addToDiary()
                    } label: {
                        Label("Adicionar ao Diário", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Adicionado ao Diário", isPresented: $showAddedAlert) {
            Button("OK") { dismiss() }
        }
    }
    
    private func addToDiary() {
        let factor = quantity / 100.0
        let entry = FoodEntry(
            name: item.name,
            calories: (item.caloriesPer100gOrServing ?? 0) * factor,
            protein: item.protein != nil ? item.protein! * factor : nil,
            fat: item.fat != nil ? item.fat! * factor : nil,
            carbs: item.carbs != nil ? item.carbs! * factor : nil,
            quantityGrams: quantity,
            mealType: defaultMeal,
            isEstimated: item.isEstimated
        )
        modelContext.insert(entry)
        showAddedAlert = true
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }
}