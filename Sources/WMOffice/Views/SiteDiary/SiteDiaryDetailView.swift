import SwiftUI

struct SiteDiaryDetailView: View {
    @Bindable var entry: SiteDiaryEntry
    
    @State private var newTaskText: String = ""

    var body: some View {
        Form {
            Section("Details") {
                DatePicker("Date", selection: $entry.date, displayedComponents: .date)
                TextField("Weather Summary", text: $entry.weatherSummary)
            }
            
            Section("Notes") {
                TextEditor(text: $entry.notes)
                    .frame(minHeight: 100)
            }
            
            Section("Tasks") {
                HStack {
                    TextField("New Task", text: $newTaskText)
                        .onSubmit(addTask)
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(newTaskText.isEmpty)
                }
                
                List {
                    ForEach(entry.tasks.indices, id: \.self) { index in
                        // Using indices because Strings are not identifiable and we want to edit/delete
                        Text(entry.tasks[index])
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
        }
        .navigationTitle("Site Diary Entry")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func addTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        withAnimation {
            entry.tasks.append(newTaskText)
            newTaskText = ""
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            entry.tasks.remove(atOffsets: offsets)
        }
    }
}
