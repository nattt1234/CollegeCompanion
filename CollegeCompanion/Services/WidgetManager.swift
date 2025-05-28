import SwiftUI
import Combine

/// Service to manage widgets in the app
class WidgetManager: ObservableObject {
    // Published properties for widget system
    @Published var availableWidgets: [WidgetModel] = []
    @Published var activeWidgets: [WidgetModel] = []
    @Published var isEditMode: Bool = false
    
    // User defaults keys
    private let activeWidgetsKey = "activeWidgets"
    private let widgetOrderKey = "widgetOrder"
    
    // Singleton instance
    static let shared = WidgetManager()
    
    private init() {
        loadWidgets()
    }
    
    /// Load widgets from storage or create defaults
    func loadWidgets() {
        // In a real app, we would load from UserDefaults or database
        // For now, use demo data
        createDemoWidgets()
        
        // Sort widgets by saved order
        activeWidgets.sort { $0.order < $1.order }
    }
    
    /// Save the current widget configuration
    func saveWidgetConfiguration() {
        // Update order values based on current array order
        for (index, _) in activeWidgets.enumerated() {
            activeWidgets[index].order = index
        }
        
        // In a real app, save to UserDefaults or database
        // UserDefaults.standard.set(encodedWidgets, forKey: activeWidgetsKey)
        print("Widget configuration saved")
    }
    
    /// Add a widget to the active widgets
    func addWidget(_ widget: WidgetModel) {
        // Set the order to be at the end
        var newWidget = widget
        newWidget.order = activeWidgets.count
        
        // Add to active widgets
        activeWidgets.append(newWidget)
        saveWidgetConfiguration()
    }
    
    /// Remove a widget from the active widgets
    func removeWidget(withID id: String) {
        activeWidgets.removeAll { $0.id == id }
        saveWidgetConfiguration()
    }
    
    /// Reorder widgets
    func moveWidget(fromOffsets source: IndexSet, toOffset destination: Int) {
        activeWidgets.move(fromOffsets: source, toOffset: destination)
        saveWidgetConfiguration()
    }
    
    /// Toggle edit mode
    func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
        }
    }
    
    /// Create initial demo widgets
    private func createDemoWidgets() {
        // Create mock data
        let tasks = createMockTasks()
        let courses = createMockCourses()
        let transactions = createMockTransactions()
        let wellnessLog = createMockWellnessLog()
        
        // Filter for today's classes
        let today = Calendar.current.component(.weekday, from: Date())
        let todayClasses = courses.filter { $0.daysOfWeek.contains(today) }
        
        // Create widgets
        activeWidgets = [
            WidgetModel(
                id: "tasks",
                title: "Tasks",
                subtitle: "Today's focus",
                iconName: "checklist",
                content: AnyView(TasksWidgetContent(tasks: tasks)),
                actionLabel: "View all",
                accentColor: AppTheme.Colors.productivity,
                hasNotification: true,
                notificationCount: tasks.filter { !$0.isCompleted }.count,
                order: 0
            ),
            
            WidgetModel(
                id: "classes",
                title: "Classes",
                subtitle: "Today's schedule",
                iconName: "book.fill",
                content: AnyView(ClassesWidgetContent(classes: todayClasses)),
                actionLabel: "Full schedule",
                accentColor: AppTheme.Colors.classes,
                hasNotification: false,
                order: 1
            ),
            
            WidgetModel(
                id: "finance",
                title: "Finance",
                subtitle: "Recent spending",
                iconName: "dollarsign.circle.fill",
                content: AnyView(FinanceWidgetContent(transactions: transactions)),
                actionLabel: "View details",
                accentColor: AppTheme.Colors.finance,
                hasNotification: false,
                order: 2
            ),
            
            WidgetModel(
                id: "wellness",
                title: "Wellness",
                subtitle: "Today's stats",
                iconName: "heart.fill",
                content: AnyView(WellnessWidgetContent(wellnessLog: wellnessLog)),
                actionLabel: "Health center",
                accentColor: AppTheme.Colors.wellness,
                hasNotification: false,
                order: 3
            )
        ]
        
        // Also add these to available widgets
        availableWidgets = activeWidgets
    }
    
    // MARK: - Mock Data Generation
    
    private func createMockTasks() -> [Task] {
        return [
            Task(title: "Economics assignment", isCompleted: false, dueDate: Date().addingTimeInterval(2*24*60*60), priority: .high, course: "ECON 101"),
            Task(title: "Physics lab report", isCompleted: false, dueDate: Date().addingTimeInterval(4*24*60*60), priority: .medium, course: "PHYS 201"),
            Task(title: "Read chapter 5", isCompleted: true, priority: .low, course: "HIST 150")
        ]
    }
    
    private func createMockCourses() -> [Course] {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return [
            Course(
                name: "Economics 101",
                code: "ECON 101",
                color: .green,
                professor: "Dr. Smith",
                location: "Building A, Room 203",
                startTime: dateFormatter.date(from: "10:00") ?? now,
                endTime: dateFormatter.date(from: "11:30") ?? now,
                daysOfWeek: [2, 4] // Monday and Wednesday
            ),
            Course(
                name: "Physics 201",
                code: "PHYS 201",
                color: .blue,
                professor: "Dr. Johnson",
                location: "Science Hall, Room 105",
                startTime: dateFormatter.date(from: "13:00") ?? now,
                endTime: dateFormatter.date(from: "14:30") ?? now,
                daysOfWeek: [2, 4, 6] // Monday, Wednesday, Friday
            ),
            Course(
                name: "History 150",
                code: "HIST 150",
                color: .orange,
                professor: "Dr. Williams",
                location: "Building C, Room 310",
                startTime: dateFormatter.date(from: "15:00") ?? now,
                endTime: dateFormatter.date(from: "16:30") ?? now,
                daysOfWeek: [3, 5] // Tuesday and Thursday
            )
        ]
    }
    
    private func createMockTransactions() -> [Transaction] {
        return [
            Transaction(amount: 15.49, title: "Campus Café", category: .food, date: Date().addingTimeInterval(-1*24*60*60), isIncome: false),
            Transaction(amount: 45.00, title: "Textbook", category: .education, date: Date().addingTimeInterval(-2*24*60*60), isIncome: false),
            Transaction(amount: 250.00, title: "Part-time job", category: .income, date: Date().addingTimeInterval(-3*24*60*60), isIncome: true)
        ]
    }
    
    private func createMockWellnessLog() -> WellnessLog {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return WellnessLog(
            date: Date(),
            sleepHours: 7.5,
            stressLevel: 3,
            mood: .good,
            mealLogs: [
                MealLog(mealType: .breakfast, description: "Oatmeal with fruit", time: dateFormatter.date(from: "08:00") ?? now, rating: 4)
            ],
            waterIntake: 24,
            exerciseMinutes: 30
        )
    }
}
