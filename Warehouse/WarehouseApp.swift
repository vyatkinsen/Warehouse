import SwiftUI

@main
struct WarehouseApp: App {
    
    @StateObject private var domain = Domain()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                .environment(\.locale, Locale.init(identifier: "ru"))
                .environmentObject(domain)
        }
    }
}
