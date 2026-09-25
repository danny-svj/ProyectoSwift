//
//  PersistenceStore.swift
//  ImpactMatch
//
//  Guarda el estado de la app (perfil, oportunidades, solicitudes,
//  conexiones) en un archivo JSON local para que sobreviva a cerrar
//  la app. Los modelos ya son Codable justo para esto — cuando se
//  conecte un backend real (Firebase), este archivo se reemplaza sin
//  tocar las vistas.
//

import Foundation

struct AppSnapshot: Codable {
    var isLoggedIn: Bool
    var currentProfile: UserProfile
    var opportunities: [Opportunity]
    var savedOpportunityIDs: Set<UUID>
    var requests: [OpportunityRequest]
    var connections: [Connection]
}

enum PersistenceStore {
    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("impactmatch_state.json")
    }

    static func load() -> AppSnapshot? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(AppSnapshot.self, from: data)
    }

    static func save(_ snapshot: AppSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
