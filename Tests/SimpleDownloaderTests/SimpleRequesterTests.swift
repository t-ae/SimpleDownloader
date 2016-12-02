import XCTest
import SimpleDownloader

class SimpleRequesterTests: XCTestCase {

    let url = "https://raw.githubusercontent.com/t-ae/SimpleDownloader/master/TestResources/test.txt"
    let content = "1234567890\n"
    
    func testRequest() {
        
        let ex = expectation(description: "request")
        
        let requester = SimpleRequester(method: .get, url: URL(string: url)!)
        
        requester.onComplete { response, data in
            let str = String(data: data, encoding: .utf8)
            XCTAssertEqual(str, self.content)
            ex.fulfill()
        }
        requester.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testError() {
        let ex = expectation(description: "request")
        
        let requester = SimpleRequester(method: .get, url: URL(string: "test")!)
        requester.onCompleteWithError { _ in
            ex.fulfill()
        }
        requester.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }

    static var allTests : [(String, (SimpleRequesterTests) -> () throws -> Void)] {
        return [
            ("testRequest", testRequest),
            ("testError", testError)
        ]
    }
}
