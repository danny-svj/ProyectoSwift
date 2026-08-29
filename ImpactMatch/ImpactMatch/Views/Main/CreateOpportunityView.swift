//
//  CreateOpportunityView.swift
//  ImpactMatch
//

import SwiftUI

struct CreateOpportunityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var type: OpportunityType = .project
    @State private var modality: Modality = .hybrid
    @State private var schedule = ""
    @State private var duration = ""
    @State private var requirements = ""
    @State private var skillsText = ""
    @State private var interestsText = ""

    var isValid: Bool { !title.isEmpty && !description.isEmpty && !skillsText.isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FormField(title: "Título de la oportunidad", text: $title, placeholder: "ej. Desarrollador SwiftUI")
                    FormField(title: "Descripción", text: $description, placeholder: "¿Qué se hará y por qué importa?", multiline: true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tipo de colaboración").font(.caption).foregroundStyle(Color.textSecondary)
                        Picker("Tipo", selection: $type) {
                            ForEach(OpportunityType.allCases) { Text($0.localizedName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Modalidad").font(.caption).foregroundStyle(Color.textSecondary)
                        Picker("Modalidad", selection: $modality) {
                            ForEach(Modality.allCases) { Text($0.localizedName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    FormField(title: "Horario", text: $schedule, placeholder: "ej. Medio tiempo, 15h/semana")
                    FormField(title: "Duración", text: $duration, placeholder: "ej. 3 meses")
                    FormField(title: "Habilidades necesarias (separadas por coma)", text: $skillsText, placeholder: "Swift, SwiftUI, Diseño")
                    FormField(title: "Intereses relacionados (separadas por coma)", text: $interestsText, placeholder: "Sostenibilidad, Educación")
                    FormField(title: "Requisitos adicionales", text: $requirements, placeholder: "Opcional", multiline: true)

                    Button {
                        let newOpportunity = Opportunity(
                            title: title,
                            organizationName: store.currentProfile.name,
                            type: type,
                            description: description,
                            requiredSkills: skillsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            relatedInterests: interestsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            modality: modality,
                            schedule: schedule.isEmpty ? AppLanguage.localizedString("Por definir") : schedule,
                            duration: duration.isEmpty ? AppLanguage.localizedString("Por definir") : duration,
                            requirements: requirements
                        )
                        store.addOpportunity(newOpportunity)
                        dismiss()
                    } label: {
                        Text("Publicar oportunidad")
                    }
                    .buttonStyle(PrimaryGradientButtonStyle(isDisabled: !isValid))
                    .disabled(!isValid)
                    .sensoryFeedback(.success, trigger: store.opportunities.count)
                }
                .padding(Layout.screenPadding)
            }
            .navigationTitle("Nueva oportunidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

struct FormField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var placeholder: LocalizedStringKey = ""
    var multiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(Color.textSecondary)
            Group {
                if multiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
        }
    }
}

#Preview {
    CreateOpportunityView().environmentObject(AppStore())
}
