//
//  UserTypeSelectionView.swift
//  ImpactMatch
//

import SwiftUI

struct UserTypeSelectionView: View {
    @State private var selected: UserType? = nil
    @State private var goToSignUp = false

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("¿Cómo quieres usar ImpactMatch?")
                    .font(.screenTitle)
                    .multilineTextAlignment(.center)
                Text("Esto nos ayuda a personalizar tu experiencia")
                    .font(.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.top, 32)

            VStack(spacing: 16) {
                UserTypeOptionCard(
                    type: .person,
                    icon: "person.fill",
                    description: "Busco oportunidades donde aportar mis habilidades",
                    isSelected: selected == .person
                ) { selected = .person }

                UserTypeOptionCard(
                    type: .organization,
                    icon: "building.2.fill",
                    description: "Busco personas o aliados para mis proyectos",
                    isSelected: selected == .organization
                ) { selected = .organization }
            }
            .padding(.horizontal, Layout.screenPadding)

            Spacer()

            Button {
                goToSignUp = true
            } label: {
                Text("Continuar")
            }
            .buttonStyle(PrimaryGradientButtonStyle(isDisabled: selected == nil))
            .disabled(selected == nil)
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, 20)
        }
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToSignUp) {
            SignUpView(userType: selected ?? .person)
        }
    }
}

struct UserTypeOptionCard: View {
    let type: UserType
    let icon: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(isSelected ? AnyShapeStyle(LinearGradient.brandGradient) : AnyShapeStyle(Color.gray.opacity(0.12)))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundStyle(isSelected ? .white : Color.textSecondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.localizedName).font(.cardTitle)
                    Text(description).font(.caption).foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.brandPrimary : Color.gray.opacity(0.3))
            }
            .padding(16)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cardRadius, style: .continuous)
                    .stroke(isSelected ? Color.brandPrimary : .clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack { UserTypeSelectionView() }
}
