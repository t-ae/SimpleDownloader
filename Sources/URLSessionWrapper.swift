
import Foundation

internal protocol URLSessionWrapper : class {
    
    associatedtype ResultType
    
    var progressHandler: ((Double)->Void)? { get set }
    var completionHandler: ((ResultType)->Void)? { get set }
    var errorHandler: ((Error)->Void)? { get set }
    var cancelHandler: (()->Void)? { get set }
    
    var session: URLSession! { get set }
    var task: URLSessionTask! { get set }
}

extension URLSessionWrapper {
    public func onProgress(_ handler: @escaping (Double)->Void) {
        precondition(progressHandler == nil, "`progressHandler` is already set.")
        progressHandler = handler
    }
    
    public func onComplete(_ handler: @escaping (Self.ResultType)->Void) {
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
