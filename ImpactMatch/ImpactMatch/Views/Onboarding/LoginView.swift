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
                        LabeledTextField(title: "Correo electrónico", text: $email, icon: "envelope.fill")
                        LabeledTextField(title: "Contraseña", text: $password, icon: "lock.fill", isSecure: true)

                        HStack {
                            Spacer()
                            Button("¿Olvidaste tu contraseña?") {}
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }

                    Button {
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
    let title: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(Color.textSecondary)
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(Color.brandPrimary).frame(width: 18)
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                        .textInputAutocapitalization(.never)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
        }
    }
}

#Preview {
    LoginView().environmentObject(AppStore())
}
