import UIKit

//  MARK: - MovieQuizPresenter

final class MovieQuizPresenter {
    
    //  MARK: - Properties
     var currentQuestionIndex = 0
     let questionsAmount: Int = 10
    
    //  MARK: - Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func swtchNextQuestion() {
        currentQuestionIndex += 1
    }
    
     func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}

