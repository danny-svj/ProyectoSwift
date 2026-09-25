//
//  Models.swift
//  ImpactMatch
//
//  Modelos de datos principales. Codable para poder persistir
//  después con Firebase u otro backend sin reescribir la lógica.
//

import Foundation
import CoreLocation

// MARK: - Tipo de usuario

enum UserType: String, Codable, CaseIterable {
    case person = "Persona"
    case organization = "Empresa / Organización"

    /// Texto localizado para mostrar en pantalla. `rawValue` se queda fijo
    /// (es lo que se guarda en disco), esto es solo lo que se traduce.
    var localizedName: String {
        switch self {
        case .person: AppLanguage.localizedString("Persona")
        case .organization: AppLanguage.localizedString("Empresa / Organización")
        }
    }
}

enum Modality: String, Codable, CaseIterable, Identifiable {
    case remote = "Remoto"
    case onsite = "Presencial"
    case hybrid = "Híbrido"
    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .remote: AppLanguage.localizedString("Remoto")
        case .onsite: AppLanguage.localizedString("Presencial")
        case .hybrid: AppLanguage.localizedString("Híbrido")
        }
    }
}

enum OpportunityType: String, Codable, CaseIterable, Identifiable {
    case job = "Empleo"
    case internship = "Práctica profesional"
    case volunteering = "Voluntariado"
    case project = "Proyecto / Colaboración"
    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .job: AppLanguage.localizedString("Empleo")
        case .internship: AppLanguage.localizedString("Práctica profesional")
        case .volunteering: AppLanguage.localizedString("Voluntariado")
        case .project: AppLanguage.localizedString("Proyecto / Colaboración")
        }
    }
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
    var avatarSystemImage: String = "person.fill"
    var avatarGradientName: String = "brand"
    /// Carrera / área de estudio — opcional, se usa para el filtro
    /// "personas de tu misma carrera" en el mapa. `nil` en perfiles
    /// guardados antes de que existiera este campo.
    var fieldOfStudy: String? = nil
    var mastersDegree: String? = nil

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

    /// Probabilidad de que la organización acepte tu solicitud — explicable,
    /// no inventada: es el mismo porcentaje de compatibilidad que decide la
    /// respuesta simulada en `AppStore.sendRequest` (umbral 65%), mostrado
    /// como probabilidad en vez de un corte binario.
    var acceptanceProbability: Int { percent }
}

// MARK: - Solicitud / interés enviado

enum RequestStatus: String, Codable {
    case pending = "Pendiente"
    case accepted = "Aceptada"
    case declined = "Rechazada"

