import UIKit

final class StatisticServiceImplementation {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameTotal
        case bestGameCorrect
        case bestGameDate
        case totalCorrect
        case totalQuestions
    }
}

extension StatisticServiceImplementation: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let total = userDefaults.integer(forKey: Keys.bestGameTotal.rawValue)
            let correct = userDefaults.integer(forKey: Keys.bestGameCorrect.rawValue)
            let date = userDefaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            userDefaults.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            userDefaults.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            userDefaults.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = userDefaults.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = userDefaults.integer(forKey: Keys.totalQuestions.rawValue)
        
        return totalQuestions > 0 ? (Double(totalCorrect) / Double(totalQuestions)) * 100 : 0
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let newTotalCorrect = correctAnswers + count
        userDefaults.set(newTotalCorrect, forKey: Keys.totalCorrect.rawValue)
        
        let newTotalQuestions = totalQuestions + amount
        userDefaults.set(newTotalQuestions, forKey: Keys.totalQuestions.rawValue)
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        
        if currentGame.correct > bestGame.correct {
            bestGame = currentGame
        }
    }
    
    private var correctAnswers: Int {
        userDefaults.integer(forKey: Keys.totalCorrect.rawValue)
    }
    
    private var totalQuestions: Int {
        userDefaults.integer(forKey: Keys.totalQuestions.rawValue)
    }
}
