import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AppKit

struct DrawingListView: View {
    @Bindable var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var sortOrder = [KeyPathComparator(\Drawing.drawingNumber)]
    
    var body: some View {
        Table(project.drawings ?? [], sortOrder: $sortOrder) {
            TableColumn("Number", value: \.drawingNumber) { drawing in
                NavigationLink(value: drawing) {
                    Text(drawing.drawingNumber)
                }
                .buttonStyle(.plain)
            }
            TableColumn("Title", value: \.title)
            TableColumn("Revision", value: \.revision)
            TableColumn("Status", value: \.status.title)
            TableColumn("Date", value: \.uploadedDate) { drawing in
                Text(drawing.uploadedDate.formatted(date: .numeric, time: .shortened))
            }
        }
        .navigationDestination(for: Drawing.self) { drawing in
            DrawingMarkupView(drawing: drawing)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Drawing", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDrawingView(project: project)
        }
        .navigationTitle("Drawings")
    }
}

struct AddDrawingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    var project: Project
    
    @State private var drawingNumber = ""
    @State private var title = ""
    @State private var revision = "A"
    @State private var status: DrawingStatus = .draft
    @State private var selectedImage: Data?
    @State private var isImporting = false
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Drawing Number", text: $drawingNumber)
                TextField("Title", text: $title)
                TextField("Revision", text: $revision)
                Picker("Status", selection: $status) {
                    ForEach(DrawingStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
            }
            
            Section("Image") {
                if let data = selectedImage, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
                
                Button("Select Image") {
                    isImporting = true
                }
            }
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                Spacer()
                Button("Add Drawing") {
                    let drawing = Drawing(
                        drawingNumber: drawingNumber,
                        title: title,
                        revision: revision,
                        status: status,
                        project: project
                    )
                    drawing.imageData = selectedImage
                    modelContext.insert(drawing)
                    project.drawings?.append(drawing)
                    dismiss()
                }
                .disabled(drawingNumber.isEmpty || title.isEmpty || selectedImage == nil)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image, .pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) {
                            selectedImage = data
                        }
                    }
                }
            case .failure(let error):
                print("Error importing file: \(error.localizedDescription)")
            }
        }
    }
}
