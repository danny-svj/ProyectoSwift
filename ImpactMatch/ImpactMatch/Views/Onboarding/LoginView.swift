//
//  LoginView.swift
//  ImpactMatch
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var email = ""
    @State private var password = ""
    @State private var goToSignUp = false
    @State private var attemptedSubmit = false

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
        FormValidation.isValidEmail(email) && FormValidation.isValidPassword(password)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(LinearGradient.brandGradient).frame(width: 72, height: 72)
                            Image(systemName: "hands.sparkles.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        Text("Bienvenido de vuelta")
                            .font(.screenTitle)
                        Text("Inicia sesión para seguir creando alianzas")
                            .font(.bodyRegular)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 14) {
                        LabeledTextField(title: "Correo electrónico", text: $email, icon: "envelope.fill", errorMessage: emailError)
                        LabeledTextField(title: "Contraseña", text: $password, icon: "lock.fill", isSecure: true, errorMessage: passwordError)

                        HStack {
                            Spacer()
                            Button("¿Olvidaste tu contraseña?") {}
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }

                    Button {
                        attemptedSubmit = true
                        guard isValid else { return }
                        withAnimation { store.isLoggedIn = true }
                    } label: {
                        Text("Iniciar sesión")
                    }
                    .buttonStyle(PrimaryGradientButtonStyle())

                    HStack {
                        VStack { Divider() }
                        Text("o").font(.caption).foregroundStyle(Color.textTertiary)
                        VStack { Divider() }
                    }

                    Button {
                        goToSignUp = true
                    } label: {
                        Text("Crear una cuenta nueva")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(Layout.screenPadding)
            }
            .navigationDestination(isPresented: $goToSignUp) {
                UserTypeSelectionView()
            }
        }
    }
}

struct LabeledTextField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false
    var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(Color.textSecondary)
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(Color.brandPrimary).frame(width: 18)
                if isSecure {
                    SecureField("", text: $text)
                        .accessibilityLabel(Text(title))
                } else {
                    TextField("", text: $text)
                        .textInputAutocapitalization(.never)
                        .accessibilityLabel(Text(title))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous)
                    .stroke(errorMessage != nil ? Color.matchLow : .clear, lineWidth: 1.5)
            )
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.matchLow)
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AppStore())
}
