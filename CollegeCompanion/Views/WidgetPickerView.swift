import SwiftUI

struct WidgetPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var widgetManager = WidgetManager.shared
    @State private var selectedWidgets: Set<String> = []
    var onDismiss: () -> Void
    
    // Available widget types
    private let availableWidgetTypes = [
        WidgetType(id: "tasks", title: "Tasks", description: "Track your assignments and to-dos", iconName: "checklist", color: AppTheme.Colors.productivity),
        WidgetType(id: "classes", title: "Classes", description: "See your daily class schedule", iconName: "book.fill", color: AppTheme.Colors.classes),
        WidgetType(id: "finance", title: "Finance", description: "Track your spending and budget", iconName: "dollarsign.circle.fill", color: AppTheme.Colors.finance),
        WidgetType(id: "wellness", title: "Wellness", description: "Monitor sleep, meals, and exercise", iconName: "heart.fill", color: AppTheme.Colors.wellness),
        WidgetType(id: "study_time", title: "Study Time", description: "Track study hours by subject", iconName: "clock.fill", color: .orange),
        WidgetType(id: "calendar", title: "Calendar", description: "View upcoming events and deadlines", iconName: "calendar", color: .red),
        WidgetType(id: "notes", title: "Quick Notes", description: "Access your recent notes", iconName: "note.text", color: .yellow),
        WidgetType(id: "grades", title: "Grades", description: "Monitor your current grades", iconName: "chart.bar.fill", color: .teal)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header section with info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Customize Your Dashboard")
                        .font(.headline)
                    
                    Text("Select widgets to add to your homescreen")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("Currently active: \(widgetManager.activeWidgets.count)")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppTheme.Colors.background)
                
                Divider()
                
                // Widget grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(availableWidgetTypes) { widgetType in
                            widgetTypeCard(for: widgetType)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Bottom action buttons
                HStack {
                    Button(action: {
                        dismiss()
                        onDismiss()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        addSelectedWidgets()
                        dismiss()
                        onDismiss()
                    }) {
                        Text("Add Selected")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedWidgets.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Add Widgets")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize with current active widgets
                selectedWidgets = Set(widgetManager.activeWidgets.map { $0.id })
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func widgetTypeCard(for widgetType: WidgetType) -> some View {
        let isSelected = selectedWidgets.contains(widgetType.id)
        let isActive = widgetManager.activeWidgets.contains(where: { $0.id == widgetType.id })
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: widgetType.iconName)
                    .font(.title3)
                    .foregroundColor(widgetType.color)
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                if isActive && !isSelected {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Text(widgetType.title)
                .font(.headline)
            
            Text(widgetType.description)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: {
                toggleWidgetSelection(widgetType.id)
            }) {
                Text(isSelected ? "Selected" : "Select")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? widgetType.color : Color.gray.opacity(0.2))
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(height: 160)
        .background(AppTheme.Colors.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? widgetType.color : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            toggleWidgetSelection(widgetType.id)
        }
    }
    
    // MARK: - Helper Functions
    
    private func toggleWidgetSelection(_ widgetId: String) {
        if selectedWidgets.contains(widgetId) {
            selectedWidgets.remove(widgetId)
        } else {
            selectedWidgets.insert(widgetId)
        }
    }
    
    private func addSelectedWidgets() {
        // Create widgets for each selected type that is not already active
        for widgetType in availableWidgetTypes {
            let isSelected = selectedWidgets.contains(widgetType.id)
            let isAlreadyActive = widgetManager.activeWidgets.contains(where: { $0.id == widgetType.id })
            
            // If selected and not already active, add it
            if isSelected && !isAlreadyActive {
                addWidget(for: widgetType)
            }
            // If not selected but active, remove it
            else if !isSelected && isAlreadyActive {
                widgetManager.removeWidget(withID: widgetType.id)
            }
        }
    }
    
    private func addWidget(for widgetType: WidgetType) {
        // Create different widget content based on type
        var content: AnyView
        var actionLabel = "View"
        
        switch widgetType.id {
        case "tasks":
            content = AnyView(TasksWidgetContent(tasks: []))
            actionLabel = "View all"
        case "classes":
            content = AnyView(ClassesWidgetContent(classes: []))
            actionLabel = "Full schedule"
        case "finance":
            content = AnyView(FinanceWidgetContent(transactions: []))
            actionLabel = "View details"
        case "wellness":
            content = AnyView(WellnessWidgetContent(wellnessLog: createEmptyWellnessLog()))
            actionLabel = "Health center"
        case "study_time":
            content = AnyView(Text("Study Time Widget").font(.caption))
            actionLabel = "View stats"
        case "calendar":
            content = AnyView(Text("Calendar Widget").font(.caption))
            actionLabel = "View calendar"
        case "notes":
            content = AnyView(Text("Notes Widget").font(.caption))
            actionLabel = "All notes"
        case "grades":
            content = AnyView(Text("Grades Widget").font(.caption))
            actionLabel = "View grades"
        default:
            content = AnyView(Text("Widget Content").font(.caption))
        }
        
        // Create the widget and add it
        let widget = WidgetModel(
            id: widgetType.id,
            title: widgetType.title,
            subtitle: widgetType.description,
            iconName: widgetType.iconName,
            content: content,
            actionLabel: actionLabel,
            accentColor: widgetType.color
        )
        
        widgetManager.addWidget(widget)
    }
    
    private func createEmptyWellnessLog() -> WellnessLog {
        return WellnessLog(
            date: Date(),
            sleepHours: nil,
            stressLevel: nil,
            mood: nil,
            mealLogs: [],
            waterIntake: nil,
            exerciseMinutes: nil
        )
    }
}

// MARK: - Supporting Models

struct WidgetType: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

// MARK: - Preview
struct WidgetPickerView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetPickerView(onDismiss: {})
    }
}
