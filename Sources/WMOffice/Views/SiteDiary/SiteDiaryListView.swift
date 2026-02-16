import SwiftUI
import SwiftData

struct SiteDiaryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SiteDiaryEntry.date, order: .reverse) private var entries: [SiteDiaryEntry]
    @Binding var selection: SiteDiaryEntry?

    init(selection: Binding<SiteDiaryEntry?>) {
        _selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(entries) { entry in
                NavigationLink(value: entry) {
                    VStack(alignment: .leading) {
                        Text(entry.date, style: .date)
                            .font(.headline)
                        if !entry.weatherSummary.isEmpty {
                            Text(entry.weatherSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Site Diary")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = SiteDiaryEntry(date: Date())
            modelContext.insert(newItem)
            selection = newItem
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
        }
    }
}
