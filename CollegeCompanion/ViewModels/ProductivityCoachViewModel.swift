import SwiftUI
import Combine

class ProductivityCoachViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [ProductivityTask] = []
    @Published var completedTasks: [ProductivityTask] = []
    @Published var currentSession: FocusSession?
    @Published var todaysStats: PomodoroStats = PomodoroStats()
    @Published var weeklyStats: [PomodoroStats] = []
    @Published var settings: ProductivitySettings = ProductivitySettings()
    @Published var insights: [ProductivityInsight] = []
    @Published var isLoading: Bool = false
    
    // Timer properties
    @Published var isTimerRunning: Bool = false
    @Published var currentSessionType: PomodoroSession = .work
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var completedPomodoros: Int = 0
    
    // Private properties
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    
    // Computed properties for easy access
    var workDuration: Int { settings.workDuration }
    var shortBreakDuration: Int { settings.shortBreakDuration }
    var longBreakDuration: Int { settings.longBreakDuration }
    
    var todaysFocusTime: Int {
        todaysStats.totalFocusTime
    }
    
    var todaysCompletedPomodoros: Int {
        todaysStats.completedPomodoros
    }
    
    var dailyGoalProgress: Double {
        Double(todaysCompletedPomodoros) / Double(settings.dailyGoal)
    }
    
    var weeklyGoalProgress: Double {
        let weeklyTotal = weeklyStats.reduce(0) { $0 + $1.completedPomodoros }
        return Double(weeklyTotal) / Double(settings.weeklyGoal)
    }
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
        loadTasks()
        loadTodaysStats()
        setupInitialState()
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        isLoading = true
        
        // Load all data
        loadSettings()
        loadTasks()
        loadTodaysStats()
        loadWeeklyStats()
        generateInsights()
        
        isLoading = false
    }
    
    func incrementTodaysPomodoros() {
        todaysStats.completedPomodoros += 1
        todaysStats.totalFocusTime += workDuration
        saveTodaysStats()
        
        // Regenerate insights with updated data
        generateInsights()
    }
    
    // MARK: - Task Management
    
    func addTask(title: String, description: String? = nil, priority: TaskPriority = .medium, category: TaskCategory = .personal, dueDate: Date? = nil) {
        let task = ProductivityTask(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: dueDate
        )
        
        tasks.append(task)
        saveTasks()
        
        // Generate updated insights
        generateInsights()
    }
    
    func updateTask(_ task: ProductivityTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
            
            // If task was completed, move to completed tasks
            if task.isCompleted && !completedTasks.contains(where: { $0.id == task.id }) {
                completedTasks.append(task)
                tasks.removeAll(where: { $0.id == task.id })
            }
        }
    }
    
    func deleteTask(withId id: String) {
        tasks.removeAll(where: { $0.id == id })
        completedTasks.removeAll(where: { $0.id == id })
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: ProductivityTask) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.completedAt = updatedTask.isCompleted ? Date() : nil
        updateTask(updatedTask)
    }
    
    // MARK: - Pomodoro Timer Functions
    
    func startTimer() {
        guard !isTimerRunning else { return }
        
        isTimerRunning = true
        
        // Create new focus session
        currentSession = FocusSession(
            taskId: nil,
            sessionType: currentSessionType,
            plannedDuration: getCurrentSessionDuration(),
            startTime: Date()
        )
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
        
        HapticFeedback.medium()
    }
    
    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        
        // Update current session
        currentSession?.endTime = Date()
        
        HapticFeedback.light()
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = TimeInterval(getCurrentSessionDuration() * 60)
        currentSession = nil
        HapticFeedback.medium()
    }
    
    func skipSession() {
        completeCurrentSession()
        switchToNextSession()
        HapticFeedback.medium()
    }
    
    // MARK: - Settings Management
    
    func updateSettings(_ newSettings: ProductivitySettings) {
        settings = newSettings
        saveSettings()
        
        // Update current timer if needed
        if !isTimerRunning {
            timeRemaining = TimeInterval(getCurrentSessionDuration() * 60)
        }
    }
    
    // MARK: - Analytics and Insights
    
    func generateInsights() {
        insights.removeAll()
        
        // Productivity insights based on data
        if completedPomodoros > 0 {
            generateProductivityInsights()
        }
        
        if !tasks.isEmpty {
            generateTaskInsights()
        }
        
        generateTimeManagementInsights()
        generateMotivationalInsights()
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        timeRemaining = TimeInterval(workDuration * 60)
        loadTodaysStats()
        completedPomodoros = todaysStats.completedPomodoros
    }
    
    private func timerTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            completeCurrentSession()
            switchToNextSession()
        }
    }
    
    private func completeCurrentSession() {
        guard var session = currentSession else { return }
        
        session.endTime = Date()
        session.wasCompleted = true
        session.actualDuration = session.duration
        
        // Update statistics
        if session.sessionType == .work {
            completedPomodoros += 1
            todaysStats.completedPomodoros += 1
            todaysStats.totalFocusTime += session.actualDuration ?? session.plannedDuration
            todaysStats.incrementSessionType(session.sessionType)
        } else {
            todaysStats.incrementSessionType(session.sessionType)
        }
        
        // Save session data
        saveSession(session)
        saveTodaysStats()
        
        HapticFeedback.success()
        
        // Generate updated insights
        generateInsights()
    }
    
    private func switchToNextSession() {
        pauseTimer()
        
        if currentSessionType == .work {
            // Determine next break type
            if completedPomodoros % settings.longBreakInterval == 0 {
                currentSessionType = .longBreak
                timeRemaining = TimeInterval(longBreakDuration * 60)
            } else {
                currentSessionType = .shortBreak
                timeRemaining = TimeInterval(shortBreakDuration * 60)
            }
        } else {
            // Switch back to work
            currentSessionType = .work
            timeRemaining = TimeInterval(workDuration * 60)
        }
        
        // Auto-start next session if enabled
        if (currentSessionType == .work && settings.autoStartWork) ||
           (currentSessionType != .work && settings.autoStartBreaks) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.startTimer()
            }
        }
    }
    
    private func getCurrentSessionDuration() -> Int {
        switch currentSessionType {
        case .work:
            return workDuration
        case .shortBreak:
            return shortBreakDuration
        case .longBreak:
            return longBreakDuration
        }
    }
    
    // MARK: - Insight Generation
    
    private func generateProductivityInsights() {
        let avgPomodoros = weeklyStats.isEmpty ? 0 : weeklyStats.reduce(0) { $0 + $1.completedPomodoros } / weeklyStats.count
        
        if completedPomodoros > avgPomodoros {
            insights.append(ProductivityInsight(
                title: "Great Progress!",
                message: "You've completed more pomodoros today than your weekly average.",
                suggestion: "Keep up the momentum and tackle your high-priority tasks.",
                type: .productivity,
                priority: .medium,
                actionable: true,
                createdAt: Date()
            ))
        }
        
        if todaysFocusTime > 120 { // More than 2 hours
            insights.append(ProductivityInsight(
                title: "Excellent Focus",
                message: "You've achieved \(todaysFocusTime) minutes of focused work today.",
                suggestion: "Consider taking a longer break to recharge.",
                type: .focus,
                priority: .low,
                actionable: true,
                createdAt: Date()
            ))
        }
    }
    
    private func generateTaskInsights() {
        let overdueTasks = tasks.filter { $0.isOverdue }.count
        let highPriorityTasks = tasks.filter { $0.priority == .high || $0.priority == .urgent }.count
        
        if overdueTasks > 0 {
            insights.append(ProductivityInsight(
                title: "Overdue Tasks",
                message: "You have \(overdueTasks) overdue task\(overdueTasks == 1 ? "" : "s").",
                suggestion: "Consider rescheduling or breaking them into smaller tasks.",
                type: .timeManagement,
                priority: .high,
                actionable: true,
                createdAt: Date()
            ))
        }
        
        if highPriorityTasks > 5 {
            insights.append(ProductivityInsight(
                title: "Too Many High-Priority Tasks",
                message: "You have \(highPriorityTasks) high-priority tasks.",
                suggestion: "Try to limit high-priority tasks to 3-5 per day for better focus.",
                type: .timeManagement,
                priority: .medium,
                actionable: true,
                createdAt: Date()
            ))
        }
    }
    
    private func generateTimeManagementInsights() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        if currentHour >= 22 && completedPomodoros == 0 {
            insights.append(ProductivityInsight(
                title: "Late Start",
                message: "It's getting late and you haven't started any focus sessions.",
                suggestion: "Try starting your productive work earlier tomorrow.",
                type: .timeManagement,
                priority: .medium,
                actionable: true,
                createdAt: Date()
            ))
        }
    }
    
    private func generateMotivationalInsights() {
        if completedPomodoros >= settings.dailyGoal {
            insights.append(ProductivityInsight(
                title: "Daily Goal Achieved! 🎉",
                message: "Congratulations! You've reached your daily pomodoro goal.",
                suggestion: "Great work! Consider setting a new challenge or taking a well-deserved break.",
                type: .motivation,
                priority: .low,
                actionable: false,
                createdAt: Date()
            ))
        } else if dailyGoalProgress >= 0.8 {
            insights.append(ProductivityInsight(
                title: "Almost There!",
                message: "You're \(Int((1 - dailyGoalProgress) * Double(settings.dailyGoal))) pomodoros away from your daily goal.",
                suggestion: "Push through for one or two more sessions to hit your target!",
                type: .motivation,
                priority: .medium,
                actionable: true,
                createdAt: Date()
            ))
        }
    }
    
    // MARK: - Data Persistence
    
    private func loadSettings() {
        if let data = userDefaults.data(forKey: "productivitySettings"),
           let decodedSettings = try? JSONDecoder().decode(ProductivitySettings.self, from: data) {
            settings = decodedSettings
        }
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: "productivitySettings")
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: "productivityTasks"),
           let decodedTasks = try? JSONDecoder().decode([ProductivityTask].self, from: data) {
            tasks = decodedTasks.filter { !$0.isCompleted }
            completedTasks = decodedTasks.filter { $0.isCompleted }
        }
    }
    
    private func saveTasks() {
        let allTasks = tasks + completedTasks
        if let data = try? JSONEncoder().encode(allTasks) {
            userDefaults.set(data, forKey: "productivityTasks")
        }
    }
    
    private func loadTodaysStats() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "pomodoroStats_\(DateFormatter.yyyyMMdd.string(from: today))"
        
        if let data = userDefaults.data(forKey: key),
           let stats = try? JSONDecoder().decode(PomodoroStats.self, from: data) {
            todaysStats = stats
        } else {
            todaysStats = PomodoroStats(date: today)
        }
    }
    
    private func saveTodaysStats() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "pomodoroStats_\(DateFormatter.yyyyMMdd.string(from: today))"
        todaysStats.date = today
        
        if let data = try? JSONEncoder().encode(todaysStats) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    private func loadWeeklyStats() {
        let calendar = Calendar.current
        let today = Date()
        weeklyStats.removeAll()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayStart = calendar.startOfDay(for: date)
                let key = "pomodoroStats_\(DateFormatter.yyyyMMdd.string(from: dayStart))"
                
                if let data = userDefaults.data(forKey: key),
                   let stats = try? JSONDecoder().decode(PomodoroStats.self, from: data) {
                    weeklyStats.append(stats)
                } else {
                    weeklyStats.append(PomodoroStats(date: dayStart))
                }
            }
        }
    }
    
    private func saveSession(_ session: FocusSession) {
        var sessions = loadSessions()
        sessions.append(session)
        
        if let data = try? JSONEncoder().encode(sessions) {
            userDefaults.set(data, forKey: "focusSessions")
        }
    }
    
    private func loadSessions() -> [FocusSession] {
        if let data = userDefaults.data(forKey: "focusSessions"),
           let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) {
            return sessions
        }
        return []
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}


