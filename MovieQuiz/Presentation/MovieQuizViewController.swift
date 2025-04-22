import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counter: UILabel!
    @IBOutlet weak private var image: UIImageView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    //MARK: - override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        image.layer.cornerRadius = image.frame.width / 20
        image.layer.masksToBounds = true
    }
    
    // MARK: - IB Actions
    @IBAction func noButton(_ sender: Any) {
        let currenQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCoorect: !currenQuestion.correctAnswer)
    }
    
    @IBAction func yesButton(_ sender: Any) {
        let currenQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCoorect: currenQuestion.correctAnswer)
    }
    
    //MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)") // 4
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        image.image = step.image
        questionLabel.text = step.question
        counter.text = step.questionNumber
    }
    
    private func showAnswerResult(isCoorect: Bool){
        yesButton.isEnabled = false
        yesButton.alpha = 0.5
        noButton.isEnabled = false
        noButton.alpha = 0.5
        image.layer.borderWidth = 8
        if isCoorect == false {
            image.layer.borderColor = UIColor.ypRed.cgColor
        } else {
            correctAnswers += 1
            image.layer.borderColor = UIColor.ypGreen.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        yesButton.isEnabled = true
        yesButton.alpha = 1
        noButton.isEnabled = true
        noButton.alpha = 1
        image.layer.borderColor = UIColor.clear.cgColor
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10" // 1
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - ViewModels
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}
