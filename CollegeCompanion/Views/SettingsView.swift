import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: HomeScreenViewModel
    @State private var selectedTheme = "system"
    @State private var showOfflineContent = true
    @State private var showDebugInfo = false
    
    // Theme options
    private let themeOptions = ["system", "light", "dark"]
    
    var body: some View {
        NavigationStack {
            List {
                // Appearance section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Use Dark Mode", isOn: $viewModel.darkModeEnabled)
                        .disabled(selectedTheme != "system")
                        .onChange(of: viewModel.darkModeEnabled) { _ in
                            viewModel.saveUserPreferences()
                        }
                }
                
                // Notifications section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                        .onChange(of: viewModel.notificationsEnabled) { _ in
                            viewModel.saveUserPreferences()
                        }
                    
                    if viewModel.notificationsEnabled {
                        NavigationLink(destination: NotificationSettingsView()) {
                            Text("Notification Preferences")
                        }
                    }
                }
                
                // Data & Privacy section
                Section(header: Text("Data & Privacy")) {
                    Toggle("Show Content Offline", isOn: $showOfflineContent)
                    Toggle("Use AI Features", isOn: $viewModel.aiEnabled)
                        .onChange(of: viewModel.aiEnabled) { _ in
                            viewModel.saveUserPreferences()
                            if viewModel.aiEnabled {
                                viewModel.refreshInsight()
                            }
                        }
                    
                    NavigationLink(destination: Text("Privacy Policy View")) {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink(destination: Text("Data Management View")) {
                        Text("Manage Your Data")
                    }
                }
                
                // Customization section
                Section(header: Text("Customization")) {
                    NavigationLink(destination: WidgetSettingsView()) {
                        Text("Widget Preferences")
                    }
                    
                    NavigationLink(destination: AppearanceSettingsView()) {
                        Text("Customize Colors & Theme")
                    }
                }
                
                // AI Assistance section
                if viewModel.aiEnabled {
                    Section(header: Text("AI Assistant")) {
                        NavigationLink(destination: AISettingsView()) {
                            Text("AI Preferences")
                        }
                        
                        Toggle("Show Debug Information", isOn: $viewModel.isDebugMode)
                            .onChange(of: viewModel.isDebugMode) { _ in
                                viewModel.saveUserPreferences()
                            }
                    }
                }
                
                // About section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    Button("Rate the App") {
                        // Handle rating
                    }
                    
                    Button("Send Feedback") {
                        // Handle feedback
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.saveUserPreferences()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct NotificationSettingsView: View {
    @State private var assignmentReminders = true
    @State private var classReminders = true
    @State private var budgetAlerts = true
    @State private var wellnessReminders = true
    @State private var aiSuggestions = true
    
    var body: some View {
        List {
            Toggle("Assignment Deadlines", isOn: $assignmentReminders)
            Toggle("Class Schedule", isOn: $classReminders)
            Toggle("Budget Alerts", isOn: $budgetAlerts)
            Toggle("Wellness Reminders", isOn: $wellnessReminders)
            Toggle("AI Suggestions", isOn: $aiSuggestions)
            
            Section(header: Text("Quiet Hours")) {
                DatePicker("Start Time", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: .constant(Date()), displayedComponents: .hourAndMinute)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct WidgetSettingsView: View {
    @ObservedObject private var widgetManager = WidgetManager.shared
    
    var body: some View {
        List {
            Section(header: Text("Active Widgets")) {
                ForEach(widgetManager.activeWidgets) { widget in
                    HStack {
                        Image(systemName: widget.iconName)
                            .foregroundColor(widget.accentColor)
                        Text(widget.title)
                    }
                }
                .onMove { source, destination in
                    widgetManager.moveWidget(fromOffsets: source, toOffset: destination)
                }
            }
            
            Section {
                Button("Edit Dashboard") {
                    widgetManager.toggleEditMode()
                }
                
                Button("Reset to Default Layout") {
                    // Reset widget layout
                    widgetManager.loadWidgets()
                }
            }
        }
        .navigationTitle("Widgets")
        .toolbar {
            EditButton()
        }
    }
}

struct AppearanceSettingsView: View {
    @State private var primaryColor = Color.purple
    @State private var useSystemFont = true
    @State private var fontSize = 1.0
    
    var body: some View {
        Form {
            Section(header: Text("Theme Color")) {
                ColorPicker("Primary Color", selection: $primaryColor)
                
                HStack {
                    Text("Preview")
                    Spacer()
                    Text("Sample")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Section(header: Text("Text")) {
                Toggle("Use System Font", isOn: $useSystemFont)
                
                if !useSystemFont {
                    Picker("Font Style", selection: .constant("Default")) {
                        Text("Default").tag("Default")
                        Text("Rounded").tag("Rounded")
                        Text("Monospaced").tag("Monospaced")
                    }
                    .pickerStyle(.menu)
                }
                
                VStack {
                    Text("Font Size")
                    Slider(value: $fontSize, in: 0.8...1.2, step: 0.1)
                    HStack {
                        Text("A")
                            .font(.caption)
                        Spacer()
                        Text("A")
                            .font(.title)
                    }
                }
            }
        }
        .navigationTitle("Appearance")
    }
}

struct AISettingsView: View {
    @State private var studyRecommendations = true
    @State private var budgetSuggestions = true
    @State private var wellnessCoaching = true
    @State private var predictiveScheduling = true
    
    var body: some View {
        Form {
            Section(header: Text("AI Features")) {
                Toggle("Study Recommendations", isOn: $studyRecommendations)
                Toggle("Budget Suggestions", isOn: $budgetSuggestions)
                Toggle("Wellness Coaching", isOn: $wellnessCoaching)
                Toggle("Predictive Scheduling", isOn: $predictiveScheduling)
            }
            
            Section(header: Text("Data Collection")) {
                NavigationLink(destination: Text("Data Collection Settings")) {
                    Text("Manage Data Collection")
                }
                
                NavigationLink(destination: Text("AI Personalization")) {
                    Text("Personalization Settings")
                }
            }
            
            Section(header: Text("Reset")) {
                Button("Reset AI Preferences") {
                    // Reset preferences to default
                    studyRecommendations = true
                    budgetSuggestions = true
                    wellnessCoaching = true
                    predictiveScheduling = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("AI Assistant")
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(HomeScreenViewModel())
    }
}


