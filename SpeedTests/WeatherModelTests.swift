import UIKit
import XCTest
import CoreLocation

class WeatherModelTests: XCTestCase {
    
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
        weatherupdatedExpectation = expectation(description: "expect the weather to be udpated")
        wm.getWeatherFromAPI()
        wm.temperatureUpdated = { wm in
            print("completion closure func in test")
            self.weatherupdatedExpectation!.fulfill()
            var temperature = wm.temperature()!
            XCTAssertTrue(temperature < 100, "Paris shouldn't be that hot")
            XCTAssertTrue(temperature > -20, "Paris shouldn't be that cold")

        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "got a timeout when pulling the temperature")
        }
    }
    


    func testIfIShouldUpdateTheWeather() {
        wm.setPosition(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448))
        // tests based on time
        wm.setUpdateTime(100)
        wm.lastUpdateTime = nil
        XCTAssertTrue(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448)),"should update the first time because we never updated")
        wm.lastUpdateTime = Date()
        XCTAssertFalse(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448)),"should not update the first time because we just updated")
        wm.lastUpdateTime = Date(timeInterval: -5, since: Date())
        XCTAssertFalse(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448)),"should not update the first time because we are below the min update time")
        wm.lastUpdateTime = Date(timeInterval: -600, since: Date())
        XCTAssertTrue(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448)),"should update because we've not updated in a long time")
        
        
        // tests based on location
        wm.lastUpdateTime = Date()
        wm.setPosition(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448))
        XCTAssertFalse(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680800, longitude: -117.178448)),"shouldn't need to update weather when we didn't move")
        XCTAssertFalse(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.680222, longitude: -117.179632)),"shouldn't need to update weather so close")
        XCTAssertTrue(wm.shouldUpdateWeather(CLLocationCoordinate2D(latitude: 32.688816, longitude: -117.178230)),"should update the weather past 500m")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBogusJsonDoesntBreakThings() {
        var json = Data()
        wm.parseAndUpdateModelWithJsonFromAPI(json: Data())
    }
    
    func testWeatherReturnsAnIcon() {
        weatherupdatedExpectation = expectation(description: "expect the weather to be udpated")
        wm.getWeatherFromAPI()
        wm.temperatureUpdated = { wm in
            print("completion closure func in test")
            var weatherIcon = wm.getWeatherIcon()
            print("my weather icon is \(weatherIcon)")
            XCTAssertNotNil(weatherIcon, "I should get an icon")
            
            var weatherDescription = wm.getWeatherDescription()
            print("my weather description is \(weatherDescription)")
            XCTAssertNotNil(weatherDescription, "I should get a weather description")
            self.weatherupdatedExpectation!.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "got a timeout when pulling the temperature")
        }

    }
    
    func updatedTemperature(temperature: Double)
    {
        print("updatedtemp func in test")
        weatherupdatedExpectation!.fulfill()
        XCTAssertTrue(temperature < 100, "Paris shouldn't be that hot")
        XCTAssertTrue(temperature > -20, "Paris shouldn't be that cold")
    }
    
    
 
    
    
}
