//
//  ConnectionsView.swift
//  ImpactMatch
//

import SwiftUI

struct ConnectionsView: View {
    @EnvironmentObject var store: AppStore
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("", selection: $segment) {
                    Text("Solicitudes").tag(0)
                    Text("Conexiones").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 14) {
                        if segment == 0 {
                            if store.requests.isEmpty {
                                EmptyStateView(icon: "paperplane", title: "Sin solicitudes", message: "Cuando apliques a una oportunidad, aparecerá aquí.")
                                    .padding(.top, 60)
                            } else {
                                ForEach(store.requests.reversed()) { request in
                                    RequestRow(request: request)
                                }
                            }
                        } else {
                            if store.connections.isEmpty {
                                EmptyStateView(icon: "hands.sparkles", title: "Sin conexiones aún", message: "Tus alianzas confirmadas aparecerán aquí.")
                                    .padding(.top, 60)
                            } else {
                                ForEach(store.connections.reversed()) { connection in
                                    ConnectionRow(connection: connection)
                                }
                            }
                        }
                    }
                    .padding(Layout.screenPadding)
                }
            }
            .background(Color.surfaceSecondary.opacity(0.4))
            .navigationTitle("Conexiones")
        }
    }
}

struct RequestRow: View {
    let request: OpportunityRequest
    var statusColor: Color {
        switch request.status {
        case .pending: return .matchMid
        case .accepted: return .matchHigh
        case .declined: return .matchLow
        }
    }
    var body: some View {
        HStack(spacing: 14) {
            CompatibilityBadge(percent: request.matchPercent, size: 46, lineWidth: 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(request.opportunity.title).font(.cardTitle)
                Text(request.opportunity.organizationName).font(.caption).foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Text(request.status.rawValue)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(statusColor.opacity(0.15))
                .foregroundStyle(statusColor)
                .clipShape(Capsule())
        }
        .cardStyle()
    }
}

struct ConnectionRow: View {
    let connection: Connection
    var body: some View {
        HStack(spacing: 14) {
            CompatibilityBadge(percent: connection.matchPercent, size: 46, lineWidth: 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(connection.opportunity.title).font(.cardTitle)
                Text(connection.opportunity.organizationName).font(.caption).foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill").foregroundStyle(Color.matchHigh)
        }
        .cardStyle()
    }
}

#Preview {
    ConnectionsView().environmentObject(AppStore())
}
