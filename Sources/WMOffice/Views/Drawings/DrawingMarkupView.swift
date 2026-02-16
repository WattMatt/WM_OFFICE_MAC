import SwiftUI
import SwiftData
import AppKit

struct DrawingMarkupView: View {
    @Bindable var drawing: Drawing
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var tappedLocation: CGPoint?
    
    // Zoom/Pan
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(nsColor: .windowBackgroundColor) // Background
                
                if let imageData = drawing.imageData, let nsImage = NSImage(data: imageData) {
                    // We need a container to handle gestures and coordinate space
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            // This GeometryReader is inside the image's coordinate space (before scale/offset if applied here?)
                            // No, we apply scale/offset to the whole ZStack content or a wrapper.
                            GeometryReader { imageGeometry in
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { location in
                                        // location is local to this view (the image bounds)
                                        let normalizedX = location.x / imageGeometry.size.width
                                        let normalizedY = location.y / imageGeometry.size.height
                                        
                                        if normalizedX >= 0 && normalizedX <= 1 && normalizedY >= 0 && normalizedY <= 1 {
                                            self.tappedLocation = CGPoint(x: normalizedX, y: normalizedY)
                                            self.showingAddSheet = true
                                        }
                                    }
                                    // Markups overlay
                                    .overlay(
                                        ZStack {
                                            if let markups = drawing.markups {
                                                ForEach(markups) { markup in
                                                    MarkupPin(markup: markup)
                                                        .position(
                                                            x: markup.x * imageGeometry.size.width,
                                                            y: markup.y * imageGeometry.size.height
                                                        )
                                                }
                                            }
                                        }
                                    )
                            }
                        )
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value.magnitude
                                }
                                .onEnded { value in
                                    lastScale = scale
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
                                }
                                .onEnded { value in
                                    lastOffset = offset
                                }
                        )
                } else {
                    ContentUnavailableView("No Image", systemImage: "photo")
                }
            }
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showingAddSheet) {
            if let location = tappedLocation {
                AddMarkupSheet(drawing: drawing, location: location)
            }
        }
        .navigationTitle(drawing.drawingNumber)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    scale = 1.0
                    offset = .zero
                    lastScale = 1.0
                    lastOffset = .zero
                }) {
                    Label("Reset View", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }
}

struct MarkupPin: View {
    let markup: Markup
    @State private var isHovering = false
    
    var body: some View {
        Circle()
            .fill(color(for: markup.type))
            .frame(width: 20, height: 20)
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 2)
            .scaleEffect(isHovering ? 1.5 : 1.0)
            .animation(.spring(), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
            .help("\(markup.title): \(markup.content)")
    }
    
    func color(for type: MarkupType) -> Color {
        switch type {
        case .inspection: return .red
        case .note: return .blue
        case .measurement: return .green
        }
    }
}

struct AddMarkupSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    var drawing: Drawing
    var location: CGPoint
    
    @State private var title = ""
    @State private var content = ""
    @State private var type: MarkupType = .note
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $title)
                TextField("Content", text: $content)
                Picker("Type", selection: $type) {
                    ForEach(MarkupType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
            }
            
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
                Button("Add") {
                    let markup = Markup(
                        type: type,
                        title: title,
                        content: content,
                        x: Double(location.x),
                        y: Double(location.y),
                        drawing: drawing
                    )
                    modelContext.insert(markup)
                    drawing.markups?.append(markup)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 300, height: 250)
    }
}
