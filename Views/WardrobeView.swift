import SwiftUI
import PhotosUI
import UIKit

struct WardrobeView: View {
    @EnvironmentObject private var store: WardrobeStore
    @State private var showingAdd = false
    @State private var selectedCategory: ClothingCategory?

    private var filteredItems: [WardrobeItem] {
        guard let selectedCategory else { return store.items }
        return store.items.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenTitle("Mon dressing", eyebrow: "TA COLLECTION", subtitle: "Chaque pièce compte. Ajoute-les une fois, puis laisse ton styliste composer.")
                    inventorySummary
                    categoryFilter
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(filteredItems) { item in
                            ClothingCard(item: item)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.delete(item)
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.wardrobeBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.wardrobeInk, in: Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddClothingView()
            }
        }
    }

    private var inventorySummary: some View {
        HStack(spacing: 0) {
            summaryCell(value: "\(store.items.count)", label: "pièces")
            Divider().frame(height: 42)
            summaryCell(value: "\(Set(store.items.map(\.color)).count)", label: "couleurs")
            Divider().frame(height: 42)
            summaryCell(value: "\(Set(store.items.map(\.style)).count)", label: "styles")
        }
        .padding(.vertical, 18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
    }

    private func summaryCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.wardrobeInk)
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color.wardrobeMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterButton(title: "Tout", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(ClothingCategory.allCases) { category in
                    filterButton(title: category.title, icon: category.icon, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    private func filterButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : Color.wardrobeInk)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isSelected ? Color.wardrobeInk : Color.white, in: Capsule())
        }
    }
}

struct ClothingCard: View {
    @EnvironmentObject private var store: WardrobeStore
    let item: WardrobeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ClothingThumbnail(item: item)
                .frame(height: 145)
            Text(item.name)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.wardrobeInk)
                .lineLimit(1)
            HStack(spacing: 4) {
                Circle().fill(colorFor(item.color)).frame(width: 8, height: 8)
                Text(item.color)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.wardrobeMuted)
            }
        }
        .padding(10)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            store.markWorn(item)
        }
    }

    private func colorFor(_ color: String) -> Color {
        let value = color.lowercased()
        if value.contains("blanc") || value.contains("écru") { return .white }
        if value.contains("bleu") { return .blue }
        if value.contains("gris") { return .gray }
        if value.contains("noir") { return .black }
        if value.contains("beige") || value.contains("sable") { return .brown.opacity(0.5) }
        if value.contains("kaki") { return .green }
        return .wardrobeCoral
    }
}

struct AddClothingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: WardrobeStore
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var name = ""
    @State private var category: ClothingCategory = .top
    @State private var color = "Blanc"
    @State private var material = "Coton"
    @State private var style = "Polyvalent"
    @State private var formality: ClothingFormality = .casual
    @State private var season: ClothingSeason = .all

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            if let imageData, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                VStack(spacing: 10) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28))
                                    Text("Ajouter une photo")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundStyle(Color.wardrobeInk)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background(Color.wardrobeCream, in: RoundedRectangle(cornerRadius: 20))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
                Section("Description") {
                    TextField("Nom de la pièce", text: $name)
                    Picker("Type", selection: $category) {
                        ForEach(ClothingCategory.allCases) { Text($0.title).tag($0) }
                    }
                    TextField("Couleur", text: $color)
                    TextField("Matière", text: $material)
                    TextField("Style", text: $style)
                }
                Section("Détails") {
                    Picker("Formalité", selection: $formality) {
                        ForEach(ClothingFormality.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Saison", selection: $season) {
                        ForEach(ClothingSeason.allCases) { Text($0.title).tag($0) }
                    }
                }
            }
            .navigationTitle("Nouvelle pièce")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let item = WardrobeItem(
                            name: trimmedName.isEmpty ? "Nouvelle pièce" : trimmedName,
                            category: category,
                            color: color,
                            material: material,
                            style: style,
                            season: season,
                            formality: formality,
                            imageData: imageData
                        )
                        store.add(item)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .task(id: selectedPhoto) {
                imageData = try? await selectedPhoto?.loadTransferable(type: Data.self)
            }
        }
    }
}