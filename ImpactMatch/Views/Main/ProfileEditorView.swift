//
//  ProfileEditorView.swift
//  ImpactMatch
//

import SwiftUI
import CoreLocation

struct ProfileEditorView: View {
    enum Mode {
        case create(userType: UserType, name: String)
        case edit
    }

    let mode: Mode

    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationMgr = LocationManager()

    @State private var headline: String
    @State private var bio: String
    @State private var skills: [String]
    @State private var interests: [String]
    @State private var availabilityHours: Double
    @State private var modality: Modality
    @State private var location: String
    @State private var fieldOfStudy: String
    @State private var hasMasters: Bool
    @State private var mastersDegree: String

    @State private var showCareerPicker = false
    @State private var careerSearch = ""
    @State private var showMastersPicker = false
    @State private var mastersSearch = ""
    @State private var isGeocodingLocation = false

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
        _hasMasters = State(initialValue: existingProfile?.mastersDegree != nil)
        _mastersDegree = State(initialValue: existingProfile?.mastersDegree ?? "")
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

    private var pendingSuggestedSkills: [String] {
        CareerCatalog.info(for: fieldOfStudy)?.suggestedSkills.filter { !skills.contains($0) } ?? []
    }
    private var pendingSuggestedInterests: [String] {
        CareerCatalog.info(for: fieldOfStudy)?.suggestedInterests.filter { !interests.contains($0) } ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isCreating { header }

                // MARK: 1 — Carrera (lo primero para personas)
                if isPerson {
                    careerSection
                }

                // MARK: 2 — Cuéntanos de ti
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cuéntanos de ti (opcional)").font(.caption).foregroundStyle(Color.textSecondary)
                    FormField(title: isPerson ? "Titular" : "Qué hace tu organización",
                              text: $headline,
                              placeholder: isPerson ? "ej. Estudiante de Ing. en Software" : "ej. ONG de educación tecnológica")
                    FormField(title: "Biografía", text: $bio,
                              placeholder: "Cuéntale a otros quién eres y qué buscas", multiline: true)
                }

