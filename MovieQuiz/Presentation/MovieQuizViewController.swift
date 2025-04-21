import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var Counter: UILabel!
    @IBOutlet weak var Image: UIImageView!
    
 


    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Image.layer.cornerRadius = 10
        Image.layer.masksToBounds = true
    }
    
    
    @IBAction private func NoButton(_ sender: Any) {
        let currenQuestion = questions[currentQuestionIndex]
        let userAnswer = false
        showAnswerResult(isCoorect: userAnswer == currenQuestion.correctAnswer)
    }
    @IBAction private func YesButton(_ sender: Any) {
        let currenQuestion = questions[currentQuestionIndex]
        let userAnswer = true
        showAnswerResult(isCoorect: userAnswer == currenQuestion.correctAnswer)
        
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    // для состояния "Вопрос показан"
    struct QuizStepViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }


    // для состояния "Результат квиза"
    struct QuizResultsViewModel {
      let title: String
      let text: String
      let buttonText: String
    }

    struct ViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }
    
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
                image: UIImage(named: model.image) ?? UIImage(), // 2
                question: model.text, // 3
                questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)") // 4
            return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        Image.image = step.image
        questionLabel.text = step.question
        Counter.text = step.questionNumber
    }
    
    private func showAnswerResult(isCoorect: Bool){
        Image.layer.borderWidth = 8
        if isCoorect == false {
            Image.layer.borderColor = UIColor.ypRed.cgColor
        } else {
            correctAnswers += 1
            Image.layer.borderColor = UIColor.ypGreen.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        Image.layer.borderColor = UIColor.clear.cgColor
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
    
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
