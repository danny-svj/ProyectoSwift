//
//  ImpactMatchApp.swift
//  ImpactMatch
//
//  Punto de entrada de la app. Alterna entre el flujo de onboarding
//  (Splash -> Login -> Registro) y la navegación principal por tabs
//  según el estado de sesión guardado en AppStore.
//

import SwiftUI

@main
struct ImpactMatchApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        Group {
            if store.isLoggedIn {
                MainTabView()
                    .transition(.opacity)
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: store.isLoggedIn)
    }
}
