//
//  LoginView.swift
//  ImpactMatch
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var email           = ""
    @State private var password        = ""
    @State private var goToSignUp      = false
    @State private var attemptedSubmit = false

    // Animaciones de entrada
    @State private var logoScale:     CGFloat = 0.5
    @State private var logoOpacity:   Double  = 0
    @State private var logoRotation:  Double  = -10
    @State private var ring1Scale:    CGFloat = 0.2
    @State private var ring1Opacity:  Double  = 0.8
    @State private var ring2Scale:    CGFloat = 0.2
    @State private var ring2Opacity:  Double  = 0.8
    @State private var cardOffset:    CGFloat = 50
    @State private var cardOpacity:   Double  = 0
    @State private var heroOpacity:   Double  = 0
    @State private var scanY:         CGFloat = -70
    @State private var scanOpacity:   Double  = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var emailError: String? {
        guard attemptedSubmit else { return nil }
        if email.isEmpty { return AppLanguage.localizedString("Ingresa tu correo electrónico.") }
        if !FormValidation.isValidEmail(email) { return AppLanguage.localizedString("Ingresa un correo válido.") }
        return nil
    }

    private var passwordError: String? {
        guard attemptedSubmit else { return nil }
        if password.isEmpty { return AppLanguage.localizedString("Ingresa tu contraseña.") }
        if !FormValidation.isValidPassword(password) {
            return AppLanguage.localizedString("Debe tener al menos \(FormValidation.minPasswordLength) caracteres.")
        }
        return nil
    }

    private var isValid: Bool {
        FormValidation.isValidEmail(email) && FormValidation.isValidPassword(password)
    }

    // ─────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground).ignoresSafeArea()

                // Sección hero fija (fondo)
                VStack(spacing: 0) {
                    heroSection
                    Spacer()
                }

                // Scroll con la tarjeta de formulario
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 248)

                        formCard
                            .padding(.horizontal, Layout.screenPadding)
                            .offset(y: reduceMotion ? 0 : cardOffset)
                            .opacity(cardOpacity)

                        Spacer(minLength: 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $goToSignUp) {
                UserTypeSelectionView()
            }
            .onAppear { runEntrance() }
        }
    }

    // MARK: – Hero futurista

    private var heroSection: some View {
        ZStack {
            // Fondo con degradado oscuro-azul-verde
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.010, green: 0.048, blue: 0.170), location: 0),
                    .init(color: Color(red: 0.060, green: 0.160, blue: 0.380), location: 0.45),
                    .init(color: Color(red: 0.102, green: 0.318, blue: 0.659), location: 0.75),
                    .init(color: Color(red: 0.220, green: 0.560, blue: 0.300), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Cuadrícula de puntos (HUD)
            Canvas { ctx, size in
                let sp: CGFloat = 28, r: CGFloat = 0.8
                var col = 0
                while CGFloat(col) * sp < size.width + sp {
                    var row = 0
                    while CGFloat(row) * sp < size.height + sp {
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: CGFloat(col)*sp - r,
                                                   y: CGFloat(row)*sp - r,
                                                   width: r*2, height: r*2)),
                            with: .color(.white.opacity(0.08))
                        )
                        row += 1
                    }
                    col += 1
                }
            }

            // Orbes decorativos
            Circle()
                .fill(.white.opacity(0.05)).frame(width: 160, height: 160).blur(radius: 4)
                .offset(x: -120, y: -30)
            Circle()
                .fill(Color(red: 0.30, green: 0.72, blue: 0.28).opacity(0.08)).frame(width: 130, height: 130).blur(radius: 6)
                .offset(x: 130, y: 50)

            // Radar rings
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(red: 0.17, green: 0.56, blue: 0.77).opacity(0.35), lineWidth: 1.5)
                    .frame(width: 145, height: 145)
                    .scaleEffect(ring1Scale)
                    .opacity(ring1Opacity)
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color(red: 0.30, green: 0.72, blue: 0.28).opacity(0.28), lineWidth: 1)
                    .frame(width: 145, height: 145)
                    .scaleEffect(ring2Scale)
                    .opacity(ring2Opacity)
            }
            .offset(y: 10)

            // Logo + scanner
            VStack(spacing: 14) {
                Spacer(minLength: 60)

                ZStack {
                    // Scanner sweep
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(red: 0.55, green: 0.84, blue: 0.24).opacity(0.65), .clear],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: 130, height: 2)
                        .offset(y: scanY)
                        .opacity(scanOpacity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Brackets HUD
                    HUDFrameLogin(size: 140)
                        .opacity(logoOpacity)

                    // Símbolo iM sin fondo, directo sobre el degradado
                    ZStack {
                        Circle()
                            .fill(RadialGradient(
                                colors: [.white.opacity(0.15), .clear],
                                center: .center, startRadius: 0, endRadius: 60
                            ))
                            .frame(width: 120, height: 120)

                        Image("ImpactMatchIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(color: Color(red: 0.30, green: 0.72, blue: 0.28).opacity(0.55), radius: 14, y: 3)
                    }
                    .frame(width: 120, height: 120)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .rotation3DEffect(.degrees(logoRotation), axis: (x: 0.2, y: 1, z: 0))

                // Bienvenida
                VStack(spacing: 4) {
                    Text("Bienvenido de vuelta")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    Text("Inicia sesión para seguir creando alianzas")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(logoOpacity)

                Spacer(minLength: 52)
            }
        }
        .frame(height: 310)
        .opacity(heroOpacity)
        .clipped()
    }

    // MARK: – Tarjeta de formulario

    private var formCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                LabeledTextField(title: "Correo electrónico", text: $email,
                                 icon: "envelope.fill", errorMessage: emailError)
                LabeledTextField(title: "Contraseña", text: $password,
                                 icon: "lock.fill", isSecure: true, errorMessage: passwordError)
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

            Button { goToSignUp = true } label: {
                Text("Crear una cuenta nueva")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(20)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 10)
    }

    // MARK: – Animación de entrada

    private func runEntrance() {
        if reduceMotion {
            heroOpacity = 1; logoScale = 1; logoOpacity = 1; logoRotation = 0
            ring1Scale = 2; ring1Opacity = 0; ring2Scale = 2; ring2Opacity = 0
            cardOffset = 0; cardOpacity = 1
            return
        }

        // Hero funde
        withAnimation(.easeOut(duration: 0.55)) { heroOpacity = 1 }

        // Logo entra con 3D spring
        withAnimation(.spring(response: 0.70, dampingFraction: 0.50).delay(0.25)) {
            logoScale    = 1
            logoOpacity  = 1
            logoRotation = 0
        }

        // Radar rings (loop)
        withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(0.50)) {
            ring1Scale = 2.2
        }
        withAnimation(.easeIn(duration: 1.0).repeatForever(autoreverses: false).delay(1.1)) {
            ring1Opacity = 0
        }
        withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(0.85)) {
            ring2Scale = 2.4
        }
        withAnimation(.easeIn(duration: 1.0).repeatForever(autoreverses: false).delay(1.5)) {
            ring2Opacity = 0
        }

        // Scanner sweep
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            scanY = -70
            withAnimation(.easeIn(duration: 0.12))  { scanOpacity = 1 }
            withAnimation(.linear(duration: 0.48))  { scanY = 70 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
                withAnimation(.easeOut(duration: 0.18)) { scanOpacity = 0 }
            }
        }

        // Tarjeta de formulario sube con spring
        withAnimation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.35)) {
            cardOffset  = 0
            cardOpacity = 1
        }
    }
}

