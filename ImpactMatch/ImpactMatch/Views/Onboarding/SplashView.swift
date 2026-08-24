//
//  SplashView.swift
//  ImpactMatch
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0

    var body: some View {
        if isActive {
            LoginView()
        } else {
            ZStack {
                LinearGradient.brandGradient.ignoresSafeArea()

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 120, height: 120)
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 46, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(spacing: 4) {
                        Text("ImpactMatch")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Conecta talento con propósito")
                            .font(.bodyMedium)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    scale = 1
                    opacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeInOut) { isActive = true }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