                // MARK: 3 — Habilidades
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: isPerson ? "Tus habilidades" : "Lo que ofrece tu organización")
                    Text(isPerson
                         ? "Elige o agrega las que te representen — así calculamos qué tan compatible eres con cada oportunidad."
                         : "Ayuda a las personas a entender qué pueden aportar contigo.")
                        .font(.caption).foregroundStyle(Color.textSecondary)
                    TagSelector(suggestions: SkillCatalog.commonSkills, selected: $skills,
                                placeholder: "Agregar otra habilidad...")
                }

                // MARK: 4 — Intereses
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: isPerson ? "Tus intereses" : "Causas que apoyas")
                    TagSelector(suggestions: SkillCatalog.commonInterests, selected: $interests,
                                color: .brandAccent, placeholder: "Agregar otro interés...")
                }

                if isPerson {
                    // MARK: 5 — Maestría
                    mastersSection

                    // MARK: 6 — Disponibilidad
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Disponibilidad")
                        HStack {
                            Text("\(Int(availabilityHours)) h / semana").font(.bodyMedium.weight(.semibold))
                            Spacer()
                        }
                        Slider(value: $availabilityHours, in: 1...40, step: 1)
                            .tint(Color.brandPrimary)
                            .accessibilityLabel("Disponibilidad: \(Int(availabilityHours)) horas por semana")
                    }
                    .cardStyle()
                }

                // MARK: 7 — Modalidad
                VStack(alignment: .leading, spacing: 6) {
                    Text("Modalidad preferida").font(.caption).foregroundStyle(Color.textSecondary)
                    Picker("Modalidad", selection: $modality) {
                        ForEach(Modality.allCases) { Text($0.localizedName).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: 8 — Ubicación con GPS
                locationSection

                // MARK: 9 — Guardar
                Button { save() } label: {
                    Text(isCreating ? "Finalizar y entrar a ImpactMatch" : "Guardar cambios")
                }
                .buttonStyle(PrimaryGradientButtonStyle(isDisabled: !canFinish))
                .disabled(!canFinish)

                if !canFinish {
                    Text("Agrega al menos una habilidad para continuar.")
                        .font(.caption).foregroundStyle(Color.textTertiary)
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
        .onAppear { locationMgr.requestPermission() }
        .onChange(of: fieldOfStudy) { _, newCareer in
            guard !newCareer.isEmpty, let info = CareerCatalog.info(for: newCareer) else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                skills = info.suggestedSkills
                interests = info.suggestedInterests
            }
        }
    }

    // MARK: - Sub-vistas

    private var header: some View {
        VStack(spacing: 6) {
            Text(isPerson ? "Arma tu perfil" : "Arma el perfil de tu organización")
                .font(.screenTitle)
            Text("Esto es lo que usamos para calcular tu compatibilidad — puedes editarlo después.")
                .font(.bodyRegular).foregroundStyle(Color.textSecondary).multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    @ViewBuilder
    private var careerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("¿Qué estudias?").font(.caption).foregroundStyle(Color.textSecondary)

            Button { showCareerPicker = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "graduationcap.fill")
                        .foregroundStyle(Color.brandPrimary).frame(width: 18)
                    Text(fieldOfStudy.isEmpty ? "Seleccionar carrera..." : fieldOfStudy)
                        .foregroundStyle(fieldOfStudy.isEmpty ? Color.textTertiary : Color.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    if !fieldOfStudy.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                fieldOfStudy = ""
                                hasMasters = false
                                mastersDegree = ""
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(Color.textTertiary)
                        }
                    }
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.textTertiary).font(.caption)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
            }
            .accessibilityLabel("Seleccionar carrera")
            .accessibilityHint("Abre buscador de carreras")
            .sheet(isPresented: $showCareerPicker) {
                CareerPickerSheet(selection: $fieldOfStudy, searchText: $careerSearch)
            }

            // Sugerencias automáticas
            if !pendingSuggestedSkills.isEmpty || !pendingSuggestedInterests.isEmpty {
                SuggestedSkillsBanner(
                    career: fieldOfStudy,
                    skills: pendingSuggestedSkills,
                    interests: pendingSuggestedInterests
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        skills = mergeUnique(skills, pendingSuggestedSkills)
                        interests = mergeUnique(interests, pendingSuggestedInterests)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: fieldOfStudy)
    }

    @ViewBuilder
    private var mastersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $hasMasters.animation(.spring(response: 0.35, dampingFraction: 0.85))) {
                Label("Tengo maestría", systemImage: "books.vertical.fill").font(.bodyMedium)
            }
            .tint(Color.brandPrimary)
            .accessibilityLabel("¿Tienes maestría?")

            if hasMasters {
                Button { showMastersPicker = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "book.fill")
                            .foregroundStyle(Color.brandPrimary).frame(width: 18)
                        Text(mastersDegree.isEmpty ? "Buscar y seleccionar maestría..." : mastersDegree)
                            .foregroundStyle(mastersDegree.isEmpty ? Color.textTertiary : Color.textPrimary)
                            .lineLimit(2)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.textTertiary).font(.caption)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
                }
                .accessibilityLabel("Seleccionar maestría")
                .accessibilityHint("Abre buscador de maestrías")
                .sheet(isPresented: $showMastersPicker) {
                    MastersPickerSheet(selection: $mastersDegree, searchText: $mastersSearch)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cardStyle()
        .onChange(of: hasMasters) { _, hasIt in
            if !hasIt { mastersDegree = "" }
        }
    }

    @ViewBuilder
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ubicación").font(.caption).foregroundStyle(Color.textSecondary)
                Spacer()
                Button { fetchCurrentLocation() } label: {
                    HStack(spacing: 4) {
                        if isGeocodingLocation {
                            ProgressView().scaleEffect(0.7)
                        } else {
                            Image(systemName: "location.fill")
                        }
                        Text(isGeocodingLocation ? "Obteniendo..." : "Usar mi ubicación")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandPrimary)
                }
                .disabled(isGeocodingLocation)
                .accessibilityLabel("Detectar ubicación actual del dispositivo")
            }
            TextField("ej. Ciudad de México, MX", text: $location)
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
                .accessibilityLabel("Ubicación")
        }
    }

    // MARK: - Helpers

    private func fetchCurrentLocation() {
        locationMgr.requestPermission()
        if let coord = locationMgr.userLocation {
            isGeocodingLocation = true
            geocodeCoordinate(coord)
        } else {
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    guard let coord = locationMgr.userLocation else { return }
                    isGeocodingLocation = true
                    geocodeCoordinate(coord)
                }
            }
        }
    }

    private func geocodeCoordinate(_ coord: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coord.latitude, longitude: coord.longitude)) { placemarks, _ in
            isGeocodingLocation = false
            guard let p = placemarks?.first else { return }
            let parts = [p.locality, p.administrativeArea, p.isoCountryCode].compactMap { $0 }
            if !parts.isEmpty { location = parts.joined(separator: ", ") }
        }
    }

    private func mergeUnique(_ existing: [String], _ new: [String]) -> [String] {
        var seen = Set(existing)
        var result = existing
        for item in new where seen.insert(item).inserted { result.append(item) }
        return result
    }

    private func save() {
        let resolvedMasters = hasMasters && !mastersDegree.isEmpty ? mastersDegree : nil
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
                fieldOfStudy: fieldOfStudy.isEmpty ? nil : fieldOfStudy,
                mastersDegree: resolvedMasters
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
            profile.mastersDegree = resolvedMasters
            store.currentProfile = profile
            dismiss()
        }
    }
}

