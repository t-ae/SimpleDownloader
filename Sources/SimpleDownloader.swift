import Foundation

public class SimpleDownloader: URLSessionWrapper<URL>, URLSessionDownloadDelegate {

    let destination: URL
    
    public init(url: URL,
                destination: URL,
                headers: [String:String] = [:],
                config: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.destination = destination
        super.init()
        
        session = URLSession(configuration: config,
                             delegate: self,
                             delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: url)
        for (key,value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        task = session.downloadTask(with: request)
    }
    
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        
        let response = downloadTask.response as? HTTPURLResponse
        
        guard response?.statusCode == 200 else {
            DispatchQueue.main.async {
                self.errorHandler?(SimpleDownloaderError.responseCode(code: response?.statusCode))
                self.session.finishTasksAndInvalidate()
            }
            return
        }
        
        do {
            if FileManager.default.fileExists(atPath: self.destination.path) {
                try FileManager.default.removeItem(at: self.destination)
            }
            try FileManager.default.moveItem(at: location, to: self.destination)
            DispatchQueue.main.async {
                self.completionHandler?(self.destination)
                self.session.finishTasksAndInvalidate()
            }
        } catch(let e) {
            DispatchQueue.main.async {
                self.errorHandler?(e)
                self.session.finishTasksAndInvalidate()
            }
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        
        guard let error = error else {
            return
        }
        DispatchQueue.main.async {
            if (error as NSError).code == NSURLErrorCancelled {
                self.cancelHandler?()
            } else {
                self.errorHandler?(error)
            }
            self.session.finishTasksAndInvalidate()
        }
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressHandler?(progress)
        }
    }
}

public enum SimpleDownloaderError: Error {
    case responseCode(code: Int?)
}
