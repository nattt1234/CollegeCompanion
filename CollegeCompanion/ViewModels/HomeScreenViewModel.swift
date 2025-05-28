import SwiftUI
import Combine

class HomeScreenViewModel: ObservableObject {
    // Published properties
    @Published var dailyInsight: AIInsight = AIInsight(
        message: "Loading your personalized insight...",
        suggestion: ""
    )
    @Published var quickActions: [QuickAction] = []
    @Published var isLoading: Bool = false
    @Published var isDebugMode: Bool = false
    @Published var aiEnabled: Bool = true
    @Published var darkModeEnabled: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var appThemeColor: Color = .purple
    
    // Private properties
    private var cancellables = Set<AnyCancellable>()
    private let widgetManager = WidgetManager.shared
    private let aiService = AIService.shared
    
    // MARK: - Initialization
    
    init() {
        setupQuickActions()
        loadUserPreferences()
    }
    
    // MARK: - Public Methods
    
    /// Load user data and refresh the UI
    func loadUserData() {
        isLoading = true
        
        // Load widgets if needed
        if widgetManager.activeWidgets.isEmpty {
            widgetManager.loadWidgets()
        }
        
        // Generate AI insight
        refreshInsight()
        
        isLoading = false
    }
    
    /// Refresh all data
    func refreshAll() {
        isLoading = true
        
        // Refresh insight
        refreshInsight()
        
        // Update widgets (in a real app, this would refresh actual data)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    /// Refresh AI insight
    func refreshInsight() {
        if aiEnabled {
            aiService.generateDailyInsight { [weak self] insight in
                self?.dailyInsight = insight
            }
        }
    }
    
    /// Save user preferences
    func saveUserPreferences() {
        // In a real app, save to UserDefaults
        UserDefaults.standard.set(aiEnabled, forKey: "aiEnabled")
        UserDefaults.standard.set(isDebugMode, forKey: "isDebugMode")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        
        // Note: For color, we'd need to convert to a storable format
        print("User preferences saved")
    }
    
    // MARK: - Private Methods
    
    /// Load user preferences
    private func loadUserPreferences() {
        // In a real app, load from UserDefaults
        aiEnabled = UserDefaults.standard.bool(forKey: "aiEnabled")
        isDebugMode = UserDefaults.standard.bool(forKey: "isDebugMode")
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        
        // Default values if not found
        if !UserDefaults.standard.contains(key: "aiEnabled") {
            aiEnabled = true
        }
        
        if !UserDefaults.standard.contains(key: "notificationsEnabled") {
            notificationsEnabled = true
        }
    }
    
    /// Set up quick actions for the homescreen
    private func setupQuickActions() {
        quickActions = [
            QuickAction(
                title: "Add Task",
                iconName: "plus.square.fill",
                color: AppTheme.Colors.productivity,
                action: {
                    // Handle add task action
                    print("Adding task")
                }
            ),
            QuickAction(
                title: "Scan Notes",
                iconName: "doc.text.viewfinder",
                color: AppTheme.Colors.classes,
                action: {
                    // Handle scan notes action
                    print("Scanning notes")
                }
            ),
            QuickAction(
                title: "Track Expense",
                iconName: "dollarsign.square.fill",
                color: AppTheme.Colors.finance,
                action: {
                    // Handle track expense action
                    print("Tracking expense")
                }
            ),
            QuickAction(
                title: "Log Meal",
                iconName: "fork.knife",
                color: AppTheme.Colors.wellness,
                action: {
                    // Handle log meal action
                    print("Logging meal")
                }
            ),
            QuickAction(
                title: "Study Plan",
                iconName: "brain.head.profile",
                color: AppTheme.Colors.primary,
                action: {
                    // Handle study plan action
                    print("Creating study plan")
                }
            )
        ]
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}


