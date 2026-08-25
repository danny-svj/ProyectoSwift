//
//  NearMeView.swift
//  ImpactMatch
//
//  Mapa con personas y organizaciones cerca de ti. Se abre desde el
//  botón de mapa en Explorar. Usa tu ubicación real si la compartes;
//  si no, centra en una ubicación por defecto para que la demo
//  funcione igual.
//

import SwiftUI
import MapKit

struct NearMeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: LocationManager.fallbackCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
    )
    @State private var didCenterOnUser = false
    @State private var filterKind: NearbyKind?
    @State private var selectedEntity: NearbyEntity?

    private var centerCoordinate: CLLocationCoordinate2D {
        locationManager.userLocation ?? LocationManager.fallbackCoordinate
    }

    private var entities: [NearbyEntity] {
        let all = NearbyEntity.mockNearby(around: centerCoordinate)
        guard let filterKind else { return all }
        return all.filter { $0.kind == filterKind }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapView

                filterBar
                    .padding(.top, 8)
            }
            .navigationTitle("Cerca de mí")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .onAppear { locationManager.requestPermission() }
            .onChange(of: locationManager.userLocation != nil) { _, hasLocation in
                guard hasLocation, !didCenterOnUser, let newValue = locationManager.userLocation else { return }
                didCenterOnUser = true
                withAnimation {
                    cameraPosition = .region(MKCoordinateRegion(center: newValue, span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)))
                }
            }
            .sheet(item: $selectedEntity) { entity in
                NavigationStack {
                    NearbyEntityDetailView(entity: entity)
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var mapView: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            ForEach(entities) { entity in
                Annotation(entity.name, coordinate: entity.coordinate) {
                    NearbyPin(entity: entity, isSelected: selectedEntity?.id == entity.id)
                        .onTapGesture { selectedEntity = entity }
                }
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea(edges: .bottom)
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            FilterChip(title: "Todos", isSelected: filterKind == nil) { filterKind = nil }
            FilterChip(title: "Personas", isSelected: filterKind == .person) { filterKind = .person }
            FilterChip(title: "Organizaciones", isSelected: filterKind == .organization) { filterKind = .organization }
            Spacer()
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

struct NearbyPin: View {
    let entity: NearbyEntity
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(entity.kind == .person ? AnyShapeStyle(LinearGradient.brandGradient) : AnyShapeStyle(LinearGradient.impactGradient))
                .frame(width: isSelected ? 44 : 34, height: isSelected ? 44 : 34)
            Image(systemName: entity.icon)
                .font(.system(size: isSelected ? 18 : 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        .overlay(Circle().stroke(.white, lineWidth: 2))
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct NearbyEntityDetailView: View {
    let entity: NearbyEntity
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(entity.kind == .person ? AnyShapeStyle(LinearGradient.brandGradient) : AnyShapeStyle(LinearGradient.impactGradient))
                        .frame(width: 54, height: 54)
                    Image(systemName: entity.icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(entity.name).font(.cardTitle)
                    Text(entity.subtitle).font(.caption).foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Text(entity.kind == .person ? "Persona" : "Organización")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.brandPrimary.opacity(0.12))
                    .foregroundStyle(Color.brandPrimary)
                    .clipShape(Capsule())
            }

            if !entity.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entity.tags.prefix(4), id: \.self) { SkillChip(text: $0) }
                }
            }

            if let opportunity = entity.opportunity {
                NavigationLink {
                    OpportunityDetailView(opportunity: opportunity)
                } label: {
                    Text("Ver oportunidad")
                }
                .buttonStyle(PrimaryGradientButtonStyle())
            } else {
                Text("La mensajería directa llega en una próxima versión — por ahora puedes verla en el mapa.")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()
        }
        .padding(Layout.screenPadding)
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cerrar") { dismiss() }
            }
        }
    }
}

#Preview {
    NearMeView()
}
