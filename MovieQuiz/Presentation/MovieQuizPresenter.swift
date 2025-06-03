import UIKit

//  MARK: - MovieQuizPresenter

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //  MARK: - Properties
    private let statisticService: StatisticServiceImplementation
    private let moviesLoader: MoviesLoading
    private let alertPresenter: AlertPresenter
    let questionFactory: QuestionFactoryProtocol
    weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    
    init(viewController: MovieQuizViewController) {
        self.statisticService = StatisticServiceImplementation()
        self.moviesLoader = MoviesLoader()
        self.alertPresenter = AlertPresenter(viewController: viewController)
        
        let factory = QuestionFactory(moviesLoader: moviesLoader, delegate: nil)
        self.questionFactory = factory
        
        factory.delegate = self
        self.viewController = viewController
        
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Button tapped methods
    
    func noButton() {
        didAnswer(isYes: false)
    }
    
    func yesButton() {
        didAnswer(isYes: true)
    }
    
    //  MARK: - Methods
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    func showNextQuestionOrResult() {
        
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let totalGames = statisticService.gamesCount
            let totalAccuracy = statisticService.totalAccuracy
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            let dateString = dateFormatter.string(from: bestGame.date)
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                        Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                        Количество сыгранных квизов: \(totalGames)
                        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
                        Средняя точность: \(String(format: "%.1f", totalAccuracy))%
                        """,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory.requestNextQuestion()
                }
            )
            alertPresenter.show(alert: alertModel)
        } else {
            self.currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.setButtonsEnabled(false)
        viewController?.showAnswerFeedback(isCorrect: isCorrect)
        
        //  запуск анимации
        if isCorrect {
            viewController?.animateCorrectAnswer { [weak self] in
                self?.handleAnimationCompletion()
            }
        } else {
            viewController?.animateWrongAnswer { [weak self] in
                self?.handleAnimationCompletion()
            }
        }
    }
    
    private func handleAnimationCompletion() {
        viewController?.resetImageBorder(animated: true) { [weak self] in
            self?.viewController?.setButtonsEnabled(true)
            
            // пауза перед сменой изображения
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showNextQuestionOrResult()
            }
        }
    }
    
    //  MARK: - Private methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givaenAnswer = isYes
        
        showAnswerResult(isCorrect: givaenAnswer == currentQuestion.correctAnswer)
    }
}

