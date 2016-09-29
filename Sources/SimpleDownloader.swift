import Foundation

class SimpleDownloader: NSObject {
    
    fileprivate var progressHandler: ((Double)->Void)?
    fileprivate var completionHandler: ((URL)->Void)?
    fileprivate var errorHandler: ((Error?)->Void)?
    fileprivate var cancelHandler: (()->Void)?
    
    private var session: URLSession!
    private var task: URLSessionDownloadTask!
    
    init(url: URL) {
        super.init()
        let conf = URLSessionConfiguration.default
        session = URLSession(configuration: conf,
                             delegate: self,
                             delegateQueue: OperationQueue.main)
        task = session.downloadTask(with: url)
    }
    
    func onProgress(_ handler: @escaping (Double)->Void) -> SimpleDownloader {
        progressHandler = handler
        return self
    }
    
    func onComplete(_ handler: @escaping (URL)->Void) -> SimpleDownloader {
        completionHandler = handler
        return self
    }
    
    func onCompleteWithError(_ handler: @escaping (Error?)->Void) -> SimpleDownloader {
        errorHandler = handler
        return self
    }
    
    func onCancel(_ handler: @escaping ()->Void) -> SimpleDownloader {
        cancelHandler = handler
        return self
    }
    
    func start() {
        task.resume()
    }
    
    func cancel() {
        task.cancel()
        cancelHandler?()
    }
}

extension SimpleDownloader : URLSessionDelegate, URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        completionHandler?(location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        errorHandler?(error)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler?(progress)
    }
}
