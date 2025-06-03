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
    
    // MARK: - Animations
    func showAnswerFeedback(isCorrect: Bool) {
        // удаление предыдущич анимаций
        image.layer.removeAnimation(forKey: "borderAnimation")
        image.layer.borderWidth = 8
        image.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func fadeBorder(completion: @escaping () -> Void) {
        // удаление предыдущие анимации
        image.layer.removeAnimation(forKey: "fadeBorder")
        
        // создание анимацию
        let fadeAnimation = CABasicAnimation(keyPath: "borderColor")
        fadeAnimation.fromValue = image.layer.borderColor
        fadeAnimation.toValue = UIColor.clear.cgColor
        fadeAnimation.duration = 0.7
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.image.layer.borderColor = UIColor.clear.cgColor
            self.image.layer.removeAnimation(forKey: "fadeBorder")
            completion()
        }
        
        image.layer.add(fadeAnimation, forKey: "fadeBorder")
        CATransaction.commit()
    }

    func resetImageBorder(animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            // задержка азтухания (оставил здесь т. к. анимация требует этого здесь)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.fadeBorder(completion: completion ?? {})
            }
        } else {
            image.layer.borderColor = UIColor.clear.cgColor
            completion?()
        }
    }

    func animateCorrectAnswer(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.2,
                       options: []) {
            self.image.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.image.transform = .identity
                completion()
            }
        }
    }

    func animateWrongAnswer(completion: @escaping () -> Void) {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [-5, 5, -5, 5, -3, 3, 0]
        shake.duration = 0.4
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        image.layer.add(shake, forKey: "shake")
        CATransaction.commit()
    }
    
    func setButtonsEnabled(_ enabled: Bool) {
           yesButton.isEnabled = enabled
           noButton.isEnabled = enabled
           yesButton.alpha = enabled ? 1 : 0.5
           noButton.alpha = enabled ? 1 : 0.5
       }
    
    //MARK: - ViewModels
    
    private struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
}
