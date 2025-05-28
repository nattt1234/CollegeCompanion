import SwiftUI

// MARK: - Tasks Widget Content
struct TasksWidgetContent: View {
    let tasks: [Task]
    @State private var animateCheckboxes = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if tasks.isEmpty {
                Text("No tasks for today")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(Array(tasks.prefix(3).enumerated()), id: \.element.id) { index, task in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(task.priority.color)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animateCheckboxes ? 1.0 : 0.5)
                            .opacity(animateCheckboxes ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.6)
                                .delay(Double(index) * 0.1),
                                value: animateCheckboxes
                            )
                        
                        Text(task.title)
                            .font(.caption)
                            .lineLimit(1)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? AppTheme.Colors.tertiaryText : AppTheme.Colors.primaryText)
                        
                        Spacer()
                        
                        if let dueDate = task.dueDate {
                            Text(dueFormatter.string(from: dueDate))
                                .font(.caption2)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .opacity(animateCheckboxes ? 1.0 : 0.0)
                                .animation(
                                    .spring(response: 0.3, dampingFraction: 0.6)
                                    .delay(0.3 + Double(index) * 0.05),
                                    value: animateCheckboxes
                                )
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                if tasks.count > 3 {
                    Text("+ \(tasks.count - 3) more")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(.top, 2)
                        .opacity(animateCheckboxes ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.6)
                            .delay(0.4),
                            value: animateCheckboxes
                        )
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateCheckboxes = true
            }
        }
    }
    
    private var dueFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter
    }
}

// MARK: - Classes Widget Content
struct ClassesWidgetContent: View {
    let classes: [Course]
    @State private var animateClasses = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if classes.isEmpty {
                Text("No classes scheduled for today")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(Array(classes.prefix(2).enumerated()), id: \.element.id) { index, course in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(course.color)
                            .frame(width: 4, height: 24)
                            .scaleEffect(x: 1, y: animateClasses ? 1 : 0.3, anchor: .center)
                            .opacity(animateClasses ? 1 : 0.3)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.15),
                                value: animateClasses
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(course.name)
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .lineLimit(1)
                            
                            Text("\(timeFormatter.string(from: course.startTime)) - \(timeFormatter.string(from: course.endTime))")
                                .font(.caption2)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                        .opacity(animateClasses ? 1 : 0)
                        .offset(x: animateClasses ? 0 : -10)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(0.1 + Double(index) * 0.15),
                            value: animateClasses
                        )
                        
                        Spacer()
                        
