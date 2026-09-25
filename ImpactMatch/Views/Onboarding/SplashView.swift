//
//  SplashView.swift
//  ImpactMatch
//

import SwiftUI

struct SplashView: View {
    @State private var isActive        = false

    // Logo card
    @State private var cardScale:      CGFloat = 0.3
    @State private var cardOpacity:    Double  = 0
    @State private var cardRotation:   Double  = -8

    // Glow
    @State private var glowRadius:     CGFloat = 60
    @State private var glowOpacity:    Double  = 0

    // Radar rings
    @State private var ringScales:     [CGFloat] = [0.2, 0.2, 0.2]
    @State private var ringOpacities:  [Double]  = [0.9, 0.9, 0.9]

    // Scanner sobre el logo
    @State private var scanY:          CGFloat = -90
    @State private var scanOpacity:    Double  = 0

    // Texto
    @State private var typedCount:     Int     = 0
    @State private var taglineOp:      Double  = 0

    // Progreso
    @State private var progress:       CGFloat = 0

    // Orbes de fondo
    @State private var orb1Y:          CGFloat = 0
    @State private var orb2Y:          CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title = "IMPACTMATCH"

    // ─────────────────────────────────────────────────────────────────
    var body: some View {
        if isActive {
            LoginView()
        } else {
            ZStack {
                background
                dotGrid
                floatingOrbs

                // Radar rings centrados en el logo
                radarRings

                // Glow tras el logo
                centralGlow

                // Contenido
                VStack(spacing: 0) {
                    Spacer()
                    logoCard
                    Spacer().frame(height: 44)
                    brandText
                    Spacer()
                    progressBar
                }
            }
            .ignoresSafeArea()
            .accessibilityLabel("ImpactMatch — Iniciando")
            .onAppear { beginSequence() }
        }
    }

    // MARK: – Fondo