    var localizedName: String {
        switch self {
        case .pending: AppLanguage.localizedString("Pendiente")
        case .accepted: AppLanguage.localizedString("Aceptada")
        case .declined: AppLanguage.localizedString("Rechazada")
        }
    }
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

// MARK: - Personas y organizaciones "cerca de mí" (mapa)

enum NearbyKind {
    case person
    case organization
}

struct NearbyEntity: Identifiable {
    var id = UUID()
    var name: String
    var kind: NearbyKind
    var subtitle: String
    var icon: String
    var tags: [String]
    var coordinate: CLLocationCoordinate2D
    var opportunity: Opportunity?
    /// Carrera / área de estudio — solo aplica a personas, se usa
    /// para el filtro "misma carrera que tú".
    var fieldOfStudy: String? = nil
}

// MARK: - Catálogo de carreras con habilidades e intereses sugeridos

struct CareerInfo: Identifiable {
    var id: String { name }
    let name: String
    let suggestedSkills: [String]
    let suggestedInterests: [String]
}

enum CareerCatalog {
    static let careers: [CareerInfo] = [
        .init(name: "Ingeniería en Software",
              suggestedSkills: ["Programación", "Swift", "SwiftUI", "Datos / Analítica", "AWS", "Gestión de proyectos"],
              suggestedInterests: ["Tecnología social", "Diseño de producto", "Inclusión"]),
        .init(name: "Nutrición",
              suggestedSkills: ["Docencia", "Investigación", "Trabajo en equipo", "Redacción"],
              suggestedInterests: ["Salud", "Medio ambiente", "Igualdad"]),
        .init(name: "Diseño Gráfico",
              suggestedSkills: ["Diseño", "UX/UI", "Fotografía", "Video", "Marketing"],
              suggestedInterests: ["Diseño de producto", "Cultura", "Tecnología social"]),
        .init(name: "Administración de Empresas",
              suggestedSkills: ["Liderazgo", "Gestión de proyectos", "Finanzas", "Ventas", "Marketing"],
              suggestedInterests: ["Sostenibilidad", "Tecnología social", "Igualdad"]),
        .init(name: "Medicina",
              suggestedSkills: ["Investigación", "Docencia", "Trabajo en equipo"],
              suggestedInterests: ["Salud", "Igualdad", "Inclusión"]),
        .init(name: "Psicología",
              suggestedSkills: ["Docencia", "Redacción", "Trabajo en equipo", "Investigación"],
              suggestedInterests: ["Salud", "Inclusión", "Educación"]),
        .init(name: "Marketing y Comunicación",
              suggestedSkills: ["Marketing", "Redacción", "Fotografía", "Video", "Idiomas"],
              suggestedInterests: ["Tecnología social", "Cultura", "Sostenibilidad"]),
        .init(name: "Arquitectura",
              suggestedSkills: ["Diseño", "Gestión de proyectos", "Liderazgo"],
              suggestedInterests: ["Sostenibilidad", "Cultura", "Medio ambiente"]),
        .init(name: "Derecho",
              suggestedSkills: ["Redacción", "Liderazgo", "Idiomas", "Investigación"],
              suggestedInterests: ["Igualdad", "Inclusión", "Medio ambiente"]),
        .init(name: "Contaduría y Finanzas",
              suggestedSkills: ["Finanzas", "Datos / Analítica", "Gestión de proyectos", "Liderazgo"],
              suggestedInterests: ["Sostenibilidad", "Tecnología social"]),
        .init(name: "Pedagogía / Educación",
              suggestedSkills: ["Docencia", "Redacción", "Liderazgo", "Trabajo en equipo"],
              suggestedInterests: ["Educación", "Inclusión", "Igualdad"]),
        .init(name: "Ciencias de la Comunicación",
              suggestedSkills: ["Redacción", "Fotografía", "Video", "Marketing", "Idiomas"],
              suggestedInterests: ["Cultura", "Tecnología social", "Inclusión"]),
        .init(name: "Ingeniería Industrial",
              suggestedSkills: ["Gestión de proyectos", "Datos / Analítica", "Liderazgo", "Programación"],
              suggestedInterests: ["Tecnología social", "Sostenibilidad", "Medio ambiente"]),
        .init(name: "Relaciones Internacionales",
              suggestedSkills: ["Idiomas", "Redacción", "Investigación", "Liderazgo"],
              suggestedInterests: ["Igualdad", "Inclusión", "Sostenibilidad"]),
        .init(name: "Biología",
              suggestedSkills: ["Investigación", "Docencia", "Datos / Analítica"],
              suggestedInterests: ["Medio ambiente", "Salud", "Sostenibilidad"]),
        .init(name: "Química",
              suggestedSkills: ["Investigación", "Datos / Analítica", "Docencia"],
              suggestedInterests: ["Salud", "Medio ambiente", "Sostenibilidad"]),
        .init(name: "Enfermería",
              suggestedSkills: ["Trabajo en equipo", "Docencia", "Investigación"],
              suggestedInterests: ["Salud", "Inclusión", "Igualdad"]),
        .init(name: "Economía",
              suggestedSkills: ["Datos / Analítica", "Investigación", "Redacción", "Finanzas"],
              suggestedInterests: ["Sostenibilidad", "Tecnología social", "Igualdad"]),
    ]

    static let mastersDegrees: [String] = [
        "Maestría en Ingeniería de Software",
        "Maestría en Ciencia de Datos e Inteligencia Artificial",
        "Maestría en Administración de Empresas (MBA)",
        "Maestría en Diseño UX/UI",
        "Maestría en Salud Pública",
        "Maestría en Nutrición Clínica",
        "Maestría en Psicología Clínica",
        "Maestría en Derecho Corporativo",
        "Maestría en Educación y Pedagogía",
        "Maestría en Marketing Digital",
        "Maestría en Comunicación Organizacional",
        "Maestría en Arquitectura Sostenible",
        "Maestría en Finanzas y Contaduría",
        "Maestría en Gestión de Proyectos",
        "Maestría en Ciberseguridad",
        "Maestría en Economía",
        "Maestría en Relaciones Internacionales",
        "Maestría en Trabajo Social",
        "Maestría en Periodismo",
        "Maestría en Biología Molecular",
        "Maestría en Ingeniería Industrial",
        "Maestría en Administración Pública",
        "Maestría en Recursos Humanos",
        "Maestría en Innovación y Emprendimiento",
    ]

    static func info(for careerName: String) -> CareerInfo? {
        let trimmed = careerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return careers.first {
            $0.name.localizedCaseInsensitiveContains(trimmed) ||
            trimmed.localizedCaseInsensitiveContains($0.name)
        }
    }
}

// MARK: - Catálogo de sugerencias para armar el perfil

enum SkillCatalog {
    static let commonSkills = [
        "Swift", "SwiftUI", "Programación", "Diseño", "UX/UI",
        "Trabajo en equipo", "Liderazgo", "Gestión de proyectos",
        "Marketing", "Redacción", "Fotografía", "Video",
        "Datos / Analítica", "AWS", "Idiomas", "Docencia", "Ventas", "Finanzas",
    ]

    static let commonInterests = [
        "Tecnología social", "Educación", "Sostenibilidad", "Diseño de producto",
        "Salud", "Igualdad", "Medio ambiente", "Cultura", "Deporte", "Inclusión",
    ]
}
