//
//  AuthErrorMessages.swift
//  ImpactMatch
//
//  Traduce los errores de Firebase Auth a los mensajes en español
//  que ya muestran LoginView/SignUpView bajo cada campo.
//

import Foundation
import FirebaseAuth

enum AuthErrorMessages {
    static func message(for error: Error) -> String {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .emailAlreadyInUse:
            return "Ya existe una cuenta con ese correo."
        case .wrongPassword, .invalidCredential:
            return "Correo o contraseña incorrectos."
        case .userNotFound:
            return "No existe una cuenta con ese correo."
        case .weakPassword:
            return "La contraseña es muy débil."
        case .invalidEmail:
            return "El correo no es válido."
        case .networkError:
            return "Sin conexión. Intenta de nuevo."
        default:
            return "Ocurrió un error. Intenta de nuevo."
        }
    }
}
