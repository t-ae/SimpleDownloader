
import Foundation

public enum HttpMethod: String {
    case get = "GET", post = "POST", head = "HEAD"
}

public class SimpleRequester: NSObject, URLSessionWrapper {

    public typealias ResultType = Data
    
    var progressHandler: ((Double)->Void)?
    var completionHandler: ((ResultType)->Void)?
    var errorHandler: ((Error?)->Void)?
    var cancelHandler: (()->Void)?
    
    var session: URLSession!
    var task: URLSessionTask!
    
    public init(method: HttpMethod, url: URL, headers: [String:String] = [:], parameters: [String:String] = [:]) {
        super.init()
        let conf = URLSessionConfiguration.default
        session = URLSession(configuration: conf,
                             delegate: self,
                             delegateQueue: OperationQueue.main)
        
        let query = parameters
            .map { k, v in
                "\(escape(k))=\(escape(v))"
            }
            .joined(separator: "&")
        
        var request: URLRequest
        switch method {
        case .post:
            request = URLRequest(url: url)
            request.httpBody = query.data(using: .utf8)
            break
        default:
            let queryUrl = URL(string: url.absoluteString + "?" + query)!
            request = URLRequest(url: queryUrl)
            break
        }
        request.httpMethod = method.rawValue
        
        for (key,value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        task = session.dataTask(with: request)
    }
    
    private func escape(_ string: String) -> String {
        let charset = NSCharacterSet.urlQueryAllowed
        return string.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    
    private func onProgress(_ handler: @escaping (Double) -> Void) -> SimpleRequester {
        fatalError("No progress handler.")
    }
    
    public func onComplete(_ handler: @escaping (String) -> Void) {
        onComplete { (data: Data) in
            let str = String(data: data, encoding: String.Encoding.utf8)!
            handler(str)
        }
    }
}

extension SimpleRequester: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        completionHandler?(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        errorHandler?(error)
    }
}
