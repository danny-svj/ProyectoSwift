//
//  ExploreView.swift
//  ImpactMatch
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""
    @State private var selectedType: OpportunityType? = nil
    @State private var selectedOpportunity: Opportunity?
    @State private var showCreateSheet = false

    var filteredMatches: [MatchResult] {
        store.recommendedMatches.filter { match in
            let matchesType = selectedType == nil || match.opportunity.type == selectedType
            let matchesSearch = searchText.isEmpty
                || match.opportunity.title.localizedCaseInsensitiveContains(searchText)
                || match.opportunity.organizationName.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    searchBar
                    filterChips

                    VStack(spacing: 14) {
                        ForEach(filteredMatches) { match in
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

                        if filteredMatches.isEmpty {
                            EmptyStateView(icon: "magnifyingglass", title: "Sin resultados", message: "Prueba con otro término o filtro.")
                                .padding(.top, 40)
                        }
                    }
                }
                .padding(Layout.screenPadding)
            }
            .background(Color.surfaceSecondary.opacity(0.4))
            .navigationTitle("Explorar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCreateSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
            .navigationDestination(item: $selectedOpportunity) { opportunity in
                OpportunityDetailView(opportunity: opportunity)
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateOpportunityView()
            }
        }
    }

    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(Color.textTertiary)
            TextField("Buscar oportunidades...", text: $searchText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
    }

    var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "Todas", isSelected: selectedType == nil) { selectedType = nil }
                ForEach(OpportunityType.allCases) { type in
                    FilterChip(title: type.rawValue, isSelected: selectedType == type) { selectedType = type }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AnyShapeStyle(LinearGradient.brandGradient) : AnyShapeStyle(Color.surfaceCard))
                .foregroundStyle(isSelected ? .white : Color.textSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 34)).foregroundStyle(Color.textTertiary)
            Text(title).font(.cardTitle)
            Text(message).font(.caption).foregroundStyle(Color.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ExploreView().environmentObject(AppStore())
}
