//
//  ProfileView.swift
//  ImpactMatch
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showSettings = false
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle().fill(LinearGradient.brandGradient).frame(width: 92, height: 92)
                            Image(systemName: store.currentProfile.avatarSystemImage)
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                        VStack(spacing: 4) {
                            Text(store.currentProfile.name).font(.screenTitle)
                            Text(store.currentProfile.headline)
                                .font(.bodyRegular)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                            Label(store.currentProfile.location, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(Color.textTertiary)
                        }
                    }
                    .padding(.top, 12)
                    .accessibilityElement(children: .combine)

                    HStack(spacing: 12) {
                        MiniStat(icon: "person.2.fill", value: store.currentProfile.connectionsCount, label: "Conexiones")
                        MiniStat(icon: "sparkles", value: store.currentProfile.matchesCount, label: "Matches")
                        MiniStat(icon: "checkmark.seal.fill", value: store.currentProfile.completedProjectsCount, label: "Proyectos")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Sobre mí")
                        Text(store.currentProfile.bio)
                            .font(.bodyRegular)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Habilidades")
                        WrapChips(items: store.currentProfile.skills)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Intereses")
                        WrapChips(items: store.currentProfile.interests, highlighted: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Preferencias")
                        DetailRow(icon: "clock.fill", title: "Disponibilidad", value: "\(store.currentProfile.availabilityHoursPerWeek)h / semana")
                        DetailRow(icon: "location.fill", title: "Modalidad preferida", value: store.currentProfile.preferredModality.localizedName)
                        DetailRow(icon: "target", title: "Busca", value: store.currentProfile.seekingOpportunityTypes.map(\.localizedName).joined(separator: ", "))
                        if let fieldOfStudy = store.currentProfile.fieldOfStudy, !fieldOfStudy.isEmpty {
                            DetailRow(icon: "graduationcap.fill", title: "Carrera", value: fieldOfStudy)
                        }
                    }
                    .cardStyle()
                }
                .padding(Layout.screenPadding)
            }
            .background(Color.surfaceSecondary.opacity(0.4))
            .navigationTitle("Perfil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button { showEditProfile = true } label: {
                            Image(systemName: "pencil")
                        }
                        .accessibilityLabel("Editar perfil")
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .accessibilityLabel("Configuración")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showEditProfile) {
                NavigationStack {
                    ProfileEditorView(mode: .edit, existingProfile: store.currentProfile)
                }
            }
        }
    }
}

struct WrapChips: View {
    let items: [String]
    var highlighted: Bool = false
    var body: some View {
        // FlowLayout simple con LazyVGrid adaptativo para evitar dependencias externas
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                SkillChip(text: item, highlighted: highlighted)
            }
        }
    }
}

#Preview {
    ProfileView().environmentObject(AppStore())
}
