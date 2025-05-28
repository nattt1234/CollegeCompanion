import SwiftUI

struct ProductivityCoachScreen: View {
    @StateObject private var viewModel = ProductivityCoachViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom tab selector
                customTabSelector
                
                // Tab content
                TabView(selection: $selectedTab) {
                    // Pomodoro Timer Tab
                    PomodoroTimerView()
                        .environmentObject(viewModel)
                        .tag(0)
                    
                    // Task Management Tab
                    TaskManagementView()
                        .environmentObject(viewModel)
                        .tag(1)
                    
                    // AI Coach Tab
                    AICoachView()
                        .environmentObject(viewModel)
                        .tag(2)
                    
                    // Analytics Tab
                    ProductivityAnalyticsView()
                        .environmentObject(viewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Productivity Coach")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    private var customTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProductivityTab.allCases.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    HapticFeedback.selection()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: ProductivityTab.allCases[index].iconName)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(ProductivityTab.allCases[index].title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == index ? AppTheme.Colors.productivity : AppTheme.Colors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .background(AppTheme.Colors.secondaryBackground)
        .overlay(
            // Selection indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.Colors.productivity)
                .frame(height: 3)
                .offset(x: CGFloat(selectedTab) * (UIScreen.main.bounds.width / 4) - UIScreen.main.bounds.width * 3/8)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab),
            alignment: .bottom
        )
    }
}

// MARK: - Productivity Tab Enum
enum ProductivityTab: CaseIterable {
    case timer, tasks, coach, analytics
    
    var title: String {
        switch self {
        case .timer: return "Timer"
        case .tasks: return "Tasks"
        case .coach: return "Coach"
        case .analytics: return "Stats"
        }
    }
    
    var iconName: String {
        switch self {
        case .timer: return "timer"
        case .tasks: return "checklist"
        case .coach: return "brain.head.profile"
        case .analytics: return "chart.bar.fill"
        }
    }
}

// MARK: - Pomodoro Timer View
struct PomodoroTimerView: View {
    @EnvironmentObject private var viewModel: ProductivityCoachViewModel
    @State private var isTimerRunning = false
    @State private var timeRemaining: TimeInterval = 25 * 60 // 25 minutes default
    @State private var timer: Timer?
    @State private var currentSession: PomodoroSession = .work
    @State private var completedPomodoros = 0
    @State private var isResetting = false
    
