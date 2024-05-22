import Foundation

@MainActor
final class WarehousesViewModel: BaseViewModel<[Warehouse]> {
    
    let projectId: Int
    
    init(projectId: Int) {
        self.projectId = projectId
        
        super.init()
    }
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<[Warehouse]>) async {
        await domain.getWarehouses(projectId: projectId, subject: subject)
    }
}
