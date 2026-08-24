//
//  SignUpView.swift
//  ImpactMatch
//

import SwiftUI

struct SignUpView: View {
    let userType: UserType
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Crea tu cuenta")
                        .font(.screenTitle)
                    Text(userType == .person ? "Regístrate como persona" : "Regístrate como empresa u organización")
                        .font(.bodyRegular)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top, 12)

                VStack(spacing: 14) {
                    LabeledTextField(title: userType == .person ? "Nombre completo" : "Nombre de la organización", text: $name, icon: "person.text.rectangle.fill")
                    LabeledTextField(title: "Correo electrónico", text: $email, icon: "envelope.fill")
                    LabeledTextField(title: "Contraseña", text: $password, icon: "lock.fill", isSecure: true)
                }

                Button {
                    var profile = store.currentProfile
                    profile.name = name.isEmpty ? profile.name : name
                    profile.userType = userType
                    store.currentProfile = profile
                    withAnimation { store.isLoggedIn = true }
                } label: {
                    Text("Crear cuenta")
                }
                .buttonStyle(PrimaryGradientButtonStyle())
                .padding(.top, 6)

                Text("Al continuar aceptas los Términos y la Política de privacidad de ImpactMatch.")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Layout.screenPadding)
        }
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SignUpView(userType: .person) }.environmentObject(AppStore())
}
