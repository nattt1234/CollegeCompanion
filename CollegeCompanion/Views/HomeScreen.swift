import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @ObservedObject private var widgetManager = WidgetManager.shared
    @State private var showingSettings = false
    @State private var showingWidgetPicker = false
    
    // Layout grid configuration with MORE SPACING between columns
    private let columns = [
        GridItem(.flexible(), spacing: 20), // Increased column spacing
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // Increased overall spacing
                    // AI greeting and recommendation
                    AIDailyInsightView(insight: viewModel.dailyInsight)
                        .onTapGesture {
                            viewModel.refreshInsight()
                        }
                        .staggeredAppearIfNeeded()
                    
                    // Widgets grid
                    if widgetManager.activeWidgets.isEmpty {
                        emptyWidgetsView
                            .staggeredAppearIfNeeded(delay: 0.2)
                    } else {
                        widgetsGridView
                    }
                    
                    // Quick actions
                    QuickActionsView(actions: viewModel.quickActions)
                        .staggeredAppearIfNeeded(delay: 0.3)
                        .padding(.top, 10) // Extra padding before quick actions
                }
                .padding(.top, 16)
                .padding(.bottom, 24) // Add bottom padding
            }
            .refreshable {
                // Pull to refresh functionality
                viewModel.refreshAll()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(widgetManager.isEditMode ? "Done" : "Edit") {
                        widgetManager.toggleEditMode()
                        HapticFeedback.medium()
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                        HapticFeedback.light()
                    }) {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .onAppear {
                viewModel.loadUserData()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingWidgetPicker) {
                WidgetPickerView(onDismiss: {
                    showingWidgetPicker = false
                })
            }
        }
    }
    
    // MARK: - Supporting Views
    
    private var emptyWidgetsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.secondary.opacity(0.5))
                .padding()
                .symbolEffect(.pulse, options: .repeating, value: UUID())
            
            Text("No widgets added yet")
                .font(.headline)
                .staggeredAppearIfNeeded(delay: 0.1)
            
            Text("Add widgets to customize your dashboard")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .staggeredAppearIfNeeded(delay: 0.2)
            
            Button(action: {
                showingWidgetPicker = true
                HapticFeedback.medium()
            }) {
                Text("Add Widgets")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.top, 8)
            .staggeredAppearIfNeeded(delay: 0.3)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(AppTheme.Dimensions.spacing16)
        .background(AppTheme.Colors.background)
        .cornerRadius(AppTheme.Dimensions.radiusMedium)
        .shadow(
            color: AppTheme.ShadowStyle.small.color,
            radius: AppTheme.ShadowStyle.small.radius,
            x: AppTheme.ShadowStyle.small.x,
            y: AppTheme.ShadowStyle.small.y
        )
        .padding(.horizontal)
    }
    
    private var widgetsGridView: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20) { // Increased grid spacing
                ForEach(Array(widgetManager.activeWidgets.enumerated()), id: \.element.id) { index, widget in
                    ReorganizedWidgetView(widget: widget)
                        .opacity(widgetManager.isEditMode ? 0.8 : 1.0)
                        .overlay(
                            widgetManager.isEditMode ? widgetEditOverlay(for: widget) : nil
                        )
                        .onTapGesture {
                            if widgetManager.isEditMode {
                                // Handle edit mode taps
                            }
                        }
                        .widgetAppearIfNeeded(index: index)
                }
                
                // Add widget button (only visible in edit mode)
                if widgetManager.isEditMode {
                    addWidgetButton
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            
            if widgetManager.isEditMode {
                Text("Drag to reorder widgets. Tap × to remove.")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smoothAppear, value: widgetManager.isEditMode)
        .animation(.smoothAppear, value: widgetManager.activeWidgets.count)
    }
    
    private var addWidgetButton: some View {
        Button(action: {
            showingWidgetPicker = true
            HapticFeedback.medium()
        }) {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AppTheme.Colors.primary)
                    .symbolEffect(.bounce, options: .repeating, value: UUID())
                
                Text("Add Widget")
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .frame(height: AppTheme.Dimensions.widgetHeight + 50) // Match increased widget height
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .cornerRadius(AppTheme.Dimensions.radiusMedium)
        }
        .buttonStyle(CardButtonStyle())
        .widgetAppearIfNeeded(index: widgetManager.activeWidgets.count)
    }
    
    private func widgetEditOverlay(for widget: WidgetModel) -> some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .strokeBorder(AppTheme.Colors.primary, lineWidth: 2, antialiased: true)
                .cornerRadius(AppTheme.Dimensions.radiusMedium)
                .contentShape(Rectangle())
            
            Button(action: {
                withAnimation(.quickDisappear) {
                    HapticFeedback.medium()
                    widgetManager.removeWidget(withID: widget.id)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .offset(x: 12, y: -12)
            .transition(.scale.combined(with: .opacity))
        }
        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
    }
}

