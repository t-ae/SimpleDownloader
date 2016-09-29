import XCTest
@testable import SimpleDownloader

class SimpleDownloaderTests: XCTestCase {
    
    let url = "http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz"
    
    func testDownload() {
        
        let ex = expectation(description: "download")
        
        let downloader = SimpleDownloader(url: URL(string: url)!)
            .onProgress { print($0) }
            .onComplete { location in
                ex.fulfill()
                try! FileManager.default.removeItem(at: location)
        }
        downloader.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testCancel() {
        let ex = expectation(description: "download")
        
        let downloader = SimpleDownloader(url: URL(string: url)!)
            .onCancel {
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
        
        let downloader = SimpleDownloader(url: URL(string: url + "/hogehoge")!)
            .onCompleteWithError { _ in
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
