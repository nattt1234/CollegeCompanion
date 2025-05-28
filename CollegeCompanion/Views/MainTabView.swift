import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Dashboard
            HomeScreen()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Productivity Coach - NEW!
            ProductivityCoachScreen()
                .tabItem {
                    Label("Productivity", systemImage: "timer")
                }
                .tag(1)
            
            // Class Companion
            Text("Class Companion")
                .tabItem {
                    Label("Classes", systemImage: "book.fill")
                }
                .tag(2)
            
            // Finance Manager
            Text("Finance Manager")
                .tabItem {
                    Label("Finance", systemImage: "dollarsign.circle.fill")
                }
                .tag(3)
            
            // Wellness Planner
            Text("Wellness Planner")
                .tabItem {
                    Label("Wellness", systemImage: "heart.fill")
                }
                .tag(4)
        }
        .accentColor(.purple) // App theme color
    }
}

#Preview {
    MainTabView()
}


