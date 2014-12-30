import UIKit
import XCTest
import CoreLocation

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
        wm.myDelegate = self
               
        waitForExpectationsWithTimeout(5) { (error) in
            XCTAssertNil(error, "got a timeout when pulling the temperature")
        }
    }
    
    func testIfIShouldUpdateTheWeather() {
        wm.setPosition(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448))
        XCTAssertFalse(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448)),"shouldn't need to update weather when we didn't move")
        XCTAssertFalse(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680222, longitude: -117.179632)),"shouldn't need to update weather so close")
        XCTAssertTrue(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.688816, longitude: -117.178230)),"should update the weather past 500m")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func updatedTemperature(temperature: Double)
    {
        println("updatedtemp func in test")
        weatherupdatedExpectation!.fulfill()
        XCTAssertTrue(temperature < 100, "Paris shouldn't be that hot")
        XCTAssertTrue(temperature > -20, "Paris shouldn't be that cold")
    }
 
    
    
}
