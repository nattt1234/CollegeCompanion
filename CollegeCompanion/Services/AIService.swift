import Foundation
import Combine

/// Service to handle AI-related functionality
class AIService {
    // Singleton instance
    static let shared = AIService()
    
    private init() {}
    
    /// Generate an AI insight based on user data
    /// - Parameter completion: Completion handler with the generated insight
    func generateDailyInsight(completion: @escaping (AIInsight) -> Void) {
        // In a real app, this would call an API like OpenAI
        // For now, we'll simulate a delay and return a mock insight
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let insight = self.generateMockInsight()
            
            DispatchQueue.main.async {
                completion(insight)
            }
        }
    }
    
    /// Generate insights for study recommendations
    /// - Parameter completion: Completion handler with the generated insights
    func generateStudyRecommendations(completion: @escaping ([String]) -> Void) {
        // Simulate API call
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let recommendations = [
                "Based on your past performance, you retain more information when studying in the morning.",
                "Your Economics assignment is due soon. Consider allocating 2 hours today.",
                "You've been studying Physics for 4 days straight. Consider taking a break or switching subjects.",
                "Your test results improve when you use practice quizzes. Try adding some for History."
            ]
            
            DispatchQueue.main.async {
                completion(recommendations)
            }
        }
    }
    
    /// Generate budget insights
    /// - Parameter completion: Completion handler with the generated insights
    func generateBudgetInsights(completion: @escaping ([String]) -> Void) {
        // Simulate API call
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let insights = [
                "You spent 20% more on food this week compared to your average.",
                "Setting aside $50 more per month could help you reach your laptop savings goal by December.",
                "Your current spending puts you on track to exceed your monthly budget by $75.",
                "You typically spend less on weekdays than weekends. Consider planning more weekend meals at home."
            ]
            
            DispatchQueue.main.async {
                completion(insights)
            }
        }
    }
    
    /// Generate wellness recommendations
    /// - Parameter completion: Completion handler with the generated recommendations
    func generateWellnessRecommendations(completion: @escaping ([String]) -> Void) {
        // Simulate API call
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let recommendations = [
                "Your sleep pattern has been irregular. Try to maintain a consistent sleep schedule.",
                "You've been reporting higher stress levels. Consider adding 10-minute meditation sessions.",
                "Your water intake has been below your target. Set reminders to drink water throughout the day.",
                "You've logged good exercise consistency. Keep it up!"
            ]
            
            DispatchQueue.main.async {
                completion(recommendations)
            }
        }
    }
    
    /// Generate a mock daily insight
    private func generateMockInsight() -> AIInsight {
        // Create array of possible insights
        let insights = [
            AIInsight(
                message: "You have 3 assignments due this week. Based on your schedule, today's a good day to work on your Economics paper.",
                suggestion: "Schedule 2-hour focus block"
            ),
            AIInsight(
                message: "Your Physics exam is in 5 days. Your study history shows you perform better when you start reviewing early.",
                suggestion: "Create Physics study plan"
            ),
            AIInsight(
                message: "You've been consistently studying more than 3 hours per day. Remember to take breaks for better retention.",
                suggestion: "Enable Pomodoro timer"
            ),
            AIInsight(
                message: "You've spent 80% of your food budget already this month. Consider cooking more meals at home this week.",
                suggestion: "View budget-friendly recipes"
            ),
            AIInsight(
                message: "Your sleep data shows you've been averaging 6 hours per night. Aim for 7-8 hours for optimal academic performance.",
                suggestion: "Adjust sleep schedule"
            ),
            AIInsight(
                message: "You have back-to-back classes today with no breaks. Don't forget to pack lunch and stay hydrated.",
                suggestion: "Set water reminders"
            )
        ]
        
        // Return a random insight
        return insights.randomElement() ?? insights[0]
    }
}
