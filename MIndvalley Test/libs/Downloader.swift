import Foundation

enum DownloadingStatus {
    case none, pending, finished, failed
}

protocol DownloadChecker: class {
    func checkDownloadedData(item: Data)
    func downloadFailure(forUrl url: String, error: Error)
}

class Downloader {
    
    let cache = Cache(config: CacheConfiguration.default())
    private var downloads = [String : DownloadedData]()
    static let shared = Downloader()
    
    func download(url: String, checker: DownloadChecker) {
        let item = itemFromCache(url: url)
        if item != nil {
            checker.checkDownloadedData(item: item!)
            return
        }
        var downloadItem = self.downloads[url]
        if downloadItem == nil {
            downloadItem = DownloadedData(url: url, observer: checker)
        }
        if downloadItem!.status == .pending {
            return
        }
        self.downloads[url] =  downloadItem
        startDownload(downloadItem: downloadItem!)        
    }
    
    func download(url: String,success: @escaping (Data) ->(), error: @escaping (Error?) ->()) {
        let item = itemFromCache(url: url)
        if item != nil {
            success(item!)
            return
        }
        
        var downloadItem = self.downloads[url]
        
        if downloadItem == nil {
            let notifier = ClosureNotifier(success: success, error: error)
            downloadItem = DownloadedData(url: url, closureNotifier: notifier)
        }
        
        if downloadItem!.status == .pending {
            return
        }
        
        self.downloads[url] =  downloadItem
        
        startDownload(downloadItem: downloadItem!)
    }
    
    private func itemFromCache(url: String) -> Data? {
        let cachedItem = cache.get(url: url)
        return cachedItem
    }
    
    private func startDownload (downloadItem: DownloadedData) {
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: downloadItem.url)!) { (data, response, error) in
            defer {
                self.downloads.removeValue(forKey: downloadItem.url)
            }
            if error != nil {
                downloadItem.notifyFailure(error: error!)
                return
            }
            guard data != nil else {
                let emptyError = Helper.createEmptyDataError()
                downloadItem.notifyFailure(error: emptyError)
                return
            }
            downloadItem.notifySuccess(data: data!)
            self.cache.add(url: downloadItem.url, item: data!)
        }
        dataTask.resume()
        
        downloadItem.downloadTask = dataTask
        downloadItem.status = .pending
    }
    
    func cancelDownload(url: String, checker: DownloadChecker) {
        guard let downloadItem = downloads[url] else {return}
        
        downloadItem.remove(checker: checker)
        if downloadItem.observers.count == 0 {
            
            let safeToCancelBlocks = downloadItem.blockObservers.count == 0 || downloadItem.blockObservers.count == 1
            let noObjectObservers = downloadItem.observers.count == 0
            
            if noObjectObservers && safeToCancelBlocks {
                downloadItem.downloadTask?.cancel()
                downloads.removeValue(forKey: downloadItem.url)
            }
        }
    }
}

class DownloadedData {
    private(set) public var downloadedItem: Data?
    var observers = [DownloadChecker]()
    var blockObservers = [ClosureNotifier]()
    var status: DownloadingStatus = .none
    var url: String
    var downloadTask: URLSessionDataTask?
    init(url: String, observers: [DownloadChecker]) {
        self.url = url
        self.observers.append(contentsOf: observers)
    }
    init(url: String, observer: DownloadChecker) {
        self.url = url
        self.observers.append(observer)
    }
    init(url: String, closureNotifier: ClosureNotifier) {
        self.url = url
        self.blockObservers.append(closureNotifier)
    }
    
    func add(checker: DownloadChecker) {
        observers.append(checker)
    }
    func remove(checker: DownloadChecker) {
        for (index, observer) in self.observers.enumerated() {
            if observer === checker {
                self.observers.remove(at: index)
            }
        }
    }
    func notifySuccess(data: Data) {
        downloadedItem = data
        self.status = .finished
        
        for observer in observers {
            observer.checkDownloadedData(item: downloadedItem!)
        }
        
        for blockNotifier in blockObservers {
            blockNotifier.success(data)
        }
        closeResources()
    }
    
    func notifyFailure(error: Error)
    {
        self.status = .failed
        for observer in observers {
            observer.downloadFailure(forUrl: url, error: error)
        }
        for blockNotifier in blockObservers {
            blockNotifier.error(error)
        }
        closeResources()
    }
    
    func closeResources() {
        observers.removeAll()
        blockObservers.removeAll()
    }
}

class ClosureNotifier: NSObject {
    var success: (Data) ->()
    var error: (Error?) ->()
    init(success: @escaping (Data) ->(), error: @escaping (Error?) ->()) {
        self.success = success
        self.error = error
    }
}
