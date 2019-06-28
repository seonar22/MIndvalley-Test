import XCTest
@testable import MIndvalley_Test

class MIndvalley_TestTests: XCTestCase {
    var sut: PinTableViewController!
    var window: UIWindow!
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupVC()
    }
    
    func setupVC(){
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(withIdentifier: "PinTableViewController") as? PinTableViewController
    }
    
    func test_InitialData() {
        XCTAssertEqual(sut.pins.count,0,"searchResults should be empty before the data task runs")
    }
    
    func test_UpdateResultData() {
        sut.viewDidLoad()
        XCTAssertEqual(
            sut.pins.count,
            10,
            "searchResults should be 10 per data from network")
    }
    
    override func tearDown() {
        sut = nil
        window = nil
        super.tearDown()
    }
    
}
