import UIKit

public struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

public struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

public struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

public struct ViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

