import Foundation

class CacheConfiguration {
    var cacheTimer: TimeInterval = 300
    var maximumItemAmount: Int = 60
    
    class func `default`() -> CacheConfiguration {
        return CacheConfiguration()
    }
}

class Cache {
    private var cachedItems = [String : CachedItem]()
    static let shared = Cache(config: CacheConfiguration.default())
    var config: CacheConfiguration
    var maximumItems: Int
    
    init(config: CacheConfiguration) {
        self.config = config
        self.maximumItems = config.maximumItemAmount
        
        if config.cacheTimer != 0 {
            Timer.scheduledTimer(withTimeInterval: config.cacheTimer, repeats: true) { (timer) in
                self.remove()
            }
        }
    }
    
    func add(url: String, item: Data) {
        var cachedItem = cachedItems[url]
        if cachedItem == nil {
            cachedItem = CachedItem(url: url, item: item)
            cachedItems[url] = cachedItem
        }
    }
    
    func get(url: String) -> Data? {
        return cachedItems[url]?.getItem()
    }
    
    func remove() {
        if cachedItems.count == config.maximumItemAmount {
            var leastRequestedKey: String?
            var leastRequestedTimes: Int = Int.max
            for itemKey in cachedItems.keys {
                
                guard let cacheditem = cachedItems[itemKey],cacheditem.requestedTimes < leastRequestedTimes else{
                    continue
                }
                
                leastRequestedKey = itemKey
                leastRequestedTimes = cacheditem.requestedTimes
            }
            
            if leastRequestedKey != nil {
                cachedItems.removeValue(forKey: leastRequestedKey!)
            }
        }
    }
}

class CachedItem {
    private let url: String
    private let item: Data
    private let createdTime: Date
    private(set) public var requestedTimes: Int = 0
    
    init(url: String, item: Data) {
        self.url = url
        self.item = item
        self.createdTime = Date()
    }
    
    func getItem() -> Data{
        requestedTimes += 1
        return item
    }    
}
