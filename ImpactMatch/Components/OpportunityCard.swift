//
//  OpportunityCard.swift
//  ImpactMatch
//
//  Tarjeta reutilizable para mostrar una oportunidad en listas
//  (Explorar, Guardadas, Recomendadas).
//

import SwiftUI

struct SkillChip: View {
    let text: String
    var highlighted: Bool = false

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(highlighted ? Color.brandAccent.opacity(0.15) : Color.gray.opacity(0.10))
            .foregroundStyle(highlighted ? Color.brandAccent : Color.textSecondary)
            .clipShape(Capsule())
    }
}

struct TypeTag: View {
    let type: OpportunityType

    var icon: String {
        switch type {
        case .job: return "briefcase.fill"
        case .internship: return "graduationcap.fill"
        case .volunteering: return "hands.sparkles.fill"
        case .project: return "sparkles"
        }
    }

    var body: some View {
        Label(type.localizedName, systemImage: icon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.brandPrimary.opacity(0.12))
            .foregroundStyle(Color.brandPrimary)
            .clipShape(Capsule())
    }
}

struct OpportunityCard: View {
    let opportunity: Opportunity
    let matchPercent: Int
    var isSaved: Bool = false
    var onSaveTapped: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TypeTag(type: opportunity.type)
                    Spacer()
                    if let onSaveTapped {
                        Button(action: onSaveTapped) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(isSaved ? Color.brandPrimary : Color.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isSaved ? "Quitar de guardados" : "Guardar oportunidad")
                    }
                }

                Text(opportunity.title)
                    .font(.cardTitle)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: opportunity.organizationIcon)
                        .foregroundStyle(Color.brandSecondary)
                    Text(opportunity.organizationName)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                HStack(spacing: 6) {
                    ForEach(opportunity.requiredSkills.prefix(3), id: \.self) { skill in
                        SkillChip(text: skill)
                    }
                }

                HStack(spacing: 14) {
                    Label(opportunity.modality.localizedName, systemImage: "location.fill")
                    Label(opportunity.duration, systemImage: "calendar")
                }
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
            }

            Spacer(minLength: 0)

            VStack {
                CompatibilityBadge(percent: matchPercent, size: 52, lineWidth: 4.5)
                Spacer()
            }
        }
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(cardAccessibilityLabel)
        .accessibilityAction(named: isSaved ? "Quitar de guardados" : "Guardar oportunidad") {
            onSaveTapped?()
        }
    }

    private var cardAccessibilityLabel: String {
        "\(opportunity.title), \(opportunity.organizationName). " +
        "\(opportunity.type.localizedName). " +
        "Modalidad: \(opportunity.modality.localizedName). " +
        "Compatibilidad: \(matchPercent) por ciento, nivel \(Color.matchTierLabel(for: matchPercent))."
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            OpportunityCard(opportunity: .mockList[0], matchPercent: 94, isSaved: true, onSaveTapped: {})
            OpportunityCard(opportunity: .mockList[1], matchPercent: 81, onSaveTapped: {})
        }
        .padding()
    }
}
