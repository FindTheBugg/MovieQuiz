import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func comparisonOfRecords(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
