//
//  CompatibilityBadge.swift
//  ImpactMatch
//
//  Insignia circular de porcentaje de compatibilidad. Se usa en
//  cards de oportunidades, detalle y resultados de matching.
//

import SwiftUI

struct CompatibilityBadge: View {
    let percent: Int
    var size: CGFloat = 56
    var lineWidth: CGFloat = 5
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(percent) / 100)
                .stroke(
                    AngularGradient(
                        colors: [Color.forMatchScore(percent).opacity(0.6), Color.forMatchScore(percent)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.6), value: percent)

            VStack(spacing: 0) {
                Text("\(percent)")
                    .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                Text("%")
                    .font(.system(size: size * 0.18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(percent) por ciento de compatibilidad, \(Color.matchTierLabel(for: percent))"))
    }
}

struct MatchBreakdownRow: View {
    let label: String
    let value: Double
    let weightPercent: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.bodyMedium)
                Spacer()
                Text("Peso \(weightPercent)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(value * 100))%")
                    .font(.bodyMedium.weight(.semibold))
                    .foregroundStyle(Color.forMatchScore(Int(value * 100)))
                    .frame(width: 44, alignment: .trailing)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.15))
                    Capsule()
                        .fill(LinearGradient.matchGradient(for: Int(value * 100)))
                        .frame(width: geo.size.width * value)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(label), peso \(weightPercent) por ciento"))
        .accessibilityValue(Text("\(Int(value * 100)) por ciento"))
    }
}

/// Barra de probabilidad de ser aceptado — reutiliza el mismo % de
/// compatibilidad que decide la respuesta simulada, así el número
/// nunca se inventa aparte del motor de matching.
struct AcceptanceProbabilityBar: View {
    let percent: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Probabilidad de ser aceptado", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("\(percent)%")
                    .font(.bodyMedium.weight(.bold))
                    .foregroundStyle(Color.forMatchScore(percent))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.15))
                    Capsule()
                        .fill(LinearGradient.matchGradient(for: percent))
                        .frame(width: geo.size.width * (Double(percent) / 100))
                }
            }
            .frame(height: 10)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Probabilidad de ser aceptado: \(percent) por ciento, \(Color.matchTierLabel(for: percent))"))
    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 20) {
            CompatibilityBadge(percent: 94)
            CompatibilityBadge(percent: 72)
            CompatibilityBadge(percent: 41)
        }
        MatchBreakdownRow(label: "Habilidades", value: 0.9, weightPercent: 50)
        MatchBreakdownRow(label: "Intereses", value: 0.6, weightPercent: 20)
    }
    .padding()
}
