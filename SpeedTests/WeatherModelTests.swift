import UIKit
import XCTest

class WeatherModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        var parisLatitude = 48.856
        var parisLongitude = 2.3508
        wc = WeatherComponent()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTemperature() {
        XCTAssertTrue(wc.getTemperature(parisLatitude,parisLongiture) < 200, "Paris shouldn't be that hot")
        XCTAssertTrue(wc.getTemperature(parisLatitude,parisLongiture) > 0, "Paris shouldn't be that cold")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