    // Duration picker states
    @State private var showingWorkDurationPicker = false
    @State private var showingShortBreakPicker = false
    @State private var showingLongBreakPicker = false
    @State private var tempWorkDuration = 25
    @State private var tempShortBreakDuration = 5
    @State private var tempLongBreakDuration = 15
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Timer Circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(AppTheme.Colors.productivity.opacity(0.2), lineWidth: 12)
                        .frame(width: 280, height: 280)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [currentSession.color, currentSession.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    // Timer content
                    VStack(spacing: 8) {
                        Text(currentSession.rawValue.capitalized)
                            .font(.headline)
                            .foregroundColor(currentSession.color)
                        
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 48, weight: .thin, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Session \(completedPomodoros + 1)")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                .onTapGesture {
                    toggleTimer()
                }
                
                // Control buttons
                HStack(spacing: 20) {
                    Button(action: resetCurrentTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.Colors.secondaryBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: toggleTimer) {
                        Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .background(currentSession.color)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(BounceButtonStyle())
                    .disabled(isResetting)
                    
                    Button(action: skipSession) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.Colors.secondaryBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                // Reset Session Button
                Button(action: resetAllSessions) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline)
                        
                        Text("Reset All Sessions")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Session settings
                VStack(spacing: 16) {
                    Text("Session Settings")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        SettingRow(
                            title: "Work Duration",
                            value: "\(viewModel.workDuration) min",
                            action: {
                                tempWorkDuration = viewModel.workDuration
                                showingWorkDurationPicker = true
                            }
                        )
                        
                        SettingRow(
                            title: "Short Break",
                            value: "\(viewModel.shortBreakDuration) min",
                            action: {
                                tempShortBreakDuration = viewModel.shortBreakDuration
                                showingShortBreakPicker = true
                            }
                        )
                        
                        SettingRow(
                            title: "Long Break",
                            value: "\(viewModel.longBreakDuration) min",
                            action: {
                                tempLongBreakDuration = viewModel.longBreakDuration
                                showingLongBreakPicker = true
                            }
                        )
                    }
                }
                
                // Today's progress
                todaysProgressView
            }
            .padding()
        }
        .onAppear {
            setupInitialState()
        }
        .onDisappear {
            cleanupTimer()
        }
        // Duration picker sheets
        .sheet(isPresented: $showingWorkDurationPicker) {
            DurationPickerView(
                title: "Work Duration",
                selectedDuration: $tempWorkDuration,
                range: 5...60,
                onSave: {
                    var newSettings = viewModel.settings
                    newSettings.workDuration = tempWorkDuration
                    viewModel.updateSettings(newSettings)
                    
                    // Update current timer if it's a work session and not running
                    if currentSession == .work && !isTimerRunning {
                        timeRemaining = Double(tempWorkDuration * 60)
                    }
                }
            )
        }
        .sheet(isPresented: $showingShortBreakPicker) {
            DurationPickerView(
                title: "Short Break Duration",
                selectedDuration: $tempShortBreakDuration,
                range: 1...30,
                onSave: {
                    var newSettings = viewModel.settings
                    newSettings.shortBreakDuration = tempShortBreakDuration
                    viewModel.updateSettings(newSettings)
                    
                    // Update current timer if it's a short break session and not running
                    if currentSession == .shortBreak && !isTimerRunning {
                        timeRemaining = Double(tempShortBreakDuration * 60)
                    }
                }
            )
        }
        .sheet(isPresented: $showingLongBreakPicker) {
            DurationPickerView(
                title: "Long Break Duration",
                selectedDuration: $tempLongBreakDuration,
                range: 5...60,
                onSave: {
                    var newSettings = viewModel.settings
                    newSettings.longBreakDuration = tempLongBreakDuration
                    viewModel.updateSettings(newSettings)
                    
                    // Update current timer if it's a long break session and not running
                    if currentSession == .longBreak && !isTimerRunning {
                        timeRemaining = Double(tempLongBreakDuration * 60)
                    }
                }
            )
        }
    }
    
    private var progress: CGFloat {
        let totalTime = currentSession == .work ? Double(viewModel.workDuration * 60) :
                       currentSession == .shortBreak ? Double(viewModel.shortBreakDuration * 60) :
                       Double(viewModel.longBreakDuration * 60)
        return totalTime > 0 ? 1 - (timeRemaining / totalTime) : 0
    }
    
    private var todaysProgressView: some View {
        VStack(spacing: 16) {
            Text("Today's Progress")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Completed Pomodoros")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("\(completedPomodoros)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Focus Time")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("\(completedPomodoros * viewModel.workDuration) min")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Timer Functions (Fixed)
    
    private func setupInitialState() {
        timeRemaining = Double(viewModel.workDuration * 60)
        currentSession = .work
        completedPomodoros = viewModel.todaysCompletedPomodoros
    }
    
    private func toggleTimer() {
        // Prevent rapid tapping issues
        guard !isResetting else { return }
        
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        // Make sure any existing timer is invalidated first
        cleanupTimer()
        
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.completeSession()
                }
            }
        }
        
        HapticFeedback.medium()
    }
    
    private func pauseTimer() {
        cleanupTimer()
        isTimerRunning = false
        HapticFeedback.light()
    }
    
    private func cleanupTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetCurrentTimer() {
        cleanupTimer()
        isTimerRunning = false
        isResetting = true
        
        // Reset to current session duration
        timeRemaining = Double(getCurrentSessionDuration() * 60)
        
        // Small delay to prevent rapid resets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isResetting = false
        }
        
        HapticFeedback.medium()
    }
    
    private func resetAllSessions() {
        cleanupTimer()
        isTimerRunning = false
        isResetting = true
        
        // Reset everything to initial state
        currentSession = .work
        completedPomodoros = 0
        timeRemaining = Double(viewModel.workDuration * 60)
        
        // Small delay to prevent issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isResetting = false
        }
        
        HapticFeedback.success()
    }
    
    private func skipSession() {
        completeSession()
        HapticFeedback.medium()
    }
    
    private func completeSession() {
        cleanupTimer()
        isTimerRunning = false
        
        if currentSession == .work {
            completedPomodoros += 1
            // Update view model
            viewModel.incrementTodaysPomodoros()
            
            // Determine next session type
            if completedPomodoros % 4 == 0 {
                currentSession = .longBreak
                timeRemaining = Double(viewModel.longBreakDuration * 60)
            } else {
                currentSession = .shortBreak
                timeRemaining = Double(viewModel.shortBreakDuration * 60)
            }
        } else {
            currentSession = .work
            timeRemaining = Double(viewModel.workDuration * 60)
        }
        
        HapticFeedback.success()
        
        // Optional: Auto-start next session after a short delay
        if viewModel.settings.autoStartBreaks || viewModel.settings.autoStartWork {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !isResetting {
                    startTimer()
                }
            }
        }
    }
    
    private func getCurrentSessionDuration() -> Int {
        switch currentSession {
        case .work:
            return viewModel.workDuration
        case .shortBreak:
            return viewModel.shortBreakDuration
        case .longBreak:
            return viewModel.longBreakDuration
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Supporting Views
struct SettingRow: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.productivity)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(8)
    }
}

