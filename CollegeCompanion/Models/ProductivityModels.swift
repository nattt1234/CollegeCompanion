import SwiftUI
import Foundation

// MARK: - Pomodoro Session Types
enum PomodoroSession: String, CaseIterable, Codable {
    case work = "work"
    case shortBreak = "short break"
    case longBreak = "long break"
    
    var color: Color {
        switch self {
        case .work:
            return AppTheme.Colors.productivity
        case .shortBreak:
            return .blue
        case .longBreak:
            return .green
        }
    }
    
    var iconName: String {
        switch self {
        case .work:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "bed.double.fill"
        }
    }
}

// MARK: - Enhanced Task Model
struct ProductivityTask: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    var isCompleted: Bool = false
    var priority: TaskPriority = .medium
    var category: TaskCategory = .personal
    var dueDate: Date?
    var estimatedDuration: Int? // in minutes
    var actualDuration: Int? // in minutes
    var pomodorosCompleted: Int = 0
    var pomodorosEstimated: Int?
    var course: String?
    var createdAt: Date = Date()
    var completedAt: Date?
    var tags: [String] = []
    var subtasks: [Subtask] = []
    
    // Custom initializer
    init(title: String, description: String? = nil, priority: TaskPriority = .medium, category: TaskCategory = .personal, dueDate: Date? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.priority = priority
        self.category = category
        self.dueDate = dueDate
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var completionRate: Double {
        guard !subtasks.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        let completedSubtasks = subtasks.filter { $0.isCompleted }.count
        return Double(completedSubtasks) / Double(subtasks.count)
    }
}

// MARK: - Task Priority
enum TaskPriority: Int, CaseIterable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    var color: Color {
        switch self {
        case .low:
            return .gray
        case .medium:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
    
    var label: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }
    
    var iconName: String {
        switch self {
        case .low:
            return "arrow.down"
        case .medium:
            return "minus"
        case .high:
            return "arrow.up"
        case .urgent:
            return "exclamationmark.2"
        }
    }
}

// MARK: - Task Category
enum TaskCategory: String, CaseIterable, Codable {
    case personal = "Personal"
    case academic = "Academic"
    case work = "Work"
    case health = "Health"
    case finance = "Finance"
    case social = "Social"
    case creative = "Creative"
    
    var color: Color {
        switch self {
        case .personal:
            return .purple
        case .academic:
            return .blue
        case .work:
            return .orange
        case .health:
            return .red
        case .finance:
            return .green
        case .social:
            return .pink
        case .creative:
            return .yellow
        }
    }
    
    var iconName: String {
        switch self {
        case .personal:
            return "person.fill"
        case .academic:
            return "graduationcap.fill"
        case .work:
            return "briefcase.fill"
        case .health:
            return "heart.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .social:
            return "person.2.fill"
        case .creative:
            return "paintbrush.fill"
        }
    }
}

// MARK: - Subtask Model
struct Subtask: Identifiable, Codable {
    let id: String
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    
    // Custom initializer
    init(title: String) {
        self.id = UUID().uuidString
        self.title = title
    }
}

// MARK: - Pomodoro Statistics
struct PomodoroStats: Codable {
    var date: Date
    var completedPomodoros: Int
    var totalFocusTime: Int // in minutes
    var sessionTypeCounts: [String: Int] // Using String keys instead of enum for Codable
    var tasksWorkedOn: [String] // task IDs
    var averageSessionLength: Double
    var distractions: Int
    
    init(date: Date = Date()) {
        self.date = date
        self.completedPomodoros = 0
        self.totalFocusTime = 0
        self.sessionTypeCounts = [:]
        self.tasksWorkedOn = []
        self.averageSessionLength = 0
        self.distractions = 0
    }
    
    // Helper methods to work with session types
    mutating func incrementSessionType(_ sessionType: PomodoroSession) {
        let key = sessionType.rawValue
        sessionTypeCounts[key, default: 0] += 1
    }
    
    func getSessionTypeCount(_ sessionType: PomodoroSession) -> Int {
        return sessionTypeCounts[sessionType.rawValue] ?? 0
    }
}

// MARK: - Productivity Settings
struct ProductivitySettings: Codable {
    var workDuration: Int = 25 // minutes
    var shortBreakDuration: Int = 5 // minutes
    var longBreakDuration: Int = 15 // minutes
    var longBreakInterval: Int = 4 // after how many work sessions
    var enableNotifications: Bool = true
    var enableSounds: Bool = true
    var autoStartBreaks: Bool = false
    var autoStartWork: Bool = false
    var dailyGoal: Int = 8 // pomodoros per day
    var weeklyGoal: Int = 40 // pomodoros per week
    var enableFocusMode: Bool = false // blocks distracting apps
    var preferredWorkStartHour: Int = 9 // hour only for simplicity
    var preferredWorkEndHour: Int = 17 // hour only for simplicity
    
    // Computed properties for Date objects (not stored)
    var preferredWorkStartTime: Date {
        return Calendar.current.date(from: DateComponents(hour: preferredWorkStartHour, minute: 0)) ?? Date()
    }
    
    var preferredWorkEndTime: Date {
        return Calendar.current.date(from: DateComponents(hour: preferredWorkEndHour, minute: 0)) ?? Date()
    }
}

// MARK: - AI Insight Model for Productivity
struct ProductivityInsight: Codable {
    let title: String
    let message: String
    let suggestion: String
    let type: InsightType
    let priority: InsightPriority
    let actionable: Bool
    let createdAt: Date
    
    enum InsightType: String, Codable {
        case productivity, timeManagement, focus, motivation, health
        
        var iconName: String {
            switch self {
            case .productivity:
                return "chart.line.uptrend.xyaxis"
            case .timeManagement:
                return "clock.fill"
            case .focus:
                return "eye.fill"
            case .motivation:
                return "flame.fill"
            case .health:
                return "heart.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .productivity:
                return .blue
            case .timeManagement:
                return .orange
            case .focus:
                return .purple
            case .motivation:
                return .red
            case .health:
                return .green
            }
        }
    }
    
    enum InsightPriority: String, Codable {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low:
                return .gray
            case .medium:
                return .blue
            case .high:
                return .red
            }
        }
    }
}

// MARK: - Focus Session Model
struct FocusSession: Identifiable, Codable {
    let id: String
    var taskId: String?
    var sessionType: PomodoroSession
    var plannedDuration: Int // minutes
    var actualDuration: Int? // minutes
    var startTime: Date
    var endTime: Date?
    var wasCompleted: Bool = false
    var distractions: Int = 0
    var notes: String?
    var productivity: Int? // 1-5 rating
    
    var isActive: Bool {
        return endTime == nil
    }
    
    var duration: Int {
        guard let endTime = endTime else {
            return Int(Date().timeIntervalSince(startTime) / 60)
        }
        return Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    // Custom initializer
    init(taskId: String? = nil, sessionType: PomodoroSession, plannedDuration: Int, startTime: Date) {
        self.id = UUID().uuidString
        self.taskId = taskId
        self.sessionType = sessionType
        self.plannedDuration = plannedDuration
        self.startTime = startTime
    }
}

// MARK: - Weekly Productivity Summary
struct WeeklyProductivitySummary {
    let weekStart: Date
    let weekEnd: Date
    let totalPomodoros: Int
    let totalFocusTime: Int // minutes
    let completedTasks: Int
    let averageProductivity: Double // 1-5 rating
    let topCategory: TaskCategory?
    let longestStreak: Int // consecutive days with pomodoros
    let goalAchievement: Double // percentage of weekly goal achieved
    let insights: [ProductivityInsight]
}


