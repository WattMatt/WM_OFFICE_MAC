import SwiftUI
import SwiftData
import Charts

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case projects = "Projects"
    case siteDiary = "Site Diary"
    case masterLibrary = "Master Library"
    case cableSchedules = "Cable Schedules"
    case costReports = "Cost Reports"
    case invoicing = "Invoicing"
    case procurement = "Procurement"
    case finalAccounts = "Final Accounts"
    case drawings = "Drawings"
    case staff = "Staff"
    case users = "Users"
    case handover = "Handover"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.pie"
        case .projects: return "folder"
        case .siteDiary: return "book.closed"
        case .masterLibrary: return "books.vertical"
        case .cableSchedules: return "bolt.ring.closed"
        case .costReports: return "chart.bar.doc.horizontal"
        case .invoicing: return "doc.text"
        case .procurement: return "shippingbox"
        case .finalAccounts: return "list.bullet.rectangle.portrait"
        case .drawings: return "doc.richtext"
        case .staff: return "person.2"
        case .users: return "person.3"
        case .handover: return "checklist"
        }
    }
}

struct DashboardView: View {
    @State private var authService = AuthService.shared
    @State private var selectedModule: SidebarItem? = .dashboard
    @State private var selectedProject: Project?
    @State private var selectedDiaryEntry: SiteDiaryEntry?
    @State private var selectedMaterial: Material?
    @State private var selectedCostReport: CostReport?
    @State private var selectedInvoice: Invoice?
    @State private var selectedProcurementItem: ProcurementItem?
    @State private var selectedFinalAccount: FinalAccount?
    @State private var selectedStaff: StaffMember?
    @State private var selectedUser: AppUser?
    @State private var selectedDrawingProject: Project? // For Drawings module
    @State private var selectedHandoverProject: Project? // For Handover module

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedModule) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
            .navigationTitle("WM Office")
            #if os(macOS)
            .listStyle(.sidebar)
            #endif
        } content: {
            if let module = selectedModule {
                switch module {
                case .dashboard:
                    List {
                        Text("Overview")
                            .font(.headline)
                        
                        Text("This dashboard provides a high-level summary of your projects and costs.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                case .projects:
                    ProjectListView(selection: $selectedProject)
                case .siteDiary:
                    SiteDiaryListView(selection: $selectedDiaryEntry)
                case .masterLibrary:
                    MaterialListView(selection: $selectedMaterial)
                case .cableSchedules:
                    Text("Select a run to view details")
                        .foregroundStyle(.secondary)
                case .costReports:
                    CostReportListView(selection: $selectedCostReport)
                case .invoicing:
                    InvoiceListView(selection: $selectedInvoice)
                case .procurement:
                    ProcurementListView(selection: $selectedProcurementItem)
                case .finalAccounts:
                    FinalAccountListView(selection: $selectedFinalAccount)
                case .drawings:
                    ProjectSelectionView(selection: $selectedDrawingProject)
                        .navigationTitle("Select Project")
                case .staff:
                    StaffListView(selection: $selectedStaff)
                case .users:
                    List(selection: $selectedUser) {
                        Text("Select Users from the detail view")
                    }
                case .handover:
                    ProjectSelectionView(selection: $selectedHandoverProject)
                        .navigationTitle("Select Project")
                }
            } else {
                Text("Select a module")
            }
        } detail: {
            if let module = selectedModule {
                switch module {
                case .dashboard:
                    DashboardChartsView()
                case .projects:
                    if let project = selectedProject {
                        ProjectDetailView(project: project)
                    } else {
                        Text("Select a project")
                            .foregroundStyle(.secondary)
                    }
                case .siteDiary:
                    if let entry = selectedDiaryEntry {
                        SiteDiaryDetailView(entry: entry)
                    } else {
                        Text("Select a diary entry")
                            .foregroundStyle(.secondary)
                    }
                case .masterLibrary:
                    if let material = selectedMaterial {
                        MaterialDetailView(material: material)
                    } else {
                        Text("Select a material")
                            .foregroundStyle(.secondary)
                    }
                case .cableSchedules:
                    CableScheduleView()
                case .costReports:
                    if let report = selectedCostReport {
                        CostReportDetailView(report: report)
                    } else {
                        Text("Select a report")
                            .foregroundStyle(.secondary)
                    }
                case .invoicing:
                    if let invoice = selectedInvoice {
                        InvoiceDetailView(invoice: invoice)
                    } else {
                        Text("Select an invoice")
                            .foregroundStyle(.secondary)
                    }
                case .procurement:
                    if let item = selectedProcurementItem {
                        ProcurementDetailView(item: item)
                    } else {
                        Text("Select an item")
                            .foregroundStyle(.secondary)
                    }
                case .finalAccounts:
                    if let account = selectedFinalAccount {
                        FinalAccountDetailView(account: account)
                    } else {
                        Text("Select an account item")
                            .foregroundStyle(.secondary)
                    }
                case .drawings:
                    if let project = selectedDrawingProject {
                        DrawingListView(project: project)
                    } else {
                        Text("Select a project to view drawings")
                            .foregroundStyle(.secondary)
                    }
                case .staff:
                    if let staff = selectedStaff {
                        StaffDetailView(staff: staff)
                    } else {
                        Text("Select a staff member")
                            .foregroundStyle(.secondary)
                    }
                case .users:
                    UserListView()
                case .handover:
                    if let project = selectedHandoverProject {
                        HandoverChecklistView(project: project)
                    } else {
                        Text("Select a project to view handover checklist")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Select a module")
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    Task {
                        try? await authService.signOut()
                    }
                }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }
    
    private func color(for status: ProjectStatus) -> Color {
        switch status {
        case .active: return .green
        case .pending: return .orange
        case .completed: return .blue
        case .archived: return .gray
        }
    }
}

struct DashboardChartsView: View {
    @Query private var projects: [Project]
    @Query private var costReports: [CostReport]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 24) {
                    
                    // Project Status Chart
                    VStack(alignment: .leading) {
                        Text("Project Status")
                            .font(.headline)
                        
                        Chart(projects) { project in
                            SectorMark(
                                angle: .value("Count", 1),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .cornerRadius(5)
                            .foregroundStyle(by: .value("Status", project.status.title))
                        }
                        .frame(height: 300)
                        .chartLegend(position: .bottom)
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Budget vs Actual Chart
                    VStack(alignment: .leading) {
                        Text("Budget vs Actual")
                            .font(.headline)
                        
                        let totalBudget = projects.reduce(0) { $0 + $1.budget }
                        let totalActual = costReports.reduce(Decimal(0)) { reportTotal, report in
                            reportTotal + report.categories.reduce(Decimal(0)) { catTotal, category in
                                catTotal + category.totalActual
                            }
                        }
                        
                        Chart {
                            BarMark(
                                x: .value("Type", "Budget"),
                                y: .value("Amount", totalBudget)
                            )
                            .foregroundStyle(.blue)
                            
                            BarMark(
                                x: .value("Type", "Actual"),
                                y: .value("Amount", NSDecimalNumber(decimal: totalActual).doubleValue)
                            )
                            .foregroundStyle(.orange)
                        }
                        .frame(height: 300)
                        .chartLegend(position: .bottom)
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct ProjectDetailView: View {
    let project: Project
    
    var body: some View {
        TabView {
            // Tab 1: Overview
            VStack(spacing: 20) {
                Text(project.title)
                    .font(.largeTitle)
                
                Text("Status: \(project.status.title)")
                    .font(.headline)
                    .padding()
                    .background(projectStatusColor(project.status).opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("Overview", systemImage: "info.circle")
            }
            
            // Tab 2: Inspections
            NavigationStack {
                InspectionListView(project: project)
            }
            .tabItem {
                Label("Inspections", systemImage: "list.bullet.clipboard")
            }
            
            // Tab 3: Floor Plan
            NavigationStack {
                FloorPlanView(project: project)
            }
            .tabItem {
                Label("Floor Plan", systemImage: "map")
            }
        }
    }
    
    private func projectStatusColor(_ status: ProjectStatus) -> Color {
        switch status {
        case .active: return .green
        case .pending: return .orange
        case .completed: return .blue
        case .archived: return .gray
        }
    }
}
