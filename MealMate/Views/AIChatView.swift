import SwiftUI
import SwiftData

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let suggestions: [FoodItemDetail]
}

struct AIChatView: View {
    @Query private var profiles: [UserProfile]
    @Query private var allEntries: [FoodEntry]
    
    @State private var inputText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "Olá! Sou o MealMate AI. Pergunta-me o que podes comer hoje com base nas tuas calorias restantes.",
            isUser: false,
            suggestions: []
        )
    ]
    
    private var remainingCalories: Int {
        let goal = profiles.first?.dailyCalorieGoal ?? 2200
        let consumed = allEntries
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.calories }
        return max(0, Int(goal - consumed))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Barra de introdução de mensagem
                HStack(spacing: 12) {
                    TextField("Ex: Ainda tenho \(remainingCalories) kcal...", text: $inputText)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
            .navigationTitle("MealMate AI")
        }
    }
    
    private func sendMessage() {
        let query = inputText
        messages.append(ChatMessage(text: query, isUser: true, suggestions: []))
        inputText = ""
        
        // Simulação de resposta contextualizada (substituir futuramente pela chamada ao backend/OpenAI)
        let mockSuggestions = [
            FoodItemDetail(
                name: "Omelete com Legumes",
                imageURL: nil,
                caloriesPer100gOrServing: 340,
                protein: 24,
                fat: 22,
                carbs: 9,
                ingredients: ["3 Ovos", "Espinafres", "Tomate cherry", "Cogumelos"],
                instructions: "Bater os ovos e cozinhar com os legumes salteados.",
                isEstimated: true,
                sourceLabel: "Sugestão MealMate AI"
            ),
            FoodItemDetail(
                name: "Salada com Frango",
                imageURL: nil,
                caloriesPer100gOrServing: 410,
                protein: 38,
                fat: 14,
                carbs: 28,
                ingredients: ["150g Peito de frango", "Alface", "Tomate", "1 colher de azeite", "Croutons integrais"],
                instructions: "Grelhar o frango, cortar em tiras e envolver na salada temperada.",
                isEstimated: true,
                sourceLabel: "Sugestão MealMate AI"
            )
        ]
        
        let reply = ChatMessage(
            text: "Tens cerca de \(remainingCalories) kcal disponíveis hoje. Aqui tens algumas sugestões:",
            isUser: false,
            suggestions: mockSuggestions
        )
        messages.append(reply)
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(message.text)
                    .foregroundStyle(message.isUser ? .white : .primary)
                
                ForEach(message.suggestions) { suggestion in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("- \(suggestion.name)")
                            .font(.subheadline.bold())
                        if let kcal = suggestion.caloriesPer100gOrServing {
                            Text("Calorias estimadas: \(Int(kcal)) kcal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        NavigationLink(destination: FoodDetailView(item: suggestion, defaultMeal: .dinner)) {
                            Text("[Ver detalhes]")
                                .font(.caption.bold())
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(12)
            .background(message.isUser ? Color.blue : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if !message.isUser { Spacer() }
        }
    }
}