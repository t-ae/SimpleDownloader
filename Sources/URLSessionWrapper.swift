
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
        progressHandler = handler
    }
    
    public func onComplete(_ handler: @escaping (Self.ResultType)->Void) {
        completionHandler = handler
    }
    
    public func onCompleteWithError(_ handler: @escaping (Error)->Void) {
        errorHandler = handler
    }
    
    public func onCancel(_ handler: @escaping ()->Void) {
        cancelHandler = handler
    }
    
    public func start() {
        task.resume()
    }
    
    public func cancel() {
        task.cancel()
    }
}