// MARK: - Duration Picker View
struct DurationPickerView: View {
    let title: String
    @Binding var selectedDuration: Int
    let range: ClosedRange<Int>
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var tempDuration: Int
    
    init(title: String, selectedDuration: Binding<Int>, range: ClosedRange<Int>, onSave: @escaping () -> Void) {
        self.title = title
        self._selectedDuration = selectedDuration
        self.range = range
        self.onSave = onSave
        self._tempDuration = State(initialValue: selectedDuration.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Select Duration")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    // Large display showing selected time
                    Text("\(tempDuration)")
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .foregroundColor(AppTheme.Colors.productivity)
                    
                    Text("minutes")
                        .font(.title2)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding(.top, 32)
                
                // Picker
                Picker("Duration", selection: $tempDuration) {
                    ForEach(range, id: \.self) { duration in
                        Text("\(duration) min")
                            .tag(duration)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                
                // Preset buttons for common durations
                if title.contains("Work") {
                    presetButtons(presets: [15, 25, 30, 45, 50])
                } else if title.contains("Short") {
                    presetButtons(presets: [3, 5, 10, 15])
                } else {
                    presetButtons(presets: [10, 15, 20, 30])
                }
                
                Spacer()
                
                // Save/Cancel buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                    
                    Button("Save") {
                        selectedDuration = tempDuration
                        onSave()
                        dismiss()
                        HapticFeedback.success()
                    }
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.productivity)
                    .cornerRadius(12)
                }
                .padding(.bottom, 32)
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedDuration = tempDuration
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func presetButtons(presets: [Int]) -> some View {
        VStack(spacing: 12) {
            Text("Quick Select")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: presets.count > 4 ? 3 : 2), spacing: 12) {
                ForEach(presets, id: \.self) { preset in
                    Button(action: {
                        tempDuration = preset
                        HapticFeedback.selection()
                    }) {
                        Text("\(preset)")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(tempDuration == preset ? .white : AppTheme.Colors.productivity)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(tempDuration == preset ? AppTheme.Colors.productivity : AppTheme.Colors.productivity.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}
struct TaskManagementView: View {
    @EnvironmentObject private var viewModel: ProductivityCoachViewModel
    
    var body: some View {
        Text("Task Management View - Coming Next!")
            .font(.headline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AICoachView: View {
    @EnvironmentObject private var viewModel: ProductivityCoachViewModel
    
    var body: some View {
        Text("AI Coach View - Coming Soon!")
            .font(.headline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProductivityAnalyticsView: View {
    @EnvironmentObject private var viewModel: ProductivityCoachViewModel
    
    var body: some View {
        Text("Analytics View - Coming Soon!")
            .font(.headline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ProductivityCoachScreen()
}


