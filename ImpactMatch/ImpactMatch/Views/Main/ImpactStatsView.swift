//
//  ImpactStatsView.swift
//  ImpactMatch
//

import SwiftUI

struct ImpactStatsView: View {
    @EnvironmentObject var store: AppStore

    var columns: [GridItem] { [GridItem(.flexible()), GridItem(.flexible())] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Impacto de la comunidad").font(.screenTitle)
                        Text("ODS 17 · Alianzas para lograr los objetivos")
                            .font(.caption)
                            .foregroundStyle(Color.brandPrimary)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        StatCard(value: store.impactStats.connectedPeople, label: "Personas conectadas", icon: "person.2.fill", tint: .brandPrimary)
                        StatCard(value: store.impactStats.matchesMade, label: "Matches realizados", icon: "sparkles", tint: .brandSecondary)
                        StatCard(value: store.impactStats.opportunitiesPosted, label: "Oportunidades publicadas", icon: "briefcase.fill", tint: .matchMid)
                        StatCard(value: store.impactStats.alliancesCreated, label: "Alianzas creadas", icon: "hands.sparkles.fill", tint: .brandAccent)
                        StatCard(value: store.impactStats.completedProjects, label: "Proyectos completados", icon: "checkmark.seal.fill", tint: .matchHigh)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Cómo contribuyes tú")
                        VStack(spacing: 10) {
                            DetailRow(icon: "person.2.fill", title: "Tus conexiones", value: "\(store.currentProfile.connectionsCount)")
                            DetailRow(icon: "sparkles", title: "Tus matches", value: "\(store.currentProfile.matchesCount)")
                            DetailRow(icon: "checkmark.seal.fill", title: "Proyectos completados", value: "\(store.currentProfile.completedProjectsCount)")
                        }
                        .cardStyle()
                    }

                    Text("Estos números representan cómo ImpactMatch conecta personas, empresas y organizaciones para construir alianzas reales alineadas al ODS 17.")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(Layout.screenPadding)
            }
            .background(Color.surfaceSecondary.opacity(0.4))
            .navigationTitle("Impacto")
        }
    }
}

#Preview {
    ImpactStatsView().environmentObject(AppStore())
}
