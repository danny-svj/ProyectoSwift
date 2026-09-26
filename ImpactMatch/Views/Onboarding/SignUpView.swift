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
    @State private var isSubmitting = false
    @State private var authErrorMessage: String?

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
                heroHeader

                VStack(spacing: 14) {
                    LabeledTextField(title: userType == .person ? "Nombre completo" : "Nombre de la organización", text: $name, icon: "person.text.rectangle.fill", errorMessage: nameError)
                    LabeledTextField(title: "Correo electrónico", text: $email, icon: "envelope.fill", errorMessage: emailError)
                    LabeledTextField(title: "Contraseña", text: $password, icon: "lock.fill", isSecure: true, errorMessage: passwordError)
                }

                if let authErrorMessage {
                    Text(authErrorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.matchLow)
                }

                Button {
                    attemptedSubmit = true
                    guard isValid, !isSubmitting else { return }
                    isSubmitting = true
                    authErrorMessage = nil
                    Task {
                        do {
                            try await store.signUp(email: email, password: password)
                            isSubmitting = false
                            goToProfileSetup = true
                        } catch {
                            isSubmitting = false
                            authErrorMessage = AuthErrorMessages.message(for: error)
                        }
                    }
                } label: {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Continuar")
                    }
                }
                .buttonStyle(PrimaryGradientButtonStyle())
                .disabled(isSubmitting)
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

    // MARK: – Encabezado con degradado de marca

    private var heroHeader: some View {
        VStack(spacing: 10) {
            IMLogoMark(size: 52, style: .white)
            Text("Crea tu cuenta")
                .font(.screenTitle)
                .foregroundStyle(.white)
            Text(userType == .person ? "Regístrate como persona" : "Regístrate como empresa u organización")
                .font(.bodyRegular)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(LinearGradient.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
        .padding(.top, 4)
    }
}

#Preview {
    NavigationStack { SignUpView(userType: .person) }.environmentObject(AppStore())
}
