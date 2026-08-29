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
    @State private var attemptedSubmit = false

    private var nameError: String? {
        guard attemptedSubmit else { return nil }
        guard name.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return userType == .person
            ? AppLanguage.localizedString("Ingresa tu nombre.")
            : AppLanguage.localizedString("Ingresa el nombre de la organización.")
    }

    private var emailError: String? {
        guard attemptedSubmit else { return nil }
        if email.isEmpty { return AppLanguage.localizedString("Ingresa tu correo electrónico.") }
        if !FormValidation.isValidEmail(email) { return AppLanguage.localizedString("Ingresa un correo válido.") }
        return nil
    }

    private var passwordError: String? {
        guard attemptedSubmit else { return nil }
        if password.isEmpty { return AppLanguage.localizedString("Ingresa tu contraseña.") }
        if !FormValidation.isValidPassword(password) { return AppLanguage.localizedString("Debe tener al menos \(FormValidation.minPasswordLength) caracteres.") }
        return nil
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && FormValidation.isValidEmail(email)
            && FormValidation.isValidPassword(password)
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
                    LabeledTextField(title: userType == .person ? "Nombre completo" : "Nombre de la organización", text: $name, icon: "person.text.rectangle.fill", errorMessage: nameError)
                    LabeledTextField(title: "Correo electrónico", text: $email, icon: "envelope.fill", errorMessage: emailError)
                    LabeledTextField(title: "Contraseña", text: $password, icon: "lock.fill", isSecure: true, errorMessage: passwordError)
                }

                Button {
                    attemptedSubmit = true
                    guard isValid else { return }
                    goToProfileSetup = true
                } label: {
                    Text("Continuar")
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
        .navigationDestination(isPresented: $goToProfileSetup) {
            ProfileEditorView(mode: .create(userType: userType, name: name))
        }
    }
}

#Preview {
    NavigationStack { SignUpView(userType: .person) }.environmentObject(AppStore())
}
