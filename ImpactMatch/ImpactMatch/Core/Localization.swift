//
//  Localization.swift
//  ImpactMatch
//
//  Idiomas disponibles en la app. El usuario puede fijar uno desde
//  Configuración, o dejar que siga el idioma del sistema. Las
//  traducciones viven en Localizable.xcstrings.
//
//  `Text(_ key: LocalizedStringKey)` respeta `.environment(\.locale, ...)`
//  automáticamente, pero el código fuera de las vistas (enums,
//  validación, notificaciones) no tiene acceso a ese environment.
//  Para esos casos usamos `AppLanguage.localizedString(_:)`, que carga
//  directamente el `.lproj` correcto — más directo y confiable que
//  pasar `locale:` a `String(localized:)`.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case es
    case en
    case pt

    static let storageKey = "appLanguageCode"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: AppLanguage.localizedString("Idioma del sistema")
        case .es: "Español"
        case .en: "English"
        case .pt: "Português"
        }
    }

    var locale: Locale? {
        self == .system ? nil : Locale(identifier: rawValue)
    }

    static func resolvedLocale(for storedValue: String) -> Locale {
        (AppLanguage(rawValue: storedValue) ?? .system).locale ?? Locale.autoupdatingCurrent
    }

    /// El código de idioma elegido en Configuración ahora mismo ("es",
    /// "en", "pt"). Si está en "según el sistema", se deriva del idioma
    /// del dispositivo (recortado a solo el código de idioma, sin
    /// región) y cae en "es" si no lo reconoce.
    static var currentLanguageCode: String {
        let stored = UserDefaults.standard.string(forKey: storageKey) ?? AppLanguage.system.rawValue
        if let language = AppLanguage(rawValue: stored), language != .system {
            return language.rawValue
        }
        return Locale.autoupdatingCurrent.language.languageCode?.identifier ?? "es"
    }

    static var currentLocale: Locale {
        Locale(identifier: currentLanguageCode)
    }

    /// Traduce `key` (el texto en español, que es la llave en
    /// Localizable.xcstrings) al idioma elegido ahora mismo. Si no hay
    /// una tabla para ese idioma (por ejemplo "es", que es el idioma
    /// fuente y no tiene su propio .lproj) devuelve `key` tal cual.
    static func localizedString(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }
}
