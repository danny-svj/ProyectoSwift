//
//  Theme.swift
//  ImpactMatch
//
//  Sistema de diseño central: colores, gradientes, tipografía,
//  logo de marca y modificadores reutilizables.
//

import SwiftUI

// MARK: - Paleta de colores (logo ImpactMatch: azul profundo → verde)

extension Color {
    // Azul profundo del "i" / persona del logo
    static let brandPrimary   = Color(red: 0.102, green: 0.318, blue: 0.659)  // #1A51A8
    // Azul-teal de transición
    static let brandSecondary = Color(red: 0.169, green: 0.557, blue: 0.773)  // #2B8EC5
    // Verde del "m" / flecha del logo
    static let brandAccent    = Color(red: 0.306, green: 0.718, blue: 0.278)  // #4EB747
    // Verde lima claro para detalles
    static let brandGreenLight = Color(red: 0.557, green: 0.839, blue: 0.243) // #8ED73E

    // Semánticos de compatibilidad
    static let matchHigh = Color(red: 0.13, green: 0.78, blue: 0.55)
    static let matchMid  = Color(red: 0.98, green: 0.68, blue: 0.16)
    static let matchLow  = Color(red: 0.94, green: 0.42, blue: 0.42)

    // Superficies
    static let surfacePrimary   = Color(.systemBackground)
    static let surfaceSecondary = Color(.secondarySystemBackground)
    static let surfaceCard      = Color(.systemBackground)

    // Texto
    static let textPrimary   = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary  = Color(.tertiaryLabel)
}

