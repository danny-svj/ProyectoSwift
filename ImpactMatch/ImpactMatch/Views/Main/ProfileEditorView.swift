//
//  ProfileEditorView.swift
//  ImpactMatch
//
//  Arma o edita el perfil: habilidades, intereses, disponibilidad,
//  modalidad y ubicación. Se usa en dos momentos:
//  - Al registrarse (antes de crear la cuenta, con `.create`).
//  - Desde la pestaña Perfil para editar más adelante (con `.edit`).
//

import SwiftUI

struct ProfileEditorView: View {
    enum Mode {
        case create(userType: UserType, name: String)
        case edit
    }

    let mode: Mode

    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var headline: String
    @State private var bio: String
    @State private var skills: [String]
    @State private var interests: [String]
    @State private var availabilityHours: Double
    @State private var modality: Modality
    @State private var location: String
    @State private var fieldOfStudy: String

    init(mode: Mode, existingProfile: UserProfile? = nil) {
        self.mode = mode
        _headline = State(initialValue: existingProfile?.headline ?? "")
        _bio = State(initialValue: existingProfile?.bio ?? "")
        _skills = State(initialValue: existingProfile?.skills ?? [])
        _interests = State(initialValue: existingProfile?.interests ?? [])
        _availabilityHours = State(initialValue: Double(existingProfile?.availabilityHoursPerWeek ?? 10))
        _modality = State(initialValue: existingProfile?.preferredModality ?? .hybrid)
        _location = State(initialValue: existingProfile?.location ?? "")
        _fieldOfStudy = State(initialValue: existingProfile?.fieldOfStudy ?? "")
    }

    private var userType: UserType {
        switch mode {
        case .create(let userType, _): return userType
        case .edit: return store.currentProfile.userType
        }
    }

    private var isPerson: Bool { userType == .person }
    private var canFinish: Bool { !skills.isEmpty }

    private var isCreating: Bool {
        if case .create = mode { return true }
        return false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isCreating {
                    header
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Cuéntanos de ti (opcional)").font(.caption).foregroundStyle(Color.textSecondary)
                    FormField(title: isPerson ? "Titular" : "Qué hace tu organización", text: $headline, placeholder: isPerson ? "ej. Estudiante de Ing. en Software" : "ej. ONG de educación tecnológica")
                    FormField(title: "Biografía", text: $bio, placeholder: "Cuéntale a otros quién eres y qué buscas", multiline: true)
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: isPerson ? "Tus habilidades" : "Lo que ofrece tu organización")
                    Text(isPerson
                         ? "Elige o agrega las que te representen — así calculamos qué tan compatible eres con cada oportunidad."
                         : "Ayuda a las personas a entender qué pueden aportar contigo.")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                    TagSelector(suggestions: SkillCatalog.commonSkills, selected: $skills, placeholder: "Agregar otra habilidad...")
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: isPerson ? "Tus intereses" : "Causas que apoyas")
                    TagSelector(suggestions: SkillCatalog.commonInterests, selected: $interests, color: .brandAccent, placeholder: "Agregar otro interés...")
                }

                if isPerson {
                    FormField(title: "Carrera / área de estudio (opcional)", text: $fieldOfStudy, placeholder: "ej. Ingeniería en Software")

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Disponibilidad")
                        HStack {
                            Text("\(Int(availabilityHours)) h / semana").font(.bodyMedium.weight(.semibold))
                            Spacer()
                        }
                        Slider(value: $availabilityHours, in: 1...40, step: 1)
                            .tint(Color.brandPrimary)
                    }
                    .cardStyle()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Modalidad preferida").font(.caption).foregroundStyle(Color.textSecondary)
                    Picker("Modalidad", selection: $modality) {
                        ForEach(Modality.allCases) { Text($0.localizedName).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                FormField(title: "Ubicación", text: $location, placeholder: "ej. Ciudad de México, MX")

                Button {
                    save()
                } label: {
                    Text(isCreating ? "Finalizar y entrar a ImpactMatch" : "Guardar cambios")
                }
                .buttonStyle(PrimaryGradientButtonStyle(isDisabled: !canFinish))
                .disabled(!canFinish)

                if !canFinish {
                    Text("Agrega al menos una habilidad para continuar.")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(Layout.screenPadding)
        }
        .navigationTitle(isCreating ? "Tu perfil" : "Editar perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isCreating {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .sensoryFeedback(.success, trigger: store.currentProfile.id)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(isPerson ? "Arma tu perfil" : "Arma el perfil de tu organización")
                .font(.screenTitle)
            Text("Esto es lo que usamos para calcular tu compatibilidad — puedes editarlo después.")
                .font(.bodyRegular)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        switch mode {
        case .create(let userType, let name):
            let resolvedName = name.isEmpty
                ? (userType == .person ? AppLanguage.localizedString("Nueva persona") : AppLanguage.localizedString("Nueva organización"))
                : name
            let resolvedHeadline = headline.isEmpty
                ? (userType == .person ? AppLanguage.localizedString("Nuevo en ImpactMatch") : AppLanguage.localizedString("Organización nueva en ImpactMatch"))
                : headline
            let profile = UserProfile(
                name: resolvedName,
                userType: userType,
                headline: resolvedHeadline,
                bio: bio,
                skills: skills,
                interests: interests,
                availabilityHoursPerWeek: userType == .person ? Int(availabilityHours) : 0,
                preferredModality: modality,
                location: location.isEmpty ? AppLanguage.localizedString("Sin especificar") : location,
                seekingOpportunityTypes: userType == .person ? [.internship, .project, .volunteering] : [],
                fieldOfStudy: fieldOfStudy.isEmpty ? nil : fieldOfStudy
            )
            store.currentProfile = profile
            withAnimation { store.isLoggedIn = true }

        case .edit:
            var profile = store.currentProfile
            profile.headline = headline
            profile.bio = bio
            profile.skills = skills
            profile.interests = interests
            if isPerson { profile.availabilityHoursPerWeek = Int(availabilityHours) }
            profile.preferredModality = modality
            profile.location = location.isEmpty ? profile.location : location
            profile.fieldOfStudy = fieldOfStudy.isEmpty ? nil : fieldOfStudy
            store.currentProfile = profile
            dismiss()
        }
    }
}

#Preview("Crear") {
    NavigationStack { ProfileEditorView(mode: .create(userType: .person, name: "Ana")) }
        .environmentObject(AppStore())
}

#Preview("Editar") {
    NavigationStack { ProfileEditorView(mode: .edit, existingProfile: .mockDaniel) }
        .environmentObject(AppStore())
}
