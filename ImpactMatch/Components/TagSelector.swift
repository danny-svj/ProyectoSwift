//
//  TagSelector.swift
//  ImpactMatch
//
//  Selector de etiquetas (habilidades, intereses...): sugerencias
//  tocables + campo para agregar las propias. Se usa al crear o
//  editar el perfil.
//

import SwiftUI

struct SelectableChip: View {
    let text: String
    let isOn: Bool
    var color: Color = .brandPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(text)
                if isOn {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                }
            }
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isOn ? AnyShapeStyle(color) : AnyShapeStyle(color.opacity(0.10)))
            .foregroundStyle(isOn ? .white : color)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
        .accessibilityHint(isOn ? "Toca dos veces para quitar" : "Toca dos veces para agregar")
    }
}

struct TagSelector: View {
    let suggestions: [String]
    @Binding var selected: [String]
    var color: Color = .brandPrimary
    var placeholder: LocalizedStringKey = "Agregar otra..."

    @State private var customText = ""

    private var remainingSuggestions: [String] {
        suggestions.filter { !selected.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !selected.isEmpty {
                flow(items: selected) { tag in
                    SelectableChip(text: tag, isOn: true, color: color) { remove(tag) }
                }
            }

            if !remainingSuggestions.isEmpty {
                flow(items: remainingSuggestions) { tag in
                    SelectableChip(text: tag, isOn: false, color: color) { add(tag) }
                }
            }

            HStack(spacing: 8) {
                TextField(placeholder, text: $customText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.chipRadius, style: .continuous))
                    .onSubmit(addCustom)

                Button(action: addCustom) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(customText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : color)
                }
                .disabled(customText.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityLabel("Agregar")
            }
        }
    }

    private func flow(items: [String], @ViewBuilder chip: @escaping (String) -> some View) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { chip($0) }
        }
    }

    private func add(_ tag: String) {
        guard !selected.contains(tag) else { return }
        selected.append(tag)
    }

    private func remove(_ tag: String) {
        selected.removeAll { $0 == tag }
    }

    private func addCustom() {
        let trimmed = customText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        add(trimmed)
        customText = ""
    }
}

#Preview {
    @Previewable @State var selected = ["Swift", "Diseño"]
    return TagSelector(suggestions: SkillCatalog.commonSkills, selected: $selected)
        .padding()
}
