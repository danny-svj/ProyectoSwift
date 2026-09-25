//
//  HomeView.swift
//  ImpactMatch
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedOpportunity: Opportunity?
    @State private var showAvatarPicker = false
    @State private var appeared = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var topMatches: [MatchResult] { Array(store.recommendedMatches.prefix(3)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    statsRow
                    matchesSection
                    impactSection
                }
                .padding(Layout.screenPadding)
                .padding(.bottom, 8)
            }
            .background(Color.surfaceSecondary.opacity(0.4))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("ImpactMatchIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
            }
            .navigationDestination(item: $selectedOpportunity) { opportunity in
                OpportunityDetailView(opportunity: opportunity)
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
            .onAppear {
                guard !appeared else { return }
                appeared = true
                if !reduceMotion {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {}
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, \(store.currentProfile.name.components(separatedBy: " ").first ?? "")")
                    .font(.displayTitle)
                    .foregroundStyle(Color.textPrimary)
                Text("Encuentra tu próxima alianza")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.textSecondary)

                if let career = store.currentProfile.fieldOfStudy, !career.isEmpty {
                    Label(career, systemImage: "graduationcap.fill")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color.brandPrimary.opacity(0.12), Color.brandAccent.opacity(0.08)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .foregroundStyle(Color.brandPrimary)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.currentProfile.fieldOfStudy)

            Spacer()

            Button { showAvatarPicker = true } label: {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.avatarGradient(named: store.currentProfile.avatarGradientName))
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.brandPrimary.opacity(0.25), radius: 8, y: 3)
                        Image(systemName: store.currentProfile.avatarSystemImage)
                            .foregroundStyle(.white)
                            .font(.system(size: 21))
                    }
                    ZStack {
                        Circle()
                            .fill(LinearGradient.brandGradient)
                            .frame(width: 18, height: 18)
                        Image(systemName: "pencil")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cambiar avatar, \(store.currentProfile.name)")
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.currentProfile.avatarGradientName)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.currentProfile.avatarSystemImage)
        }
        .padding(.top, 4)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Estadísticas rápidas

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

    // MARK: - Sección de compatibilidades

    @ViewBuilder
    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Mejores compatibilidades para ti")

            if topMatches.isEmpty {
                EmptyStateView(
                    icon: "sparkles",
                    title: "Completa tu perfil",
                    message: "Agrega habilidades e intereses para ver tus compatibilidades."
                )
                .padding(.vertical, 20)
            } else {
                let columns = horizontalSizeClass == .regular
                    ? [GridItem(.flexible()), GridItem(.flexible())]
                    : [GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(topMatches) { match in
                        Button { selectedOpportunity = match.opportunity } label: {
                            OpportunityCard(
                                opportunity: match.opportunity,
                                matchPercent: match.percent,
                                isSaved: store.isSaved(match.opportunity),
                                onSaveTapped: { store.toggleSaved(match.opportunity) }
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Toca para ver el detalle completo")
                    }
                }
            }
        }
    }

    // MARK: - Banner de impacto

    @ViewBuilder
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "El impacto de ImpactMatch")
            ImpactBanner(stats: store.impactStats)
        }
    }
}

// MARK: - MiniStat con degradado

struct GradientMiniStat: View {
    let icon: String
    let value: Int
    let label: LocalizedStringKey
    let gradient: LinearGradient

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(gradient)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text("\(value)")
                .font(.bodyMedium.weight(.bold))
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value) ") + Text(label))
    }
}

// Alias retrocompatible para vistas que usan MiniStat
struct MiniStat: View {
    let icon: String
    let value: Int
    let label: LocalizedStringKey
    var body: some View {
        GradientMiniStat(
            icon: icon,
            value: value,
            label: label,
            gradient: LinearGradient(colors: [Color.brandPrimary, Color.brandSecondary],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}

// MARK: - ImpactBanner

struct ImpactBanner: View {
    let stats: ImpactStats
    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(stats.alliancesCreated)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("alianzas creadas gracias a la comunidad ImpactMatch")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 56, height: 56)
                IMLogoMark(size: 38, style: .white)
            }
        }
        .padding(20)
        .background(LinearGradient.brandGradient)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
        .shadow(color: Color.brandPrimary.opacity(0.30), radius: 14, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(stats.alliancesCreated) alianzas creadas gracias a la comunidad ImpactMatch"))
    }
}

#Preview {
    HomeView().environmentObject(AppStore())
}
