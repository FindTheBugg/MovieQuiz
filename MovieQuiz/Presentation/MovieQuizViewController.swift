import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counter: UILabel!
    @IBOutlet weak private var image: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Properties
    private var movieQuizPresener: MovieQuizPresenter!
    
    //MARK: - override Methods
    override func viewDidLoad() {
        
        //  Настройка UI
        image.layer.cornerRadius = image.frame.width / 20
        image.layer.masksToBounds = true
        
        //  Инициализация сервисов
        movieQuizPresener = MovieQuizPresenter(viewController: self)
        
        //  Загрузка данных и начало работы
        showLoadingIndicator()
        movieQuizPresener.questionFactory.loadData()
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
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка!",
            message: "Интернет соединение отсутствует или сервер недоступен",
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.movieQuizPresener.resetQuestionIndex()
                self.movieQuizPresener.correctAnswers = 0
                showLoadingIndicator()
            }
        )
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alert: alertModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        image.image = step.image
        questionLabel.text = step.question
        counter.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        UIView.animate(withDuration: 0.3) {
            self.yesButton.alpha = 0.5
            self.noButton.alpha = 0.5
        }
        image.layer.borderWidth = 8
        
        if isCorrectAnswer {
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
        } else {
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.values = [-5, 5, -5, 5, -3, 3, 0]
            shake.duration = 0.4
            image.layer.add(shake, forKey: "shake")
            image.layer.borderColor = UIColor.ypRed.cgColor
        }
        
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
        
    }
    
    //MARK: - ViewModels
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}
