//
//  HomeView.swift
//  ImpactMatch
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedOpportunity: Opportunity?

    var topMatches: [MatchResult] { Array(store.recommendedMatches.prefix(3)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header

                    // Resumen rápido de impacto personal
                    HStack(spacing: 12) {
                        MiniStat(icon: "person.2.fill", value: store.currentProfile.connectionsCount, label: "Conexiones")
                        MiniStat(icon: "hands.sparkles.fill", value: store.currentProfile.matchesCount, label: "Matches")
                        MiniStat(icon: "checkmark.seal.fill", value: store.currentProfile.completedProjectsCount, label: "Proyectos")
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "Mejores compatibilidades para ti")
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
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "El impacto de ImpactMatch")
                        ImpactBanner(stats: store.impactStats)
                    }
                }
                .padding(Layout.screenPadding)
            }
            .background(Color.surfaceSecondary.opacity(0.4))
            .navigationDestination(item: $selectedOpportunity) { opportunity in
                OpportunityDetailView(opportunity: opportunity)
            }
        }
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hola, \(store.currentProfile.name.components(separatedBy: " ").first ?? "")")
                    .font(.displayTitle)
                Text("Encuentra tu próxima alianza")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            ZStack {
                Circle().fill(LinearGradient.brandGradient).frame(width: 44, height: 44)
                Image(systemName: store.currentProfile.avatarSystemImage)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct MiniStat: View {
    let icon: String
    let value: Int
    let label: LocalizedStringKey
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(Color.brandPrimary)
            Text("\(value)").font(.bodyMedium.weight(.bold))
            Text(label).font(.caption).foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct ImpactBanner: View {
    let stats: ImpactStats
    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(stats.alliancesCreated)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("alianzas creadas gracias a la comunidad ImpactMatch")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer()
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(18)
        .background(LinearGradient.impactGradient)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeView().environmentObject(AppStore())
}
