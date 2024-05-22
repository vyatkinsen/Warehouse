import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var domain: Domain
    
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Label("Главная", systemImage: "list.number")
                }
            QRScanTabView()
                .tabItem {
                    Label("Сканер", systemImage: "qrcode.viewfinder")
                }
        }
        .id(domain.needAuth.wrappedValue)
        .fullScreenCover(isPresented: domain.needAuth) {
            AuthUI()
                .interactiveDismissDisabled()
        }
    }
}
