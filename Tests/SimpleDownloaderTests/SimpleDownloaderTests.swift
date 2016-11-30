import XCTest
import SimpleDownloader

class SimpleDownloaderTests: XCTestCase {
    
    let url = "https://raw.githubusercontent.com/t-ae/SimpleDownloader/master/TestResources/test.txt"
    
    func testDownload() {
        
        let ex = expectation(description: "download")
        
        let downloader = SimpleDownloader(url: URL(string: url)!)
        downloader.onProgress { print($0) }
        
        downloader.onComplete { (location:URL)->Void in
            ex.fulfill()
            try! FileManager.default.removeItem(at: location)
        }
        downloader.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }

    func testCancel() {
        let ex = expectation(description: "download")
        
        let downloader = SimpleDownloader(url: URL(string: url)!)
        downloader.onCancel {
            ex.fulfill()
        }
        downloader.start()
        let deadline = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            downloader.cancel()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testError() {
        let ex = expectation(description: "download")
        
        let downloader = SimpleDownloader(url: URL(string: "tests")!)
        downloader.onProgress { print($0) }
        
        downloader.onComplete { (location:URL)->Void in
            print(location)
        }
        downloader.onCompleteWithError { error in
            print(error)
            ex.fulfill()
        }
        downloader.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func test404() {
        
        // If 404, error must be thrown.
        // https://developer.apple.com/reference/foundation/urlsessiondownloadtask
        // but, oddly, error is nil, and task complete with 404 file.

        let ex = expectation(description: "download")
        
        let downloader = SimpleDownloader(url: URL(string: url + "/hogehoge")!)
        downloader.onComplete { url in
            print(url)
            print(try! String(contentsOf: url))
        }
        downloader.onCompleteWithError { error in
            print("error:", error)
            ex.fulfill()
        }
        downloader.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    static var allTests : [(String, (SimpleDownloaderTests) -> () throws -> Void)] {
        return [
            ("testDownload", testDownload),
            ("testCancel", testCancel),
            ("testError", testError)
        ]
    }
}
