//
//  MockData.swift
//  ImpactMatch
//
//  Datos de ejemplo para previews de SwiftUI y para que la demo
//  escolar se vea poblada sin necesidad de un backend real.
//

import Foundation
import CoreLocation

extension UserProfile {
    static let mockDaniel = UserProfile(
        name: "Daniel González",
        userType: .person,
        headline: "Estudiante de Ing. en Desarrollo de Software",
        bio: "Me apasiona construir apps con impacto real. Busco proyectos donde pueda aportar con Swift y diseño de producto.",
        skills: ["Swift", "SwiftUI", "Diseño", "Programación", "Trabajo en equipo", "AWS"],
        interests: ["Tecnología social", "Educación", "Sostenibilidad", "Diseño de producto"],
        availabilityHoursPerWeek: 12,
        preferredModality: .hybrid,
        location: "Ciudad de México, MX",
        seekingOpportunityTypes: [.internship, .project, .volunteering],
        fieldOfStudy: "Ingeniería en Software"
    )
}

extension Opportunity {
    static let mockList: [Opportunity] = [
        Opportunity(
            title: "Desarrollador Swift Jr.",
            organizationName: "GreenTech Labs",
            organizationIcon: "leaf.circle.fill",
            type: .internship,
            description: "Buscamos a alguien que nos ayude a construir la app móvil de nuestra plataforma de reciclaje comunitario.",
            requiredSkills: ["Swift", "SwiftUI", "Trabajo en equipo"],
            relatedInterests: ["Sostenibilidad", "Tecnología social"],
            modality: .hybrid,
            schedule: "Medio tiempo, 15h/semana",
            duration: "3 meses"
        ),
        Opportunity(
            title: "Diseñador/a UI para app social",
            organizationName: "Fundación Impulsa",
            organizationIcon: "paintpalette.fill",
            type: .volunteering,
            description: "Necesitamos apoyo de diseño para renovar la interfaz de nuestra app de conexión con voluntarios.",
            requiredSkills: ["Diseño", "SwiftUI"],
            relatedInterests: ["Diseño de producto", "Educación"],
            modality: .remote,
            schedule: "Flexible, 5h/semana",
            duration: "6 semanas"
        ),
        Opportunity(
            title: "Proyecto app de alianzas sociales",
            organizationName: "ONG Conecta",
            organizationIcon: "hands.sparkles.fill",
            type: .project,
            description: "Colaboración abierta para desarrollar funciones nuevas de una app que conecta voluntarios con causas sociales.",
            requiredSkills: ["Programación", "Swift", "Trabajo en equipo"],
            relatedInterests: ["Tecnología social", "Sostenibilidad"],
            modality: .remote,
            schedule: "Flexible",
            duration: "Proyecto abierto"
        ),
        Opportunity(
            title: "Práctica profesional — Desarrollo móvil",
            organizationName: "Nimbus Solutions",
            organizationIcon: "building.2.crop.circle.fill",
            type: .internship,
            description: "Práctica profesional en el equipo de apps móviles, trabajando en producto real con usuarios activos.",
            requiredSkills: ["Swift", "AWS", "Programación"],
            relatedInterests: ["Diseño de producto"],
            modality: .onsite,
            schedule: "Tiempo completo",
            duration: "4 meses"
        ),
        Opportunity(
            title: "Voluntariado — Talleres de programación",
            organizationName: "Código Comunidad",
            organizationIcon: "person.3.fill",
            type: .volunteering,
            description: "Facilitar talleres básicos de programación para jóvenes en comunidades con poco acceso a tecnología.",
            requiredSkills: ["Programación", "Trabajo en equipo"],
            relatedInterests: ["Educación", "Tecnología social"],
            modality: .onsite,
            schedule: "Sábados, 4h",
            duration: "2 meses"
        ),
    ]
}

// MARK: - Personas cerca de ti (mock, para el mapa "Cerca de mí")

extension NearbyEntity {
    private static let mockPeople: [(name: String, subtitle: String, tags: [String], icon: String, fieldOfStudy: String)] = [
        ("Camila Torres", "Diseñadora UX", ["Diseño", "UX/UI"], "paintbrush.fill", "Diseño Gráfico"),
        ("Luis Hernández", "Desarrollador backend", ["Programación", "AWS"], "chevron.left.forwardslash.chevron.right", "Ingeniería en Software"),
        ("Ana Ramírez", "Voluntaria social", ["Educación", "Trabajo en equipo"], "person.fill", "Trabajo Social"),
        ("Jorge Paredes", "Estudiante de diseño", ["Diseño", "Branding"], "paintpalette.fill", "Diseño Gráfico"),
        ("Sofía Delgado", "Product manager jr.", ["Gestión de proyectos", "Liderazgo"], "chart.bar.fill", "Administración de Empresas"),
        ("Renata Solís", "Fotógrafa y video", ["Fotografía", "Video"], "camera.fill", "Comunicación"),
    ]

    /// Genera personas y organizaciones dispersas alrededor de un centro
    /// (ubicación real del usuario si está disponible, o una por defecto).
    /// No hay backend de geolocalización real todavía — son coordenadas
    /// simuladas para la demo escolar.
    static func mockNearby(around center: CLLocationCoordinate2D) -> [NearbyEntity] {
        let organizations = Opportunity.mockList
        let total = mockPeople.count + organizations.count

        var result: [NearbyEntity] = mockPeople.enumerated().map { index, person in
            NearbyEntity(
                name: person.name,
                kind: .person,
                subtitle: person.subtitle,
                icon: person.icon,
                tags: person.tags,
                coordinate: offsetCoordinate(from: center, index: index, total: total),
                fieldOfStudy: person.fieldOfStudy
            )
        }

        result += organizations.enumerated().map { offset, opportunity in
            let index = offset + mockPeople.count
            return NearbyEntity(
                name: opportunity.organizationName,
                kind: .organization,
                subtitle: opportunity.title,
                icon: opportunity.organizationIcon,
                tags: opportunity.requiredSkills,
                coordinate: offsetCoordinate(from: center, index: index, total: total),
                opportunity: opportunity
            )
        }

        return result
    }

    private static func offsetCoordinate(from center: CLLocationCoordinate2D, index: Int, total: Int) -> CLLocationCoordinate2D {
        let angle = (2 * Double.pi / Double(max(total, 1))) * Double(index)
        let radiusKm = 0.6 + Double(index % 4) * 0.45
        let earthRadiusKm = 6371.0
        let latOffset = (radiusKm / earthRadiusKm) * (180 / .pi) * cos(angle)
        let lonOffset = (radiusKm / earthRadiusKm) * (180 / .pi) * sin(angle) / cos(center.latitude * .pi / 180)
        return CLLocationCoordinate2D(latitude: center.latitude + latOffset, longitude: center.longitude + lonOffset)
    }
}
