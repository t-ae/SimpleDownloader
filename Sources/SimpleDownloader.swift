import Foundation

public class SimpleDownloader: NSObject, URLSessionWrapper {
    
    public typealias ResultType = URL
    
    var progressHandler: ((Double)->Void)?
    var completionHandler: ((URL)->Void)?
    var errorHandler: ((Error)->Void)?
    var cancelHandler: (()->Void)?
    
    var session: URLSession!
    var task: URLSessionTask!
    
    public init(url: URL, headers: [String:String] = [:]) {
        super.init()
        let conf = URLSessionConfiguration.default
        session = URLSession(configuration: conf,
                             delegate: self,
                             delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: url)
        for (key,value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        task = session.downloadTask(with: request)
    }
}

extension SimpleDownloader : URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        self.completionHandler?(location)
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        
        if let error = error {
            self.errorHandler?(error)
        }
        
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        self.progressHandler?(progress)
        
    }
}
