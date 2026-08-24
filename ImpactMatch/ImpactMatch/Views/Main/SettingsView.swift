//
//  SettingsView.swift
//  ImpactMatch
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var showConfirmLogout = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Cuenta") {
                    LabeledContent("Nombre", value: store.currentProfile.name)
                    LabeledContent("Tipo de cuenta", value: store.currentProfile.userType.rawValue)
                }

                Section("Preferencias") {
                    Toggle("Notificaciones", isOn: $notificationsEnabled)
                }

                Section("Acerca de ImpactMatch") {
                    LabeledContent("ODS relacionado", value: "17 — Alianzas para lograr los objetivos")
                    LabeledContent("Versión", value: "1.0 (proyecto escolar)")
                }

                Section {
                    Button(role: .destructive) {
                        showConfirmLogout = true
                    } label: {
                        Text("Cerrar sesión")
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                }
            }
            .confirmationDialog("¿Cerrar sesión?", isPresented: $showConfirmLogout, titleVisibility: .visible) {
                Button("Cerrar sesión", role: .destructive) {
                    store.isLoggedIn = false
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SettingsView().environmentObject(AppStore())
}
