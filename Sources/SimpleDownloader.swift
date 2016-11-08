import Foundation

public class SimpleDownloader: NSObject, URLSessionWrapper {
    
    public typealias ResultType = URL
    
    var progressHandler: ((Double)->Void)?
    var completionHandler: ((ResultType)->Void)?
    var errorHandler: ((Error?)->Void)?
    var cancelHandler: (()->Void)?
    
    var session: URLSession!
    var task: URLSessionTask!
    
    public init(url: URL) {
        super.init()
        let conf = URLSessionConfiguration.default
        session = URLSession(configuration: conf,
                             delegate: self,
                             delegateQueue: OperationQueue.main)
        task = session.downloadTask(with: url)
    }
}

extension SimpleDownloader : URLSessionDelegate, URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        completionHandler?(location)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        errorHandler?(error)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler?(progress)
    }
}
