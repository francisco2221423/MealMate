import SwiftUI
import SwiftData

struct ProfileHistoryView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \FoodEntry.date, order: .reverse) private var entries: [FoodEntry]
    
    @State private var activeSheet: ProfileSheetType?
    
    enum ProfileSheetType: Identifiable {
        case allergies, preferences, settings
        var id: Self { self }
    }
    
    private var profile: UserProfile {
        profiles.first ?? UserProfile()
    }
    
    // Agrupar histórico por dia
    private var groupedEntries: [(Date, [FoodEntry])] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Cabeçalho do Perfil
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.blue)
                        
                        Text(profile.name)
                            .font(.title3.bold())
                        
                        Text("Objetivo: \(Int(profile.dailyCalorieGoal)) kcal/dia")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 3 Botões Circulares (Alergias, Preferências, Definições)
                    HStack(spacing: 28) {
                        ProfileCircleButton(title: "Alergias", icon: "exclamationmark.triangle.fill", color: .orange) {
                            activeSheet = .allergies
                        }
                        ProfileCircleButton(title: "Preferências", icon: "heart.fill", color: .pink) {
                            activeSheet = .preferences
                        }
                        ProfileCircleButton(title: "Definições", icon: "gearshape.fill", color: .blue) {
                            activeSheet = .settings
                        }
                    }
                    
                    Divider()
                    
                    // Secção Histórico
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Histórico")
                            .font(.headline)
                        
                        if groupedEntries.isEmpty {
                            Text("Ainda não existem registos anteriores.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(groupedEntries, id: \.0) { day, dayEntries in
                                let totalKcal = dayEntries.reduce(0) { $0 + $1.calories }
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(day, style: .date)
                                            .font(.subheadline.bold())
                                        Spacer()
                                        Text("\(Int(totalKcal)) kcal")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.blue)
                                    }
                                    
                                    ForEach(dayEntries) { entry in
                                        HStack {
                                            Text("\(entry.mealType.rawValue): \(entry.name)")
                                                .font(.caption)
                                            Spacer()
                                            Text("\(Int(entry.calories)) kcal")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Perfil e Histórico")
            .sheet(item: $activeSheet) { sheet in
                ProfileEditSheet(profile: profile, type: sheet)
            }
        }
    }
}

struct ProfileCircleButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(color)
                    }
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
        }
    }
}

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile
    let type: ProfileHistoryView.ProfileSheetType
    
    @State private var newTag = ""
    
    var body: some View {
        NavigationStack {
            Form {
                switch type {
                case .settings:
                    Section("Perfil e Objetivos") {
                        TextField("Nome", text: $profile.name)
                        HStack {
                            Text("Objetivo Calórico (kcal)")
                            Spacer()
                            TextField("2200", value: $profile.dailyCalorieGoal, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 90)
                        }
                        HStack {
                            Text("Proteínas (g)")
                            Spacer()
                            TextField("150", value: $profile.dailyProteinGoal, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 90)
                        }
                        HStack {
                            Text("Gorduras (g)")
                            Spacer()
                            TextField("70", value: $profile.dailyFatGoal, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 90)
                        }
                    }
                    
                case .allergies:
                    Section("Adicionar Alergia / Intolerância") {
                        HStack {
                            TextField("Ex: Glúten, Lactose, Amendoim", text: $newTag)
                            Button("Adicionar") {
                                guard !newTag.isEmpty else { return }
                                profile.allergies.append(newTag)
                                newTag = ""
                            }
                        }
                    }
                    Section("Registadas") {
                        ForEach(profile.allergies, id: \.self) { allergy in
                            Text(allergy)
                        }
                        .onDelete { profile.allergies.remove(atOffsets: $0) }
                    }
                    
                case .preferences:
                    Section("Adicionar Preferência Alimentar") {
                        HStack {
                            TextField("Ex: Vegetariano, Alta proteína", text: $newTag)
                            Button("Adicionar") {
                                guard !newTag.isEmpty else { return }
                                profile.preferences.append(newTag)
                                newTag = ""
                            }
                        }
                    }
                    Section("Registadas") {
                        ForEach(profile.preferences, id: \.self) { pref in
                            Text(pref)
                        }
                        .onDelete { profile.preferences.remove(atOffsets: $0) }
                    }
                }
            }
            .navigationTitle("Editar Perfil")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluir") { dismiss() }
                }
            }
        }
    }
}