// MARK: - Career picker sheet

struct CareerPickerSheet: View {
    @Binding var selection: String
    @Binding var searchText: String
    @Environment(\.dismiss) var dismiss

    private var filtered: [CareerInfo] {
        searchText.isEmpty ? CareerCatalog.careers
            : CareerCatalog.careers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { career in
                    Button {
                        selection = career.name; searchText = ""; dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(career.name).foregroundStyle(Color.textPrimary)
                                Text(career.suggestedSkills.prefix(3).joined(separator: " · "))
                                    .font(.caption).foregroundStyle(Color.textTertiary)
                            }
                            Spacer()
                            if selection == career.name {
                                Image(systemName: "checkmark").foregroundStyle(Color.brandPrimary)
                            }
                        }
                    }
                }
                if !searchText.isEmpty,
                   !CareerCatalog.careers.contains(where: { $0.name.localizedCaseInsensitiveCompare(searchText) == .orderedSame }) {
                    Button {
                        selection = searchText; searchText = ""; dismiss()
                    } label: {
                        Label("Usar \"\(searchText)\"", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
            .navigationTitle("¿Qué estudias?")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar carrera...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") { searchText = ""; dismiss() }
                }
            }
        }
    }
}

// MARK: - Masters picker sheet

struct MastersPickerSheet: View {
    @Binding var selection: String
    @Binding var searchText: String
    @Environment(\.dismiss) var dismiss

    private var filtered: [String] {
        searchText.isEmpty ? CareerCatalog.mastersDegrees
            : CareerCatalog.mastersDegrees.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered, id: \.self) { degree in
                    Button {
                        selection = degree; searchText = ""; dismiss()
                    } label: {
                        HStack {
                            Text(degree).foregroundStyle(Color.textPrimary)
                            Spacer()
                            if selection == degree {
                                Image(systemName: "checkmark").foregroundStyle(Color.brandPrimary)
                            }
                        }
                    }
                }
                if !searchText.isEmpty,
                   !CareerCatalog.mastersDegrees.contains(where: { $0.localizedCaseInsensitiveCompare(searchText) == .orderedSame }) {
                    Button {
                        selection = searchText; searchText = ""; dismiss()
                    } label: {
                        Label("Usar \"\(searchText)\"", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
            .navigationTitle("Seleccionar maestría")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar maestría...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") { searchText = ""; dismiss() }
                }
            }
        }
    }
}

// MARK: - Banner de sugerencias por carrera

struct SuggestedSkillsBanner: View {
    let career: String
    let skills: [String]
    let interests: [String]
    let onAddAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles").foregroundStyle(Color.brandPrimary)
                Text("Sugeridas para \(career.components(separatedBy: " ").prefix(2).joined(separator: " "))")
                    .font(.caption.weight(.semibold)).foregroundStyle(Color.brandPrimary)
                Spacer()
                Button("Agregar todas", action: onAddAll)
                    .font(.caption.weight(.semibold)).foregroundStyle(Color.brandPrimary)
                    .accessibilityLabel("Agregar todas las sugerencias a tu perfil")
            }
            if !skills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(skills, id: \.self) { SkillChip(text: $0, highlighted: true) }
                    }
                }
            }
            if !interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(interests, id: \.self) { SkillChip(text: $0) }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.brandPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
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
