//
//  ProfileView.swift
//  ImpactMatch
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showSettings    = false
    @State private var showEditProfile = false
    @State private var showAvatarPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    VStack(spacing: 24) {
                        statsRow
                        bioSection
                        skillsSection
                        interestsSection
                        preferencesSection
                    }
                    .padding(Layout.screenPadding)
                }
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
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showEditProfile) {
                NavigationStack {
                    ProfileEditorView(mode: .edit, existingProfile: store.currentProfile)
                }
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(
                    avatarGradientName: Binding(
                        get: { store.currentProfile.avatarGradientName },
                        set: { store.currentProfile.avatarGradientName = $0 }
                    ),
                    avatarSystemImage: Binding(
                        get: { store.currentProfile.avatarSystemImage },
                        set: { store.currentProfile.avatarSystemImage = $0 }
                    )
                )
            }
        }
    }

    // MARK: - Header con banner de gradiente

    @ViewBuilder
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Banner de gradiente (cubre la parte superior)
            LinearGradient.brandGradient
                .frame(height: 120)
                .frame(maxWidth: .infinity)

            // Orbes decorativos sobre el banner
            HStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 90, height: 90)
                    .offset(x: -20, y: 10)
                Spacer()
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 70, height: 70)
                    .offset(x: 10, y: -10)
            }
            .frame(height: 120)

            // Contenido centrado (avatar + datos)
            VStack(spacing: 10) {
                // Avatar — tappable para personalizar
                Button {
                    showAvatarPicker = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 98, height: 98)
                            Circle()
                                .fill(LinearGradient.avatarGradient(named: store.currentProfile.avatarGradientName))
                                .frame(width: 90, height: 90)
                            Image(systemName: store.currentProfile.avatarSystemImage)
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                        // Badge de cámara
                        ZStack {
                            Circle()
                                .fill(Color.surfacePrimary)
                                .frame(width: 28, height: 28)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.brandPrimary)
                        }
                        .offset(x: 2, y: 2)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Cambiar foto de perfil")
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.currentProfile.avatarGradientName)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.currentProfile.avatarSystemImage)
                .offset(y: 50)  // Superpone el avatar sobre el banner
            }
        }
        .frame(height: 120)
        .padding(.bottom, 64)  // Espacio para el avatar que sobresale

        // Datos del perfil (debajo del avatar)
        VStack(spacing: 6) {
            Text(store.currentProfile.name).font(.screenTitle)

            Text(store.currentProfile.headline)
                .font(.bodyRegular)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            if let career = store.currentProfile.fieldOfStudy, !career.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "graduationcap.fill")
                        .foregroundStyle(Color.brandPrimary)
                        .font(.caption)
                    Text(career)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.brandPrimary)
                    if let masters = store.currentProfile.mastersDegree, !masters.isEmpty {
                        Text("·").foregroundStyle(Color.textTertiary).font(.caption)
                        Image(systemName: "books.vertical.fill")
                            .foregroundStyle(Color.brandAccent)
                            .font(.caption)
                        Text(masters.replacingOccurrences(of: "Maestría en ", with: ""))
                            .font(.caption)
                            .foregroundStyle(Color.brandAccent)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(
                    LinearGradient(
                        colors: [Color.brandPrimary.opacity(0.08), Color.brandAccent.opacity(0.06)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .accessibilityLabel("Carrera: \(career)")
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Label(store.currentProfile.location, systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
                .accessibilityLabel("Ubicación: \(store.currentProfile.location)")
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.currentProfile.fieldOfStudy)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.currentProfile.mastersDegree)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Stats row

    @ViewBuilder
    private var statsRow: some View {
        HStack(spacing: 12) {
            GradientMiniStat(
                icon: "person.2.fill",
                value: store.currentProfile.connectionsCount,
                label: "Conexiones",
                gradient: LinearGradient(colors: [Color.brandPrimary, Color.brandSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            GradientMiniStat(
                icon: "sparkles",
                value: store.currentProfile.matchesCount,
                label: "Matches",
                gradient: LinearGradient(colors: [Color.brandSecondary, Color.brandAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            GradientMiniStat(
                icon: "checkmark.seal.fill",
                value: store.currentProfile.completedProjectsCount,
                label: "Proyectos",
                gradient: LinearGradient(colors: [Color.brandAccent, Color.brandGreenLight], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }

    @ViewBuilder
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Sobre mí")
            Text(store.currentProfile.bio)
                .font(.bodyRegular)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Habilidades")
            WrapChips(items: store.currentProfile.skills)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.currentProfile.skills)
    }

    @ViewBuilder
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Intereses")
            WrapChips(items: store.currentProfile.interests, highlighted: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.currentProfile.interests)
    }

    @ViewBuilder
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Preferencias")
            DetailRow(icon: "clock.fill", title: "Disponibilidad", value: "\(store.currentProfile.availabilityHoursPerWeek)h / semana")
            DetailRow(icon: "location.fill", title: "Modalidad preferida", value: store.currentProfile.preferredModality.localizedName)
            DetailRow(icon: "target", title: "Busca", value: store.currentProfile.seekingOpportunityTypes.map(\.localizedName).joined(separator: ", "))
            if let masters = store.currentProfile.mastersDegree, !masters.isEmpty {
                DetailRow(icon: "books.vertical.fill", title: "Maestría", value: masters.replacingOccurrences(of: "Maestría en ", with: ""))
            }
        }
        .cardStyle()
    }
}

// MARK: - Avatar Picker Sheet

struct AvatarPickerSheet: View {
    @Binding var avatarGradientName: String
    @Binding var avatarSystemImage:  String
    @Environment(\.dismiss) var dismiss

    private let symbols = [
        "person.fill", "star.fill", "heart.fill",
        "bolt.fill", "leaf.fill", "flame.fill",
        "moon.fill", "sun.max.fill", "globe.americas.fill",
        "brain.head.profile", "lightbulb.fill", "music.note",
        "paintbrush.fill", "pencil", "book.fill",
        "trophy.fill", "graduationcap.fill", "figure.run",
        "pawprint.fill", "airplane"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Vista previa animada
                    ZStack {
                        Circle()
                            .fill(LinearGradient.avatarGradient(named: avatarGradientName))
                            .frame(width: 100, height: 100)
                            .shadow(color: .black.opacity(0.18), radius: 16, y: 6)
                        Image(systemName: avatarSystemImage)
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: avatarGradientName)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: avatarSystemImage)
                    .padding(.top, 8)

                    Text("Color").font(.caption).foregroundStyle(Color.textSecondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 12)], spacing: 12) {
                        ForEach(LinearGradient.allAvatarGradients, id: \.name) { item in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    avatarGradientName = item.name
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient.avatarGradient(named: item.name))
                                        .frame(width: 56, height: 56)
                                    if avatarGradientName == item.name {
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.caption.weight(.bold))
                                    }
                                }
                            }
                            .accessibilityLabel(AppLanguage.localizedString(item.label))
                            .accessibilityAddTraits(avatarGradientName == item.name ? [.isSelected] : [])
                        }
                    }

                    Text("Ícono").font(.caption).foregroundStyle(Color.textSecondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 12)], spacing: 12) {
                        ForEach(symbols, id: \.self) { symbol in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    avatarSystemImage = symbol
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(avatarSystemImage == symbol
                                              ? AnyShapeStyle(LinearGradient.brandGradient)
                                              : AnyShapeStyle(Color.surfaceSecondary))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: symbol)
                                        .foregroundStyle(avatarSystemImage == symbol ? .white : Color.textSecondary)
                                        .font(.system(size: 24))
                                }
                            }
                            .accessibilityLabel(symbol)
                            .accessibilityAddTraits(avatarSystemImage == symbol ? [.isSelected] : [])
                        }
                    }
                }
                .padding(Layout.screenPadding)
            }
            .navigationTitle("Personalizar avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Chips reutilizables

struct WrapChips: View {
    let items: [String]
    var highlighted: Bool = false
    var body: some View {
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
