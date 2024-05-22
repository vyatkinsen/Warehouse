import Foundation

@MainActor
final class ProjectsViewModel: BaseViewModel<[Project]> {
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<[Project]>) async {
        await domain.getProjects(subject: subject)
    }
}
