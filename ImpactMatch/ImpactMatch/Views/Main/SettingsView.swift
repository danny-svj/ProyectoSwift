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
    @State private var showConfirmReset = false
    @AppStorage(AppLanguage.storageKey) private var languageCode: String = AppLanguage.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Cuenta") {
                    LabeledContent("Nombre", value: store.currentProfile.name)
                    LabeledContent("Tipo de cuenta", value: store.currentProfile.userType.localizedName)
                }

                Section {
                    Toggle("Notificaciones", isOn: $notificationsEnabled)
                    Picker("Idioma", selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language.rawValue)
                        }
                    }
                } header: {
                    Text("Preferencias")
                } footer: {
                    Text("Cambia el idioma de inmediato, sin reiniciar la app.")
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

                Section {
                    Button(role: .destructive) {
                        showConfirmReset = true
                    } label: {
                        Text("Restablecer datos de la demo")
                    }
                } footer: {
                    Text("Borra tu perfil, oportunidades creadas, solicitudes y conexiones, y vuelve a los datos de ejemplo. Útil antes de una presentación.")
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
            .confirmationDialog("¿Restablecer todos los datos?", isPresented: $showConfirmReset, titleVisibility: .visible) {
                Button("Restablecer", role: .destructive) {
                    store.resetToDemoDefaults()
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esto no se puede deshacer.")
            }
        }
    }
}

#Preview {
    SettingsView().environmentObject(AppStore())
}
