//
//  FormValidation.swift
//  ImpactMatch
//
//  Validación de formularios en el cliente (formato de correo,
//  longitud de contraseña). No hay backend real todavía, así que
//  esto no verifica credenciales — solo que el formato sea válido.
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