extension LinearGradient {
    // Degradado principal del logo: azul → verde
    static let brandGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.102, green: 0.318, blue: 0.659), location: 0),
            .init(color: Color(red: 0.169, green: 0.557, blue: 0.773), location: 0.45),
            .init(color: Color(red: 0.306, green: 0.718, blue: 0.278), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Degradado de acento: teal → verde (banners secundarios)
    static let impactGradient = LinearGradient(
        colors: [Color.brandSecondary, Color.brandAccent],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Degradado hero para pantallas completas (splash, hero login)
    static let heroGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.055, green: 0.188, blue: 0.455), location: 0),
            .init(color: Color(red: 0.102, green: 0.318, blue: 0.659), location: 0.38),
            .init(color: Color(red: 0.169, green: 0.557, blue: 0.773), location: 0.72),
            .init(color: Color(red: 0.306, green: 0.718, blue: 0.278), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Gradientes de avatar
    static let gradientSunset = LinearGradient(
        colors: [Color(red: 0.98, green: 0.55, blue: 0.20), Color(red: 0.94, green: 0.25, blue: 0.48)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientOcean = LinearGradient(
        colors: [Color(red: 0.12, green: 0.78, blue: 0.92), Color(red: 0.08, green: 0.45, blue: 0.98)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientForest = LinearGradient(
        colors: [Color(red: 0.13, green: 0.82, blue: 0.55), Color(red: 0.06, green: 0.52, blue: 0.32)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientFire = LinearGradient(
        colors: [Color(red: 0.98, green: 0.82, blue: 0.10), Color(red: 0.96, green: 0.38, blue: 0.08)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientNight = LinearGradient(
        colors: [Color(red: 0.18, green: 0.12, blue: 0.48), Color(red: 0.46, green: 0.12, blue: 0.80)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientRose = LinearGradient(
        colors: [Color(red: 0.98, green: 0.40, blue: 0.72), Color(red: 0.70, green: 0.15, blue: 0.90)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static func avatarGradient(named name: String) -> LinearGradient {
        switch name {
        case "sunset": return gradientSunset
        case "ocean":  return gradientOcean
        case "forest": return gradientForest
        case "fire":   return gradientFire
        case "night":  return gradientNight
        case "rose":   return gradientRose
        default:       return brandGradient
        }
    }

    static let allAvatarGradients: [(name: String, label: String)] = [
        ("brand",  "Marca"),
        ("ocean",  "Océano"),
        ("sunset", "Atardecer"),
        ("forest", "Bosque"),
        ("fire",   "Fuego"),
        ("rose",   "Rosa"),
        ("night",  "Noche"),
    ]

    static func matchGradient(for score: Int) -> LinearGradient {
        let color = Color.forMatchScore(score)
        return LinearGradient(colors: [color.opacity(0.85), color], startPoint: .leading, endPoint: .trailing)
    }
}

extension Color {
    static func forMatchScore(_ score: Int) -> Color {
        switch score {
        case 85...100: return .matchHigh
        case 60..<85:  return .matchMid
        default:       return .matchLow
        }
    }

    static func matchTierLabel(for score: Int) -> String {
        switch score {
        case 85...100: AppLanguage.localizedString("alta")
        case 60..<85:  AppLanguage.localizedString("media")
        default:       AppLanguage.localizedString("baja")
        }
    }
}

// MARK: - Logo de marca ImpactMatch

/// Logo "IM": figura de persona (azul) + flecha diagonal (verde),
/// igual al logo oficial de ImpactMatch.
struct IMLogoMark: View {
    var size: CGFloat = 80
    var style: Style = .gradient

    enum Style {
        case gradient  // Colores del logo (para fondos claros)
        case white     // Blanco (para fondos oscuros/degradados)
    }

    var body: some View {
        ZStack {
            personSymbol
            arrowSymbol
        }
        .frame(width: size, height: size)
    }

    private var personSymbol: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.54, height: size * 0.54)
            .foregroundStyle(personStyle)
            .offset(x: -size * 0.13, y: size * 0.04)
    }

    private var arrowSymbol: some View {
        Image(systemName: "arrow.up.right")
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.31, height: size * 0.31)
            .fontWeight(.black)
            .foregroundStyle(arrowStyle)
            .offset(x: size * 0.24, y: -size * 0.14)
    }

    private var personStyle: AnyShapeStyle {
        switch style {
        case .gradient:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.102, green: 0.318, blue: 0.659),
                         Color(red: 0.169, green: 0.557, blue: 0.773)],
                startPoint: .top, endPoint: .bottom
            ))
        case .white:
            return AnyShapeStyle(Color.white)
        }
    }

    private var arrowStyle: AnyShapeStyle {
        switch style {
        case .gradient:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.169, green: 0.557, blue: 0.773),
                         Color(red: 0.306, green: 0.718, blue: 0.278)],
                startPoint: .bottomLeading, endPoint: .topTrailing
            ))
        case .white:
            return AnyShapeStyle(Color.white.opacity(0.92))
        }
    }
}

// MARK: - Tipografía

extension Font {
    static let displayTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let screenTitle  = Font.system(.title, design: .rounded).weight(.bold)
    static let sectionTitle = Font.system(.title3, design: .rounded).weight(.semibold)
    static let cardTitle    = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyRegular  = Font.system(.body)
    static let bodyMedium   = Font.system(.body).weight(.medium)
    static let caption      = Font.system(.caption).weight(.medium)
    static let statNumber   = Font.system(.title2, design: .rounded).weight(.bold)
}

// MARK: - Espaciado y radios

enum Layout {
    static let cardRadius:    CGFloat = 20
    static let buttonRadius:  CGFloat = 16
    static let chipRadius:    CGFloat = 12
    static let screenPadding: CGFloat = 20
    static let cardSpacing:   CGFloat = 16
}

// MARK: - Estilo de tarjeta reutilizable

struct CardBackground: ViewModifier {
    var padding: CGFloat = 16
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.07),
                radius: 12, x: 0, y: 4
            )
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isDisabled
                    ? AnyShapeStyle(Color.gray.opacity(0.35))
                    : AnyShapeStyle(LinearGradient.brandGradient)
            )
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonRadius, style: .continuous))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium.weight(.semibold))
            .foregroundStyle(Color.brandPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.brandPrimary.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: Layout.buttonRadius, style: .continuous))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
