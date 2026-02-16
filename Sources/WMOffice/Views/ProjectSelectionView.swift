import SwiftUI
import SwiftData

struct ProjectSelectionView: View {
    @Binding var selection: Project?
    @Query(sort: \Project.title) private var projects: [Project]
    
    var body: some View {
        List(selection: $selection) {
            ForEach(projects) { project in
                Text(project.title)
                    .tag(project)
            }
        }
        .navigationTitle("Select Project")
    }
}
