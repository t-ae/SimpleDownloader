import XCTest
import SimpleDownloader

class SimpleDownloaderTests: XCTestCase {
    
    let url = "https://raw.githubusercontent.com/t-ae/SimpleDownloader/master/TestResources/test.txt"
    let dest = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.txt")
    
    func testDownload() {
        
        let ex = expectation(description: "download")
        let downloader = SimpleDownloader(url: URL(string: url)!, destination: dest)
        downloader.onProgress { print($0) }
        
        if FileManager.default.fileExists(atPath: dest.path) {
            try! FileManager.default.removeItem(at: dest)
        }
        
        downloader.onComplete { (location:URL)->Void in
            print(location)
            try! FileManager.default.removeItem(at: location)
            ex.fulfill()
        }
        downloader.onCompleteWithError { e in
            print(e)
        }
        downloader.start()
        
        waitForExpectations(timeout: 15, handler: nil)
    }

    func testCancel() {
        let ex = expectation(description: "download")
        
        if FileManager.default.fileExists(atPath: dest.path) {
            try! FileManager.default.removeItem(at: dest)
        }
        
        let downloader = SimpleDownloader(url: URL(string: url)!, destination: dest)
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
        
        if FileManager.default.fileExists(atPath: dest.path) {
            try! FileManager.default.removeItem(at: dest)
        }
        
        let downloader = SimpleDownloader(url: URL(string: "tests")!, destination: dest)
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

        let ex = expectation(description: "download")
        
        if FileManager.default.fileExists(atPath: dest.path) {
            try! FileManager.default.removeItem(at: dest)
        }
        
        let downloader = SimpleDownloader(url: URL(string: url + "/hogehoge")!, destination: dest)
        downloader.onComplete { url in
            print(url)
            print(try! String(contentsOf: url))
        }
        downloader.onCompleteWithError { error in
            print("error:", error)
            ex.fulfill()
        }
        downloader.start()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    static var allTests : [(String, (SimpleDownloaderTests) -> () throws -> Void)] {
        return [
            ("testDownload", testDownload),
            ("testCancel", testCancel),
            ("testError", testError)
        ]
    }
}
