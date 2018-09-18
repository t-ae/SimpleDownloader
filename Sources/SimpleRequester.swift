import Foundation

public enum HTTPMethod: String {
    case get = "GET", post = "POST", head = "HEAD"
}

public class SimpleRequester: URLSessionWrapper<(URLResponse, Data)> {
    
    public init(method: HTTPMethod, url: URL,
                headers: [String:String] = [:],
                parameters: [String:String] = [:],
                config: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        super.init()
        
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
        
        session = URLSession(configuration: config)
        
        task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorHandler?(error)
                } else {
                    self.completionHandler?((response!, data!))
                }
                self.session.finishTasksAndInvalidate()
            }
        }
    }
    
    private func escape(_ string: String) -> String {
        let charset = NSCharacterSet.urlQueryAllowed
        return string.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    
    private func onProgress(_ handler: @escaping (Double) -> Void) -> SimpleRequester {
        fatalError("No progress handler.")
    }
}
