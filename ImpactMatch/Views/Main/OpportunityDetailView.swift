//
//  OpportunityDetailView.swift
//  ImpactMatch
//

import SwiftUI

struct OpportunityDetailView: View {
    let opportunity: Opportunity
    @EnvironmentObject var store: AppStore

    var match: MatchResult { MatchEngine.result(for: store.currentProfile, opportunity: opportunity) }
    var alreadyRequested: Bool { store.hasRequested(opportunity) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Compatibilidad explicada")
                    MatchBreakdownRow(label: AppLanguage.localizedString("Habilidades"), value: match.breakdown.skillsScore, weightPercent: 50)
                    MatchBreakdownRow(label: AppLanguage.localizedString("Intereses"), value: match.breakdown.interestsScore, weightPercent: 20)
                    MatchBreakdownRow(label: AppLanguage.localizedString("Disponibilidad"), value: match.breakdown.availabilityScore, weightPercent: 15)
                    MatchBreakdownRow(label: AppLanguage.localizedString("Modalidad"), value: match.breakdown.modalityScore, weightPercent: 15)
                    Divider()
                    AcceptanceProbabilityBar(percent: match.acceptanceProbability)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Descripción")
                    Text(opportunity.description)
                        .font(.bodyRegular)
                        .foregroundStyle(Color.textSecondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Habilidades requeridas")
                    HStack(spacing: 8) {
                        ForEach(opportunity.requiredSkills, id: \.self) { skill in
                            SkillChip(text: skill, highlighted: match.matchedSkills.contains(skill))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Detalles")
                    DetailRow(icon: "location.fill", title: "Modalidad", value: opportunity.modality.localizedName)
                    DetailRow(icon: "clock.fill", title: "Horario", value: opportunity.schedule)
                    DetailRow(icon: "calendar", title: "Duración", value: opportunity.duration)
                    DetailRow(icon: "checkmark.seal.fill", title: "Requisitos", value: opportunity.requirements.isEmpty ? AppLanguage.localizedString("No especificados") : opportunity.requirements)
                }
                .cardStyle()

                actionButton
            }
            .padding(Layout.screenPadding)
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { store.toggleSaved(opportunity) } label: {
                    Image(systemName: store.isSaved(opportunity) ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(store.isSaved(opportunity) ? "Quitar de guardados" : "Guardar oportunidad")
            }
        }
        .sensoryFeedback(.selection, trigger: store.isSaved(opportunity))
        .sensoryFeedback(.success, trigger: alreadyRequested)
    }

    var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                TypeTag(type: opportunity.type)
                Text(opportunity.title).font(.screenTitle)
                HStack(spacing: 6) {
                    Image(systemName: opportunity.organizationIcon).foregroundStyle(Color.brandSecondary)
                    Text(opportunity.organizationName).font(.bodyMedium).foregroundStyle(Color.textSecondary)
                }
            }
            Spacer()
            CompatibilityBadge(percent: match.percent, size: 68, lineWidth: 6)
        }
    }

    var actionButton: some View {
        Group {
            if alreadyRequested {
                let status = store.requests.first(where: { $0.opportunity.id == opportunity.id })?.status ?? .pending
                HStack {
                    Image(systemName: status == .accepted ? "checkmark.circle.fill" : (status == .declined ? "xmark.circle.fill" : "clock.fill"))
                    Text(statusText(status))
                }
                .font(.bodyMedium.weight(.semibold))
                .foregroundStyle(status == .accepted ? Color.matchHigh : (status == .declined ? Color.matchLow : Color.textSecondary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.buttonRadius, style: .continuous))
                .accessibilityElement(children: .combine)
            } else {
                Button {
                    store.sendRequest(for: opportunity)
                } label: {
                    Text("Mostrar interés / Aplicar")
                }
                .buttonStyle(PrimaryGradientButtonStyle())
                .accessibilityHint("Envía una solicitud de interés a \(opportunity.organizationName)")
            }
        }
    }

    func statusText(_ status: RequestStatus) -> String {
        switch status {
        case .pending: AppLanguage.localizedString("Solicitud enviada — esperando respuesta")
        case .accepted: AppLanguage.localizedString("¡Conexión creada! Revisa tus Conexiones")
        case .declined: AppLanguage.localizedString("La organización no continuó esta vez")
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: LocalizedStringKey
    let value: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(Color.brandPrimary).frame(width: 20)
            Text(title).font(.bodyRegular).foregroundStyle(Color.textSecondary)
            Spacer()
            Text(value).font(.bodyMedium).multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { OpportunityDetailView(opportunity: .mockList[0]) }.environmentObject(AppStore())
}