                        Text(course.location.components(separatedBy: ",").first ?? "")
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .opacity(animateClasses ? 1 : 0)
                            .offset(x: animateClasses ? 0 : 10)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(0.2 + Double(index) * 0.15),
                                value: animateClasses
                            )
                    }
                    .padding(.vertical, 2)
                }
                
                if classes.count > 2 {
                    Text("+ \(classes.count - 2) more classes today")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(.top, 2)
                        .opacity(animateClasses ? 1 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(0.4),
                            value: animateClasses
                        )
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateClasses = true
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

// MARK: - Finance Widget Content
struct FinanceWidgetContent: View {
    let transactions: [Transaction]
    @State private var animateProgress = false
    @State private var animateTransactions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Budget summary
            HStack {
                VStack(alignment: .leading) {
                    Text("This Week")
                        .font(.caption2)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("$\(weeklySpending, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .opacity(animateTransactions ? 1 : 0)
                .offset(y: animateTransactions ? 0 : 10)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7),
                    value: animateTransactions
                )
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Monthly Budget")
                        .font(.caption2)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("$\(spendingPercentage, specifier: "%.0f")%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(spendingPercentage > 80 ? .red : .green)
                }
                .opacity(animateTransactions ? 1 : 0)
                .offset(y: animateTransactions ? 0 : 10)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                    .delay(0.1),
                    value: animateTransactions
                )
            }
            .padding(.bottom, 4)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(spendingPercentage > 80 ? Color.red : Color.green)
                        .frame(width: animateProgress ? min(CGFloat(spendingPercentage) / 100.0 * geometry.size.width, geometry.size.width) : 0, height: 4)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.7)
                            .delay(0.3),
                            value: animateProgress
                        )
                }
            }
            .frame(height: 4)
            .padding(.bottom, 8)
            
            // Recent transactions
            if transactions.isEmpty {
                Text("No recent transactions")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .opacity(animateTransactions ? 1 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(0.4),
                        value: animateTransactions
                    )
            } else {
                Text("Recent Transactions")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(.bottom, 2)
                    .opacity(animateTransactions ? 1 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(0.4),
                        value: animateTransactions
                    )
                
                ForEach(Array(transactions.prefix(2).enumerated()), id: \.element.id) { index, transaction in
                    HStack {
                        Image(systemName: transaction.category.icon)
                            .font(.caption)
                            .foregroundColor(transaction.category.color)
                            .frame(width: 20, height: 20)
                            .background(transaction.category.color.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text(transaction.title)
                            .font(.caption)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(transaction.isIncome ? "+$\(transaction.amount, specifier: "%.2f")" : "-$\(transaction.amount, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(transaction.isIncome ? .green : .primary)
                    }
                    .padding(.vertical, 2)
                    .opacity(animateTransactions ? 1 : 0)
                    .offset(x: animateTransactions ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(0.5 + Double(index) * 0.1),
                        value: animateTransactions
                    )
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateTransactions = true
                animateProgress = true
            }
        }
    }
    
    // Calculated properties for demo
    private var weeklySpending: Double {
        let expenses = transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        return expenses
    }
    
    private var spendingPercentage: Double {
        // Mock monthly budget of $1000
        let monthlyBudget = 1000.0
        return (weeklySpending / monthlyBudget) * 100
    }
}

// MARK: - Wellness Widget Content
struct WellnessWidgetContent: View {
    let wellnessLog: WellnessLog
    @State private var animateContent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Mood indicator
            HStack {
                if let mood = wellnessLog.mood {
                    Image(systemName: mood.icon)
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(mood.rawValue)
                        .font(.caption)
                }
                
                Spacer()
                
                if let stressLevel = wellnessLog.stressLevel {
                    Text("Stress: \(stressLevel)/5")
                        .font(.caption)
                        .foregroundColor(stressLevel > 3 ? .orange : .green)
                }
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 10)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.7),
                value: animateContent
            )
            
            // Sleep and water
            HStack {
                if let sleepHours = wellnessLog.sleepHours {
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("\(sleepHours, specifier: "%.1f") hrs")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                if let waterIntake = wellnessLog.waterIntake {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("\(waterIntake) oz")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                if let exerciseMinutes = wellnessLog.exerciseMinutes {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("\(exerciseMinutes) min")
                            .font(.caption)
                    }
                }
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 5)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.7)
                .delay(0.1),
                value: animateContent
            )
            
            Divider()
                .opacity(animateContent ? 1 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                    .delay(0.2),
                    value: animateContent
                )
            
            // Meals today
            Text("Meals Today")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .opacity(animateContent ? 1 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                    .delay(0.3),
                    value: animateContent
                )
            
            if wellnessLog.mealLogs.isEmpty {
                Text("No meals logged yet")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.tertiaryText)
                    .padding(.top, 2)
                    .opacity(animateContent ? 1 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(0.4),
                        value: animateContent
                    )
            } else {
                ForEach(Array(wellnessLog.mealLogs.prefix(2).enumerated()), id: \.element.id) { index, meal in
                    HStack {
                        Text(meal.mealType.rawValue)
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.primaryText)
                        
                        Spacer()
                        
                        Text(timeFormatter.string(from: meal.time))
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        
                        if let rating = meal.rating {
                            ForEach(1...rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 5)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(0.4 + Double(index) * 0.1),
                        value: animateContent
                    )
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animateContent = true
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}
