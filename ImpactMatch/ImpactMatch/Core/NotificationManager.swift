//
//  NotificationManager.swift
//  ImpactMatch
//
//  Notificaciones locales cuando una solicitud es aceptada o
//  rechazada. Todo pasa en el dispositivo — no hay push real
//  todavía porque no hay backend.
//

import Foundation
import UserNotifications

enum NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func notifyRequestResult(opportunityTitle: String, accepted: Bool) {
        let content = UNMutableNotificationContent()
        content.title = accepted ? "¡Nueva conexión! 🎉" : "Actualización de tu solicitud"
        content.body = accepted
            ? "\"\(opportunityTitle)\" aceptó tu solicitud. Revisa tus Conexiones."
            : "\"\(opportunityTitle)\" no continuó esta vez."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

/// Permite que las notificaciones se muestren aunque la app esté en
/// primer plano (por defecto iOS las oculta si no hay delegate).
private final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
