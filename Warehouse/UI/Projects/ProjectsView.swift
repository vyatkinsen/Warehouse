import SwiftUI

struct ProjectsView: View {
    
    @StateObject private var viewModel: ProjectsViewModel = ProjectsViewModel()
    
    var body: some View {
        BaseView(viewModel: viewModel) { projects in
            CardsGridView(items: projects.map { ($0.id, $0.name) }) { id, name in
                WarehouseView(projectId: id, projectName: name)
            }
        }
        .navigationTitle("Проекты")
    }
}