    private var background: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.010, green: 0.048, blue: 0.170), location: 0),
                .init(color: Color(red: 0.040, green: 0.120, blue: 0.340), location: 0.30),
                .init(color: Color(red: 0.102, green: 0.318, blue: 0.659), location: 0.62),
                .init(color: Color(red: 0.240, green: 0.600, blue: 0.310), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var dotGrid: some View {
        Canvas { ctx, size in
            let sp: CGFloat = 30, r: CGFloat = 0.9
            var col = 0
            while CGFloat(col) * sp < size.width + sp {
                var row = 0
                while CGFloat(row) * sp < size.height + sp {
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: CGFloat(col)*sp - r,
                                               y: CGFloat(row)*sp - r,
                                               width: r*2, height: r*2)),
                        with: .color(.white.opacity(0.09))
                    )
                    row += 1
                }
                col += 1
            }
        }
        .ignoresSafeArea()
    }

    private var floatingOrbs: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.05)).frame(width: 250, height: 250).blur(radius: 6)
                .offset(x: -110, y: -260 + orb1Y)
            Circle()
                .fill(Color(red: 0.30, green: 0.72, blue: 0.28).opacity(0.10)).frame(width: 190, height: 190).blur(radius: 10)
                .offset(x: 125, y: 260 + orb2Y)
        }
    }

    private var radarRings: some View {
        let colors: [Color] = [
            Color(red: 0.17, green: 0.56, blue: 0.77),
            Color(red: 0.30, green: 0.72, blue: 0.28),
            .white
        ]
        return ZStack {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(colors[i].opacity(0.35), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .scaleEffect(ringScales[i])
                    .opacity(ringOpacities[i])
            }
        }
    }

    private var centralGlow: some View {
        RadialGradient(
            colors: [Color(red: 0.17, green: 0.56, blue: 0.77).opacity(0.45), .clear],
            center: .center, startRadius: 0, endRadius: glowRadius
        )
        .frame(width: 300, height: 300)
        .opacity(glowOpacity)
    }

    // MARK: – Logo card

    private var logoCard: some View {
        ZStack {
            // Scanner que barre el logo
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color(red: 0.55, green: 0.84, blue: 0.24).opacity(0.70), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: 180, height: 2)
                .blur(radius: 1)
                .offset(y: scanY)
                .opacity(scanOpacity)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            // Brackets HUD en las 4 esquinas
            HUDFrame(size: 210)
                .opacity(cardOpacity)

            // Símbolo iM sin fondo, directo sobre el degradado
            ZStack {
                // Resplandor suave detrás del ícono
                Circle()
                    .fill(RadialGradient(
                        colors: [.white.opacity(0.18), .clear],
                        center: .center, startRadius: 0, endRadius: 90
                    ))
                    .frame(width: 180, height: 180)

                Image("ImpactMatchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .shadow(color: Color(red: 0.30, green: 0.72, blue: 0.28).opacity(0.6), radius: 20, y: 4)
            }
            .frame(width: 180, height: 180)
        }
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0.3, y: 1, z: 0))
    }

    // MARK: – Texto

    private var brandText: some View {
        VStack(spacing: 9) {
            HStack(spacing: 0) {
                Text(String(title.prefix(min(typedCount, 6))))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                if typedCount > 6 {
                    Text(String(title.dropFirst(6).prefix(typedCount - 6)))
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.84, blue: 0.24))
                }

                if typedCount < title.count {
                    BlinkingCursor()
                }
            }

            Text("FINDING YOUR FUTURE")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(4.5)
                .foregroundStyle(.white.opacity(0.45))
                .opacity(taglineOp)
        }
    }

    // MARK: – Barra de progreso

    private var progressBar: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.10))
                    .frame(width: 160, height: 3)
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.10, green: 0.32, blue: 0.66),
                                     Color(red: 0.55, green: 0.84, blue: 0.24)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: progress * 160, height: 3)
            }
            Text("INICIANDO SISTEMA...")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.22))
        }
        .padding(.bottom, 60)
    }

    // MARK: – Secuencia de animación

    private func beginSequence() {
        guard !reduceMotion else {
            cardScale = 1; cardOpacity = 1; cardRotation = 0
            glowOpacity = 1; typedCount = title.count; taglineOp = 1; progress = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { isActive = true }
            return
        }

        // Orbes flotantes
        withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) { orb1Y = 26 }
        withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) { orb2Y = -22 }

        // Glow
        withAnimation(.easeOut(duration: 0.9).delay(0.15)) { glowOpacity = 1 }

        // Logo card — spring con rebote + giro 3D
        withAnimation(.spring(response: 0.70, dampingFraction: 0.48).delay(0.20)) {
            cardScale    = 1
            cardOpacity  = 1
            cardRotation = 0
        }

        // Radar pulsos (stagger, loop infinito)
        for i in 0..<3 {
            let d = 0.55 + Double(i) * 0.40
            withAnimation(.easeOut(duration: 1.9).repeatForever(autoreverses: false).delay(d)) {
                ringScales[i] = 2.5
            }
            withAnimation(.easeIn(duration: 1.1).repeatForever(autoreverses: false).delay(d + 0.8)) {
                ringOpacities[i] = 0
            }
        }

        // Scanner doble pasada
        runScanner(after: 0.85)

        // Typewriter
        for i in 0..<title.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05 + Double(i) * 0.080) {
                typedCount = i + 1
            }
        }
        let textEnd = 1.05 + Double(title.count) * 0.080
        withAnimation(.easeOut(duration: 0.45).delay(textEnd + 0.28)) { taglineOp = 1 }

        // Barra de progreso
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 3.2)) { progress = 1 }
        }

        // Transición
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            withAnimation(.easeInOut(duration: 0.45)) { isActive = true }
        }
    }

    private func runScanner(after delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            scanY = -90
            withAnimation(.easeIn(duration: 0.12))  { scanOpacity = 1 }
            withAnimation(.linear(duration: 0.52))  { scanY = 90 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.56) {
                withAnimation(.easeOut(duration: 0.18)) { scanOpacity = 0 }
                // Segundo pase
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    scanY = -90
                    withAnimation(.easeIn(duration: 0.12))  { scanOpacity = 1 }
                    withAnimation(.linear(duration: 0.52))  { scanY = 90 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.56) {
                        withAnimation(.easeOut(duration: 0.18)) { scanOpacity = 0 }
                    }
                }
            }
        }
    }
}

// MARK: – Cursor parpadeante

private struct BlinkingCursor: View {
    @State private var visible = true
    var body: some View {
        Rectangle()
            .fill(.white.opacity(visible ? 0.85 : 0))
            .frame(width: 3, height: 35)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.45).repeatForever()) { visible = false }
            }
    }
}

// MARK: – Marco HUD (4 brackets)

private struct HUDFrame: View {
    let size: CGFloat
    private let arm: CGFloat = 20
    private let lw:  CGFloat = 2.5

    var body: some View {
        Canvas { ctx, cs in
            let w = cs.width, h = cs.height
            let color = GraphicsContext.Shading.color(
                Color(red: 0.55, green: 0.84, blue: 0.24).opacity(0.75)
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
    SplashView()
}
