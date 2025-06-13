import CoreML

class ReviewIntervalPredictor {
    private let model: FlashcardReviewScheduler

    init?() {
        guard let model = try? FlashcardReviewScheduler(configuration: .init()) else {
            print("❌ Failed to load model")
            return nil
        }
        self.model = model
    }

    func predictNextInterval(reviewsSoFar: Int, difficulty: Int, lastInterval: Double) -> Double? {
        do {
            let input = FlashcardReviewSchedulerInput(
                reviews_so_far: Double(reviewsSoFar),
                difficulty: Double(difficulty),
                last_interval: lastInterval
            )
            let output = try model.prediction(input: input)
            return output.next_session_interval
        } catch {
            print("❌ Prediction error: \(error)")
            return nil
        }
    }
}
