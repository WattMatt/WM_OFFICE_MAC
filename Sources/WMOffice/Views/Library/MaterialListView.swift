import SwiftUI
import SwiftData

struct MaterialListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Material.code) private var materials: [Material]
    @Binding var selection: Material?
    @State private var searchText = ""

    var filteredMaterials: [Material] {
        if searchText.isEmpty {
            return materials
        } else {
            return materials.filter { material in
                material.code.localizedCaseInsensitiveContains(searchText) ||
                material.materialDescription.localizedCaseInsensitiveContains(searchText) ||
                material.supplier.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredMaterials) { material in
                NavigationLink(value: material) {
                    VStack(alignment: .leading) {
                        Text(material.code)
                            .font(.headline)
                        Text(material.materialDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteMaterials)
        }
        .searchable(text: $searchText, prompt: "Search Code, Description, Supplier")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addMaterial) {
                    Label("Add Material", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Master Library")
    }

    private func addMaterial() {
        let newMaterial = Material(code: "NEW-\(Int.random(in: 1000...9999))", materialDescription: "New Material", unit: "EA", rate: 0.0, supplier: "Unknown")
        modelContext.insert(newMaterial)
        selection = newMaterial
    }

    private func deleteMaterials(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if let materialToDelete = filteredMaterials[safe: index] {
                    modelContext.delete(materialToDelete)
                    if selection == materialToDelete {
                        selection = nil
                    }
                }
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct MaterialDetailView: View {
    @Bindable var material: Material

    var body: some View {
        Form {
            Section("Details") {
                TextField("Code", text: $material.code)
                TextField("Description", text: $material.materialDescription)
                TextField("Unit", text: $material.unit)
                TextField("Rate", value: $material.rate, format: .currency(code: "USD"))
                TextField("Supplier", text: $material.supplier)
            }
        }
        .navigationTitle(material.code)
    }
}