// MARK: – Campo de texto con etiqueta

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
                Image(systemName: icon)
                    .foregroundStyle(Color.brandPrimary)
                    .frame(width: 18)
                if isSecure {
                    SecureField("", text: $text).accessibilityLabel(Text(title))
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
            if let msg = errorMessage {
                Text(msg).font(.caption).foregroundStyle(Color.matchLow)
            }
        }
    }
}

// MARK: – HUD Frame (login - versión pequeña)

private struct HUDFrameLogin: View {
    let size: CGFloat
    private let arm: CGFloat = 16
    private let lw:  CGFloat = 2

    var body: some View {
        Canvas { ctx, cs in
            let w = cs.width, h = cs.height
            let color = GraphicsContext.Shading.color(
                Color(red: 0.55, green: 0.84, blue: 0.24).opacity(0.70)
            )
            func bracket(_ path: Path) { ctx.stroke(path, with: color, lineWidth: lw) }
            var p = Path()
            p.move(to: CGPoint(x: 0, y: arm)); p.addLine(to: .zero); p.addLine(to: CGPoint(x: arm, y: 0))
            bracket(p)
            p = Path()
            p.move(to: CGPoint(x: w-arm, y: 0)); p.addLine(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: w, y: arm))
            bracket(p)
            p = Path()
            p.move(to: CGPoint(x: w, y: h-arm)); p.addLine(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: w-arm, y: h))
            bracket(p)
            p = Path()
            p.move(to: CGPoint(x: arm, y: h)); p.addLine(to: CGPoint(x: 0, y: h)); p.addLine(to: CGPoint(x: 0, y: h-arm))
            bracket(p)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    LoginView().environmentObject(AppStore())
}
