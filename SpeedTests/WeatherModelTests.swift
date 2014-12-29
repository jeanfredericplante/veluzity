import UIKit
import XCTest

class WeatherModelTests: XCTestCase, WeatherUpdateDelegate {
    
    var weatherupdatedExpectation: XCTestExpectation?
    var wm: WeatherModel = WeatherModel()
  
    override func setUp() {
        super.setUp()
        var parisLatitude = 48.856
        var parisLongitude = 2.3508

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTemperature() {
        weatherupdatedExpectation = expectationWithDescription("expect the weather to be udpated")
        wm.getWeatherFromAPI()
               
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil("timeout")
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func updatedTemperature(temperature: Float)
    {
        weatherupdatedExpectation!.fulfill()
        XCTAssertTrue(wm.temperature() < 200, "Paris shouldn't be that hot")
        XCTAssertTrue(wm.temperature() > 0, "Paris shouldn't be that cold")
    }
 
    
    
}
