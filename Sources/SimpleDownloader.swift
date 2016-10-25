import Foundation

class SimpleDownloader: NSObject {
    
    fileprivate var progressHandler: ((Double)->Void)?
    fileprivate var completionHandler: ((URL)->Void)?
    fileprivate var errorHandler: ((Error?)->Void)?
    fileprivate var cancelHandler: (()->Void)?
    
    private var session: URLSession!
    private var task: URLSessionDownloadTask!
    
    public init(url: URL) {
        super.init()
        let conf = URLSessionConfiguration.default
        session = URLSession(configuration: conf,
                             delegate: self,
                             delegateQueue: OperationQueue.main)
        task = session.downloadTask(with: url)
    }
    
    public func onProgress(_ handler: @escaping (Double)->Void) -> SimpleDownloader {
        progressHandler = handler
        return self
    }
    
    public func onComplete(_ handler: @escaping (URL)->Void) -> SimpleDownloader {
        completionHandler = handler
        return self
    }
    
    public func onCompleteWithError(_ handler: @escaping (Error?)->Void) -> SimpleDownloader {
        errorHandler = handler
        return self
    }
    
    public func onCancel(_ handler: @escaping ()->Void) -> SimpleDownloader {
        cancelHandler = handler
        return self
    }
    
    public func start() {
        task.resume()
    }
    
    public func cancel() {
        task.cancel()
        cancelHandler?()
    }
}

extension SimpleDownloader : URLSessionDelegate, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        completionHandler?(location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        errorHandler?(error)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler?(progress)
    }
}
