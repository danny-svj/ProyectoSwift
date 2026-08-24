//
//  Models.swift
//  ImpactMatch
//
//  Modelos de datos principales. Codable para poder persistir
//  después con Firebase u otro backend sin reescribir la lógica.
//

import Foundation

// MARK: - Tipo de usuario

enum UserType: String, Codable, CaseIterable {
    case person = "Persona"
    case organization = "Empresa / Organización"
}

enum Modality: String, Codable, CaseIterable, Identifiable {
    case remote = "Remoto"
    case onsite = "Presencial"
    case hybrid = "Híbrido"
    var id: String { rawValue }
}

enum OpportunityType: String, Codable, CaseIterable, Identifiable {
    case job = "Empleo"
    case internship = "Práctica profesional"
    case volunteering = "Voluntariado"
    case project = "Proyecto / Colaboración"
    var id: String { rawValue }
}

// MARK: - Perfil de usuario (persona)

struct UserProfile: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var userType: UserType
    var headline: String            // ej. "Estudiante de Ing. en Software"
    var bio: String
    var skills: [String]
    var interests: [String]
    var availabilityHoursPerWeek: Int
    var preferredModality: Modality
    var location: String
    var seekingOpportunityTypes: [OpportunityType]
    var avatarSystemImage: String = "person.crop.circle.fill"

    // Estadísticas de impacto propias del usuario
    var connectionsCount: Int = 0
    var matchesCount: Int = 0
    var completedProjectsCount: Int = 0
}

// MARK: - Oportunidad publicada por una empresa/organización

struct Opportunity: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var organizationName: String
    var organizationIcon: String = "building.2.crop.circle.fill"
    var type: OpportunityType
    var description: String
    var requiredSkills: [String]
    var relatedInterests: [String]
    var modality: Modality
    var schedule: String            // ej. "Medio tiempo, 15h/semana"
    var duration: String            // ej. "3 meses"
    var requirements: String = ""
    var postedDate: Date = Date()
}

// MARK: - Desglose de compatibilidad explicable

struct MatchBreakdown {
    var skillsScore: Double         // 0...1
    var interestsScore: Double
    var availabilityScore: Double
    var modalityScore: Double

    // Pesos definidos en el planteamiento del proyecto
    static let skillsWeight = 0.50
    static let interestsWeight = 0.20
    static let availabilityWeight = 0.15
    static let modalityWeight = 0.15

    var totalPercent: Int {
        let total = skillsScore * Self.skillsWeight
            + interestsScore * Self.interestsWeight
            + availabilityScore * Self.availabilityWeight
            + modalityScore * Self.modalityWeight
        return Int((total * 100).rounded())
    }
}

struct MatchResult: Identifiable {
    var id: UUID = UUID()
    var opportunity: Opportunity
    var breakdown: MatchBreakdown
    var matchedSkills: [String]
    var percent: Int { breakdown.totalPercent }
}

// MARK: - Solicitud / interés enviado

enum RequestStatus: String, Codable {
    case pending = "Pendiente"
    case accepted = "Aceptada"
    case declined = "Rechazada"
}

struct OpportunityRequest: Identifiable, Codable {
    var id: UUID = UUID()
    var opportunity: Opportunity
    var status: RequestStatus = .pending
    var sentDate: Date = Date()
    var matchPercent: Int
}

// MARK: - Conexión creada cuando ambas partes aceptan

struct Connection: Identifiable, Codable {
    var id: UUID = UUID()
    var opportunity: Opportunity
    var matchPercent: Int
    var createdDate: Date = Date()
    var isProjectCompleted: Bool = false
}

// MARK: - Estadísticas de impacto globales (mock, representa a toda la plataforma)

struct ImpactStats {
    var connectedPeople: Int
    var matchesMade: Int
    var opportunitiesPosted: Int
    var alliancesCreated: Int
    var completedProjects: Int
}
