//
//  StatCard.swift
//  ImpactMatch
//
//  Tarjeta compacta para mostrar una métrica de impacto con ícono.
//

import SwiftUI

struct StatCard: View {
    let value: Int
    let label: LocalizedStringKey
    let icon: String
    var tint: Color = .brandPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(tint.opacity(0.14)).frame(width: 38, height: 38)
                Image(systemName: icon).foregroundStyle(tint)
            }
            Text("\(value)")
                .font(.statNumber)
                .foregroundStyle(Color.textPrimary)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value) ") + Text(label))
    }
}

struct SectionHeader: View {
    let title: LocalizedStringKey
    var actionTitle: LocalizedStringKey? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.bodyMedium)
                    .foregroundStyle(Color.brandPrimary)
                    .accessibilityHint("Ver todos")
            }
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        StatCard(value: 1280, label: "Personas conectadas", icon: "person.2.fill", tint: .brandPrimary)
        StatCard(value: 312, label: "Alianzas creadas", icon: "hands.sparkles.fill", tint: .brandAccent)
    }
    .padding()
}
