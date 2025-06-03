protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setButtonsEnabled(_ enabled: Bool)
    func showAnswerFeedback(isCorrect: Bool)
    func animateCorrectAnswer(completion: @escaping () -> Void)
    func animateWrongAnswer(completion: @escaping () -> Void)
    func resetImageBorder(animated: Bool, completion: (() -> Void)?)
}
