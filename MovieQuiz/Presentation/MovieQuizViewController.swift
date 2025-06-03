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
    private let movieQuizPresener = MovieQuizPresenter()
    private var alertPresenter: AlertPresenter!
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    
    
    //MARK: - override Methods
    override func viewDidLoad() {
        
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
        movieQuizPresener.viewController = self
    }
    
    // MARK: - IBActions
    @IBAction private func yesButton (_ sender: UIButton) {
        movieQuizPresener.yesButton()
    }
    
    @IBAction private func noButton (_ sender: UIButton) {
        movieQuizPresener.noButton()
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
        let alertModel = AlertModel(
            title: "Ошибка!",
            message: "Интернет соединение отсутствует или сервер недоступен",
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.movieQuizPresener.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.loadData()
                showLoadingIndicator()
            }
        )
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alert: alertModel)
    }
    
    //  MARK: - QuestionFactory
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        movieQuizPresener.didReceiveNextQuestion(question: question)
    }
    
     func show(quiz step: QuizStepViewModel) {
        image.image = step.image
        questionLabel.text = step.question
        counter.text = step.questionNumber
    }
    
     func showAnswerResult(isCorrect: Bool){
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        UIView.animate(withDuration: 0.3) {
            self.yesButton.alpha = 0.5
            self.noButton.alpha = 0.5
        }
        
        image.layer.borderWidth = 8
        
        if isCorrect {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.2,
                           options: []) {
                self.image.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.image.layer.borderColor = UIColor.ypGreen.cgColor
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.image.transform = .identity
                }
            }
            
            correctAnswers += 1
        } else {
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.values = [-5, 5, -5, 5, -3, 3, 0]
            shake.duration = 0.4
            image.layer.add(shake, forKey: "shake")
            image.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.4) {
                self.yesButton.alpha = 1
                self.noButton.alpha = 1
            } completion: { _ in
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            }
            
            UIView.animate(withDuration: 0.3) {
                self.image.layer.borderColor = UIColor.clear.cgColor
            }
            movieQuizPresener.showNextQuestionOrResult()
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
