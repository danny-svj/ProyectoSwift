//
//  FormValidation.swift
//  ImpactMatch
//
//  Validación de formato en el cliente (correo bien formado,
//  contraseña con longitud mínima) antes de llamar a Firebase Auth,
//  que es quien verifica las credenciales de verdad.
//

import Foundation

enum FormValidation {
    static let minPasswordLength = 6

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= minPasswordLength
    }
}
