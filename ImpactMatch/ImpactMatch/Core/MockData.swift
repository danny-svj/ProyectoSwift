//
//  MockData.swift
//  ImpactMatch
//
//  Datos de ejemplo para previews de SwiftUI y para que la demo
//  escolar se vea poblada sin necesidad de un backend real.
//

import Foundation

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
        seekingOpportunityTypes: [.internship, .project, .volunteering]
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
