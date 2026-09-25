//
//  AppStore.swift
//  ImpactMatch
//
//  Fuente única de verdad de la app (patrón MVVM simple con
//  ObservableObject). Contiene los datos mock, el motor de
//  matching explicable y las acciones que modifican el estado
//  (guardar, solicitar, conectar). Pensado para poder cambiar
//  el backend por Firebase más adelante sin tocar las vistas.
//

import Foundation
import SwiftUI

// MARK: - Motor de matching

enum MatchEngine {

    /// Calcula la compatibilidad entre un perfil y una oportunidad,
    /// devolviendo un desglose explicable (no un número inventado).
    static func breakdown(for profile: UserProfile, opportunity: Opportunity) -> MatchBreakdown {
        let userSkills = Set(profile.skills.map { $0.lowercased() })
        let requiredSkills = Set(opportunity.requiredSkills.map { $0.lowercased() })
        let skillsScore: Double = requiredSkills.isEmpty ? 1.0 :
            Double(userSkills.intersection(requiredSkills).count) / Double(requiredSkills.count)

        let userInterests = Set(profile.interests.map { $0.lowercased() })
        let oppInterests = Set(opportunity.relatedInterests.map { $0.lowercased() })
        let interestsScore: Double = oppInterests.isEmpty ? 0.7 :
            Double(userInterests.intersection(oppInterests).count) / Double(oppInterests.count)

        // Disponibilidad: compara horas/semana del usuario contra una carga estimada del schedule.
        let availabilityScore: Double = profile.availabilityHoursPerWeek >= 10 ? 1.0 :
            (profile.availabilityHoursPerWeek >= 5 ? 0.7 : 0.4)

        let modalityScore: Double = (profile.preferredModality == opportunity.modality || opportunity.modality == .hybrid) ? 1.0 : 0.35

        return MatchBreakdown(
            skillsScore: min(skillsScore, 1.0),
            interestsScore: min(interestsScore, 1.0),
            availabilityScore: availabilityScore,
            modalityScore: modalityScore
        )
    }

    static func matchedSkills(for profile: UserProfile, opportunity: Opportunity) -> [String] {
        let userSkills = Set(profile.skills.map { $0.lowercased() })
        return opportunity.requiredSkills.filter { userSkills.contains($0.lowercased()) }
    }

    static func result(for profile: UserProfile, opportunity: Opportunity) -> MatchResult {
        MatchResult(
            opportunity: opportunity,
            breakdown: breakdown(for: profile, opportunity: opportunity),
            matchedSkills: matchedSkills(for: profile, opportunity: opportunity)
        )
    }
}

// MARK: - Store central

@MainActor
final class AppStore: ObservableObject {

    // Sesión
    @Published var isLoggedIn: Bool = false { didSet { persist() } }
    @Published var currentProfile: UserProfile = .mockDaniel { didSet { persist() } }

    // Datos
    @Published var opportunities: [Opportunity] = Opportunity.mockList { didSet { persist() } }
    @Published var savedOpportunityIDs: Set<UUID> = [] { didSet { persist() } }
    @Published var requests: [OpportunityRequest] = [] { didSet { persist() } }
    @Published var connections: [Connection] = [] { didSet { persist() } }

    private var isRestoring = false

    init() {
        guard let snapshot = PersistenceStore.load() else { return }
        isRestoring = true
        isLoggedIn = snapshot.isLoggedIn
        var profile = snapshot.currentProfile
        // Migración: "person.crop.circle.fill" tiene su propio círculo y se ve mal
        // dentro del avatar circular con gradiente — reemplazarlo por "person.fill".
        if profile.avatarSystemImage == "person.crop.circle.fill" {
            profile.avatarSystemImage = "person.fill"
        }
        currentProfile = profile
        opportunities = snapshot.opportunities
        savedOpportunityIDs = snapshot.savedOpportunityIDs
        requests = snapshot.requests
        connections = snapshot.connections
        isRestoring = false
    }

    private func persist() {
        guard !isRestoring else { return }
        let snapshot = AppSnapshot(
            isLoggedIn: isLoggedIn,
            currentProfile: currentProfile,
            opportunities: opportunities,
            savedOpportunityIDs: savedOpportunityIDs,
            requests: requests,
            connections: connections
        )
        PersistenceStore.save(snapshot)
    }

    // MARK: Derivados

    var recommendedMatches: [MatchResult] {
        opportunities
            .map { MatchEngine.result(for: currentProfile, opportunity: $0) }
            .sorted { $0.percent > $1.percent }
    }

    var savedOpportunities: [Opportunity] {
        opportunities.filter { savedOpportunityIDs.contains($0.id) }
    }

    var impactStats: ImpactStats {
        ImpactStats(
            connectedPeople: 1280 + connections.count,
            matchesMade: 3460 + recommendedMatches.filter { $0.percent >= 70 }.count,
            opportunitiesPosted: opportunities.count + 214,
            alliancesCreated: 312 + connections.count,
            completedProjects: 96 + connections.filter { $0.isProjectCompleted }.count
        )
    }

    // MARK: Acciones

    func toggleSaved(_ opportunity: Opportunity) {
        if savedOpportunityIDs.contains(opportunity.id) {
            savedOpportunityIDs.remove(opportunity.id)
        } else {
            savedOpportunityIDs.insert(opportunity.id)
        }
    }

    func isSaved(_ opportunity: Opportunity) -> Bool {
        savedOpportunityIDs.contains(opportunity.id)
    }

    func sendRequest(for opportunity: Opportunity) {
        guard !requests.contains(where: { $0.opportunity.id == opportunity.id }) else { return }
        let match = MatchEngine.result(for: currentProfile, opportunity: opportunity)
        let request = OpportunityRequest(opportunity: opportunity, matchPercent: match.percent)
        requests.append(request)

        // Simula respuesta automática de la organización para fines de demo escolar:
        // compatibilidades altas tienden a aceptarse.
        let willAccept = match.percent >= 65
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            if let index = self.requests.firstIndex(where: { $0.id == request.id }) {
                self.requests[index].status = willAccept ? .accepted : .declined
                if willAccept {
                    self.connections.append(Connection(opportunity: opportunity, matchPercent: match.percent))
                    self.currentProfile.connectionsCount += 1
                }
                NotificationManager.notifyRequestResult(opportunityTitle: opportunity.title, accepted: willAccept)
            }
        }
    }

    func hasRequested(_ opportunity: Opportunity) -> Bool {
        requests.contains { $0.opportunity.id == opportunity.id }
    }

    func addOpportunity(_ opportunity: Opportunity) {
        opportunities.insert(opportunity, at: 0)
    }

    /// Borra todo y vuelve a los datos de ejemplo — para poder
    /// reiniciar la demo antes de una presentación.
    func resetToDemoDefaults() {
        isLoggedIn = false
        currentProfile = .mockDaniel
        opportunities = Opportunity.mockList
        savedOpportunityIDs = []
        requests = []
        connections = []
    }
}
