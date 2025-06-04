
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func testGetValueRange() throws {
        let testArray = [1,2,3,4,5]
        let testValue = testArray[safe: 2]
        
        XCTAssertNotNil(testValue)
        XCTAssertEqual(testValue, 3)
    }
    func testGetValueOutOfRange() throws {
        let testArray = [1,2,3,4,5]
        let testValue = testArray[safe: 10]
        
        XCTAssertNil(testValue)
    }
    
    
}
