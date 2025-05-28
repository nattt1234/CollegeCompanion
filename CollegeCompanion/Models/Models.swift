import SwiftUI

// MARK: - Widget Model
struct WidgetModel: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let content: AnyView
    let actionLabel: String
    let accentColor: Color
    let hasNotification: Bool
    let notificationCount: Int
    var order: Int = 0
    
    init(
        id: String,
        title: String,
        subtitle: String,
        iconName: String,
        content: AnyView,
        actionLabel: String = "",
        accentColor: Color = AppTheme.Colors.primary,
        hasNotification: Bool = false,
        notificationCount: Int = 0,
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.content = content
        self.actionLabel = actionLabel
        self.accentColor = accentColor
        self.hasNotification = hasNotification
        self.notificationCount = notificationCount
        self.order = order
    }
}

// MARK: - Quick Action Model
struct QuickAction: Identifiable {
    let id = UUID().uuidString
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    init(title: String, iconName: String, color: Color, action: @escaping () -> Void = {}) {
        self.title = title
        self.iconName = iconName
        self.color = color
        self.action = action
    }
}

// MARK: - AI Insight Model
struct AIInsight {
    let message: String
    let suggestion: String
}

// MARK: - Task Model (for Tasks Widget)
struct Task: Identifiable {
    let id = UUID().uuidString
    var title: String
    var isCompleted: Bool = false
    var dueDate: Date?
    var priority: TaskPriority = .medium
    var course: String?
    
    enum TaskPriority: Int, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var color: Color {
            switch self {
            case .low:
                return .green
            case .medium:
                return .orange
            case .high:
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
            }
        }
    }
}

// MARK: - Class Model
struct Course: Identifiable {
    let id = UUID().uuidString
    var name: String
    var code: String
    var color: Color
    var professor: String
    var location: String
    var startTime: Date
    var endTime: Date
    var daysOfWeek: [Int] // 1 = Sunday, 2 = Monday, etc.
}

// MARK: - Finance Transaction Model
struct Transaction: Identifiable {
    let id = UUID().uuidString
    var amount: Double
    var title: String
    var category: TransactionCategory
    var date: Date
    var isIncome: Bool
    
    enum TransactionCategory: String, CaseIterable {
        case food = "Food"
        case groceries = "Groceries"
        case transport = "Transport"
        case entertainment = "Entertainment"
        case education = "Education"
        case utilities = "Utilities"
        case housing = "Housing"
        case health = "Health"
        case clothing = "Clothing"
        case other = "Other"
        case income = "Income"
        
        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .groceries: return "cart"
            case .transport: return "bus"
            case .entertainment: return "film"
            case .education: return "book"
            case .utilities: return "bolt"
            case .housing: return "house"
            case .health: return "heart"
            case .clothing: return "tshirt"
            case .other: return "ellipsis"
            case .income: return "dollarsign"
            }
        }
        
        var color: Color {
            switch self {
            case .food: return .orange
            case .groceries: return .green
            case .transport: return .blue
            case .entertainment: return .purple
            case .education: return .cyan
            case .utilities: return .yellow
            case .housing: return .brown
            case .health: return .red
            case .clothing: return .pink
            case .other: return .gray
            case .income: return .green
            }
        }
    }
}

// MARK: - Wellness Log Model
struct WellnessLog: Identifiable {
    let id = UUID().uuidString
    var date: Date
    var sleepHours: Double?
    var stressLevel: Int? // 1-5
    var mood: Mood?
    var mealLogs: [MealLog]
    var waterIntake: Int? // in oz
    var exerciseMinutes: Int?
    
    enum Mood: String, CaseIterable {
        case great = "Great"
        case good = "Good"
        case okay = "Okay"
        case poor = "Poor"
        case bad = "Bad"
        
        var icon: String {
            switch self {
            case .great: return "face.smiling"
            case .good: return "face.smiling"
            case .okay: return "face.smiling"
            case .poor: return "face.clouded"
            case .bad: return "face.frowning"
            }
        }
    }
}

// MARK: - Meal Log Model
struct MealLog: Identifiable {
    let id = UUID().uuidString
    var mealType: MealType
    var description: String
    var time: Date
    var rating: Int? // 1-5
    
    enum MealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
}
