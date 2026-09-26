//
//  FirestoreStore.swift
//  ImpactMatch
//
//  Persiste el estado de la app en Firestore (colección "users",
//  un documento por uid anónimo) en vez de un archivo JSON local.
//  Firestore no soporta Set nativamente, así que savedOpportunityIDs
//  viaja como [String] (uuidString) y se reconvierte a Set en AppStore.
//  Límite de 1 MiB por documento de Firestore: de sobra para el volumen
//  de datos de este proyecto escolar.
//

import Foundation
import FirebaseFirestore

struct FirestoreSnapshot: Codable {
    var currentProfile: UserProfile
    var opportunities: [Opportunity]
    var savedOpportunityIDStrings: [String]
    var requests: [OpportunityRequest]
    var connections: [Connection]
}

enum FirestoreStore {
    private static func documentRef(uid: String) -> DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }

    static func load(uid: String) async throws -> FirestoreSnapshot? {
        let doc = try await documentRef(uid: uid).getDocument()
        guard doc.exists else { return nil }
        return try doc.data(as: FirestoreSnapshot.self)
    }

    static func save(_ snapshot: FirestoreSnapshot, uid: String) throws {
        try documentRef(uid: uid).setData(from: snapshot, merge: false)
    }
}