// MARK: - Supporting Views

struct AIDailyInsightView: View {
    let insight: AIInsight
    @State private var isExpanded = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primary)
                    .symbolEffect(.pulse, options: .repeating, value: isLoading)
                
                Text("Daily Insight")
                    .font(AppTheme.TextStyle.headline)
                
                Spacer()
                
                Button(action: {
                    isLoading = true
                    
                    // Simulate refresh with a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .symbolEffect(.bounce, value: isLoading)
                }
                .disabled(isLoading)
            }
            
            if isLoading {
                // Loading state
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .shimmerLoadingIfNeeded()
                    .padding(.leading, 4)
                    .padding(.top, 4)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .shimmerLoadingIfNeeded()
                    .padding(.leading, 4)
            } else {
                Text(insight.message)
                    .font(AppTheme.TextStyle.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(.leading, 4)
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    .lineLimit(isExpanded ? nil : 2)
                    .onTapGesture {
                        withAnimation(.smoothAppear) {
                            isExpanded.toggle()
                        }
                    }
            }
            
            if !insight.suggestion.isEmpty && !isLoading {
                Button(action: {
                    // Apply suggestion
                    HapticFeedback.light()
                }) {
                    HStack {
                        Text(insight.suggestion)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.leading, 4)
                .padding(.top, 4)
                .staggeredAppearIfNeeded(delay: 0.3)
            }
        }
        .padding(20)
        .padding(AppTheme.Dimensions.spacing16)
        .background(AppTheme.Colors.background)
        .cornerRadius(AppTheme.Dimensions.radiusMedium)
        .shadow(
            color: AppTheme.ShadowStyle.small.color,
            radius: AppTheme.ShadowStyle.small.radius,
            x: AppTheme.ShadowStyle.small.x,
            y: AppTheme.ShadowStyle.small.y
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}

// MARK: - Reorganized Widget View with title outside and action link at bottom
struct ReorganizedWidgetView: View {
    let widget: WidgetModel
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title above the card
            HStack {
                Image(systemName: widget.iconName)
                    .font(.title3)
                    .foregroundColor(widget.accentColor)
                
                Text(widget.title)
                    .font(.title3)
                    .foregroundColor(widget.accentColor)
                
                Spacer()
                
                if widget.hasNotification {
                    Text("\(widget.notificationCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.red)
                        .clipShape(Circle())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 4) // Add slight horizontal padding to title
            
            // Card content
            VStack(alignment: .leading, spacing: 12) {
                // Subtitle
                Text(widget.subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(.bottom, 4)
                
                // Widget content
                widget.content
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 100) // Ensure enough space for content
                
                Spacer(minLength: 8)
                
                // Action link at bottom
                if !widget.actionLabel.isEmpty {
                    Divider()
                        .padding(.vertical, 4)
                    
                    NavigationLink(destination: EmptyView()) {
                        HStack {
                            Text(widget.actionLabel)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(widget.accentColor)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(16) // Card content padding
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Dimensions.radiusMedium)
                    .fill(AppTheme.Colors.background)
                    .shadow(
                        color: isPressed ? widget.accentColor.opacity(0.1) : AppTheme.ShadowStyle.small.color,
                        radius: isPressed ? 2 : AppTheme.ShadowStyle.small.radius,
                        x: 0,
                        y: isPressed ? 1 : AppTheme.ShadowStyle.small.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Dimensions.radiusMedium)
                    .stroke(widget.accentColor.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                HapticFeedback.light()
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }
        }
    }
}

struct QuickActionsView: View {
    let actions: [QuickAction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
                .staggeredAppearIfNeeded()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { // Kept original spacing (12)
                    ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                        Button(action: {
                            HapticFeedback.medium()
                            action.action()
                        }) {
                            VStack(spacing: 8) { // Kept original spacing (8)
                                Image(systemName: action.iconName)
                                    .font(.headline)
                                    .foregroundColor(action.color)
                                    .frame(width: 42, height: 42) // Kept original size (42)
                                    .background(action.color.opacity(0.1))
                                    .cornerRadius(12) // Kept original radius (12)
                                
                                Text(action.title)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 80) // Kept original width (80)
                        }
                        .buttonStyle(BounceButtonStyle())
                        .staggeredAppearIfNeeded(delay: Double(index) * 0.1 + 0.2)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4) // Added slight vertical padding
            }
        }
    }
}

#Preview {
    HomeScreen()
}



