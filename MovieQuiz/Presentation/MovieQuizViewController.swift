import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counter: UILabel!
    @IBOutlet weak private var image: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Properties
    private var alertPresenter: AlertPresenter!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol!
    
    //MARK: - override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Настройка UI
        image.layer.cornerRadius = image.frame.width / 20
        image.layer.masksToBounds = true
        
        //  Инициализация сервисов
        let moviesLoader = MoviesLoader()
            statisticService = StatisticServiceImplementation()
            alertPresenter = AlertPresenter(viewController: self)
            questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        
        //  Настройка QuestionFactory
        questionFactory = QuestionFactory(
            moviesLoader: moviesLoader,
            delegate: self
        )
        
        //  Загрузка данных и начало работы
        showLoadingIndicator()
        questionFactory?.loadData()
        //        questionFactory.setup(delegate: self)
        //        self.questionFactory = questionFactory
    }
    
    // MARK: - IB Actions
    @IBAction func noButton(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCoorect: !currentQuestion.correctAnswer)
    }
    
    @IBAction func yesButton(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCoorect: currentQuestion.correctAnswer)
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    //MARK: - Private Methods
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        _ = AlertModel(
            title: "Ошибка!",
            message: "Ошибка подключения",
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        yesButton.isEnabled = true
        yesButton.alpha = 1
        noButton.isEnabled = true
        noButton.alpha = 1
        image.layer.borderColor = UIColor.clear.cgColor
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        if currentQuestionIndex == questionsAmount - 1 {
            let bestGame = statisticService.bestGame
            let totalGames = statisticService.gamesCount
            let totalAccuracy = statisticService.totalAccuracy
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            let dateString = dateFormatter.string(from: bestGame.date)
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(totalGames)
                    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
                    Средняя точность: \(String(format: "%.1f", totalAccuracy))%
                    """,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
            )
            
            alertPresenter.show(alert: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    //MARK: - Publick methods
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    
    //MARK: - ViewModels
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}
