import SwiftUI
import Firebase

@main
struct CollegeCompanionApp: App {
    // Initialize Firebase when the app launches
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

