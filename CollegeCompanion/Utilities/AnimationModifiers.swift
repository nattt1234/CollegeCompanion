import SwiftUI

// MARK: - Animation Extensions

extension Animation {
    static var smoothAppear: Animation {
        .spring(response: 0.4, dampingFraction: 0.7)
    }
    
    static var quickDisappear: Animation {
        .easeOut(duration: 0.2)
    }
    
    static var gentleBounce: Animation {
        .interpolatingSpring(mass: 1.0, stiffness: 100, damping: 10, initialVelocity: 0)
    }
}

// MARK: - Animation Effect Modifiers

struct StaggeredAppearEffect: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct WidgetAnimationEffect: ViewModifier {
    @State private var isVisible = false
    let index: Int
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                    isVisible = true
                }
            }
    }
}

struct CardPressEffect: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
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

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(shimmerOverlay)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
    
    private var shimmerOverlay: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .white.opacity(0.2), location: 0.3),
                .init(color: .white.opacity(0.3), location: 0.5),
                .init(color: .white.opacity(0.2), location: 0.7),
                .init(color: .clear, location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .offset(x: -200 + phase * 1000)
        .blendMode(.screen)
    }
}

struct PulsingEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0 : 0.3)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - View Extensions for Animations

extension View {
    func staggeredAppearIfNeeded(delay: Double = 0) -> some View {
        self.modifier(StaggeredAppearEffect(delay: delay))
    }
    
    func widgetAppearIfNeeded(index: Int) -> some View {
        self.modifier(WidgetAnimationEffect(index: index))
    }
    
    func cardPressAnimationIfNeeded() -> some View {
        self.modifier(CardPressEffect())
    }
    
    func shimmerLoadingIfNeeded() -> some View {
        self.modifier(ShimmerEffect())
    }
    
    func pulseEffectIfNeeded() -> some View {
        self.modifier(PulsingEffect())
    }
}


