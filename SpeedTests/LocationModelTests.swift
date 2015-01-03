import UIKit
import XCTest

class LocationModelTests: XCTestCase {
    
    var lm = LocationModel()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
        
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testReverseGeocoding() {
        
    }
    
    func testCardinalDirection() {
        var cardHeading = lm.getCardinalDirectionFromHeading(360)
        XCTAssertTrue(cardHeading=="N", "heading should be north")
        
        cardHeading = lm.getCardinalDirectionFromHeading(0)
        XCTAssertTrue(cardHeading=="N", "heading should be north")
        
        cardHeading = lm.getCardinalDirectionFromHeading(0.1)
        XCTAssertTrue(cardHeading=="N", "heading should be north")
        
        cardHeading = lm.getCardinalDirectionFromHeading(22)
        XCTAssertTrue(cardHeading=="N", "heading should be north")

        cardHeading = lm.getCardinalDirectionFromHeading(23)
        XCTAssertTrue(cardHeading=="NE", "heading should be north east")

        cardHeading = lm.getCardinalDirectionFromHeading(70)
        XCTAssertTrue(cardHeading=="E", "heading should be  east")
        
        cardHeading = lm.getCardinalDirectionFromHeading(90)
        XCTAssertTrue(cardHeading=="E", "heading should be  east")
   
        cardHeading = lm.getCardinalDirectionFromHeading(115)
        XCTAssertTrue(cardHeading=="SE", "heading should be south east")
        
        cardHeading = lm.getCardinalDirectionFromHeading(170)
        XCTAssertTrue(cardHeading=="S", "heading should be south ")
        
        cardHeading = lm.getCardinalDirectionFromHeading(180)
        XCTAssertTrue(cardHeading=="S", "heading should be south")
        
        cardHeading = lm.getCardinalDirectionFromHeading(180+360)
        XCTAssertTrue(cardHeading=="S", "heading should be south")
        
        cardHeading = lm.getCardinalDirectionFromHeading(235)
        XCTAssertTrue(cardHeading=="SW", "heading should be south west")
        
        cardHeading = lm.getCardinalDirectionFromHeading(270)
        XCTAssertTrue(cardHeading=="W", "heading should be west")
       
        cardHeading = lm.getCardinalDirectionFromHeading(325)
        XCTAssertTrue(cardHeading=="NW", "heading should be north west")
   
        cardHeading = lm.getCardinalDirectionFromHeading(355)
        XCTAssertTrue(cardHeading=="N", "heading should be north ")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
