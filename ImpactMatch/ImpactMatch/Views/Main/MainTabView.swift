//
//  MainTabView.swift
//  ImpactMatch
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            ExploreView()
                .tabItem { Label("Explorar", systemImage: "sparkle.magnifyingglass") }

            ConnectionsView()
                .tabItem { Label("Conexiones", systemImage: "person.2.fill") }

            ImpactStatsView()
                .tabItem { Label("Impacto", systemImage: "chart.bar.fill") }

            ProfileView()
                .tabItem { Label("Perfil", systemImage: "person.crop.circle.fill") }
        }
        .tint(Color.brandPrimary)
        .onAppear { NotificationManager.requestPermission() }
    }
}

#Preview {
    MainTabView().environmentObject(AppStore())
}
