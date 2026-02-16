import SwiftUI
import SwiftData

struct FloorPlanView: View {
    @Bindable var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var tappedLocation: CGPoint?
    @State private var isImportingFloorPlan = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let imageData = project.floorPlanImageData,
                   let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            GeometryReader { imageGeometry in
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { location in
                                        // Calculate normalized coordinates relative to the image frame
                                        let normalizedX = location.x / imageGeometry.size.width
                                        let normalizedY = location.y / imageGeometry.size.height
                                        
                                        // Only add if within bounds (safety check)
                                        if normalizedX >= 0 && normalizedX <= 1 && normalizedY >= 0 && normalizedY <= 1 {
                                            self.tappedLocation = CGPoint(x: normalizedX, y: normalizedY)
                                            self.showingAddSheet = true
                                        }
                                    }
                                    .overlay(
                                        // Overlay existing inspections as pins
                                        ZStack {
                                            if let inspections = project.inspections {
                                                ForEach(inspections) { inspection in
                                                    InspectionPin(inspection: inspection)
                                                        .position(
                                                            x: inspection.x_coord * imageGeometry.size.width,
                                                            y: inspection.y_coord * imageGeometry.size.height
                                                        )
                                                }
                                            }
                                        }
                                    )
                            }
                        )
                } else {
                    ContentUnavailableView {
                        Label("No Floor Plan", systemImage: "photo")
                    } description: {
                        Text("Add a floor plan image to start pinning inspections.")
                    } actions: {
                        Button("Select Image") {
                            isImportingFloorPlan = true
                        }
                    }
                }
            }
        }
        .fileImporter(isPresented: $isImportingFloorPlan, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url) {
                    project.floorPlanImageData = data
                }
            case .failure(let error):
                print("Error importing floor plan: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if let location = tappedLocation {
                AddInspectionAtLocationSheet(project: project, location: location)
            }
        }
    }
}

struct InspectionPin: View {
    let inspection: Inspection
    @State private var isHovering = false
    
    var body: some View {
        NavigationLink(destination: InspectionDetailView(inspection: inspection)) {
            Circle()
                .fill(statusColor(for: inspection.status))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 2)
                .scaleEffect(isHovering ? 1.2 : 1.0)
                .animation(.spring(), value: isHovering)
                .onHover { hovering in
                    isHovering = hovering
                }
                .help(inspection.title) // Tooltip on hover
        }
        .buttonStyle(.plain) // Remove button styling for NavigationLink in this context
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

struct AddInspectionAtLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: Project
    let location: CGPoint
    
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
                Section(header: Text("Location")) {
                    Text("X: \(location.x, specifier: "%.2f")")
                    Text("Y: \(location.y, specifier: "%.2f")")
                }
            }
            .navigationTitle("New Inspection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let inspection = Inspection(
                            title: title,
                            status: status,
                            x: Double(location.x),
                            y: Double(location.y)
                        )
                        project.inspections?.append(inspection)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 350)
    }
}
