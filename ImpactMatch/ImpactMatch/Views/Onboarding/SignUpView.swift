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
    @State private var goToProfileSetup = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !email.isEmpty && !password.isEmpty
    }

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
                    goToProfileSetup = true
                } label: {
                    Text("Continuar")
                }
                .buttonStyle(PrimaryGradientButtonStyle(isDisabled: !isValid))
                .disabled(!isValid)
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
        .navigationDestination(isPresented: $goToProfileSetup) {
            ProfileEditorView(mode: .create(userType: userType, name: name))
        }
    }
}

#Preview {
    NavigationStack { SignUpView(userType: .person) }.environmentObject(AppStore())
}
