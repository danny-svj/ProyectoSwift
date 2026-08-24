//
//  Theme.swift
//  ImpactMatch
//
//  Sistema de diseño central de la app: colores, gradientes, tipografía
//  y modificadores reutilizables para mantener una identidad visual
//  consistente y profesional en toda la aplicación.
//

import SwiftUI

// MARK: - Paleta de colores

extension Color {
    // Marca principal — degradado violeta -> azul, transmite confianza + innovación
    static let brandPrimary = Color(red: 0.42, green: 0.31, blue: 0.98)      // #6B4FFA
    static let brandSecondary = Color(red: 0.20, green: 0.60, blue: 0.98)    // #3399FA
    static let brandAccent = Color(red: 0.13, green: 0.85, blue: 0.68)       // #22D9AE (verde impacto)

    // Semánticos de compatibilidad
    static let matchHigh = Color(red: 0.13, green: 0.78, blue: 0.55)   // 85-100%
    static let matchMid = Color(red: 0.98, green: 0.68, blue: 0.16)    // 60-84%
    static let matchLow = Color(red: 0.94, green: 0.42, blue: 0.42)    // <60%

    // Superficies
    static let surfacePrimary = Color(.systemBackground)
    static let surfaceSecondary = Color(.secondarySystemBackground)
    static let surfaceCard = Color(.systemBackground)

    // Texto
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
}

extension LinearGradient {
    static let brandGradient = LinearGradient(
        colors: [Color.brandPrimary, Color.brandSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let impactGradient = LinearGradient(
        colors: [Color.brandAccent, Color.brandSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func matchGradient(for score: Int) -> LinearGradient {
        let color = Color.forMatchScore(score)
        return LinearGradient(colors: [color.opacity(0.85), color], startPoint: .leading, endPoint: .trailing)
    }
}

extension Color {
    static func forMatchScore(_ score: Int) -> Color {
        switch score {
        case 85...100: return .matchHigh
        case 60..<85: return .matchMid
        default: return .matchLow
        }
    }
}

// MARK: - Tipografía

extension Font {
    static let displayTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let screenTitle = Font.system(size: 24, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let bodyRegular = Font.system(size: 15, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .medium)
    static let caption = Font.system(size: 12, weight: .medium)
    static let statNumber = Font.system(size: 26, weight: .bold, design: .rounded)
}

// MARK: - Espaciado y radios consistentes

enum Layout {
    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 16
    static let chipRadius: CGFloat = 12
    static let screenPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 16
}

// MARK: - Estilo de tarjeta reutilizable

struct CardBackground: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }
}

// MARK: - Botón primario con degradado de marca

struct PrimaryGradientButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isDisabled ? AnyShapeStyle(Color.gray.opacity(0.35)) : AnyShapeStyle(LinearGradient.brandGradient))
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium.weight(.semibold))
            .foregroundStyle(Color.brandPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.brandPrimary.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
