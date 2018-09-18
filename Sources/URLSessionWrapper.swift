import Foundation

public class URLSessionWrapper<ResultType>: NSObject {
    var progressHandler: ((Double)->Void)?
    var completionHandler: ((ResultType)->Void)?
    var errorHandler: ((Error)->Void)?
    var cancelHandler: (()->Void)?
    
    var session: URLSession!
    var task: URLSessionTask!
}

extension URLSessionWrapper {
    public func onProgress(_ handler: @escaping (Double)->Void) {
        precondition(progressHandler == nil, "`progressHandler` is already set.")
        progressHandler = handler
    }
    
    public func onComplete(_ handler: @escaping (ResultType)->Void) {
        precondition(completionHandler == nil, "`completionHandler` is already set.")
        completionHandler = handler
    }
    
    public func onCompleteWithError(_ handler: @escaping (Error)->Void) {
        precondition(errorHandler == nil, "`errorHandler` is already set.")
        errorHandler = handler
    }
    
    public func onCancel(_ handler: @escaping ()->Void) {
        precondition(cancelHandler == nil, "`cancelHandler` is already set.")
        cancelHandler = handler
    }
    
    public func start() {
        task.resume()
    }
    
    public func cancel() {
        task.cancel()
    }
}
