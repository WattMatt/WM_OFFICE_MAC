import SwiftUI
import SwiftData

struct InspectionListView: View {
    @Bindable var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddInspection = false
    
    var body: some View {
        List {
            ForEach(project.inspections ?? []) { inspection in
                NavigationLink(destination: InspectionDetailView(inspection: inspection)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(inspection.title)
                                .font(.headline)
                            Text(inspection.status.title)
                                .font(.caption)
                                .foregroundStyle(statusColor(for: inspection.status))
                        }
                        Spacer()
                        Text(inspection.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteInspections)
        }
        .navigationTitle("Inspections")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddInspection = true }) {
                    Label("Add Inspection", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddInspection) {
            AddInspectionSheet(project: project)
        }
    }
    
    private func deleteInspections(offsets: IndexSet) {
        guard let inspections = project.inspections else { return }
        withAnimation {
            for index in offsets {
                modelContext.delete(inspections[index])
            }
            try? modelContext.save()
        }
    }
    
    private func statusColor(for status: InspectionStatus) -> Color {
        switch status {
        case .open: return .blue
        case .inProgress: return .orange
        case .resolved: return .green
        case .closed: return .gray
        }
    }
}

struct InspectionDetailView: View {
    @Bindable var inspection: Inspection
    @State private var newPhotoData: Data?
    @State private var isImportingPhoto = false
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $inspection.title)
                Picker("Status", selection: $inspection.status) {
                    ForEach(InspectionStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
            }
            
            Section(header: Text("Location")) {
                HStack {
                    Text("X: \(inspection.x_coord, specifier: "%.2f")")
                    Spacer()
                    Text("Y: \(inspection.y_coord, specifier: "%.2f")")
                }
            }
            
            Section(header: Text("Photos")) {
                if let photos = inspection.photos {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(photos) { photo in
                                if let uiImage = NSImage(data: photo.imageData) {
                                    Image(nsImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                Button("Add Photo") {
                    isImportingPhoto = true
                }
            }
        }
        .navigationTitle(inspection.title)
        .fileImporter(isPresented: $isImportingPhoto, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url) {
                    let photo = Photo(imageData: data)
                    inspection.photos?.append(photo)
                }
            case .failure(let error):
                print("Error importing photo: \(error.localizedDescription)")
            }
        }
    }
}

struct AddInspectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: Project
    @State private var title = ""
    @State private var status: InspectionStatus = .open
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Status", selection: $status) {
                    ForEach(InspectionStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
            }
            .navigationTitle("New Inspection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let inspection = Inspection(title: title, status: status, x: 0.5, y: 0.5) // Default center
                        project.inspections?.append(inspection)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}
