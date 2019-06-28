import UIKit
import SwiftyJSON

class PinDownloadChecker: DownloadChecker {
    
    let notificationName = Notification.Name("pinsReceived")
    
    var pins = [PinterestItem]()
    
    func start() {
        Downloader.shared.download(url: "https://pastebin.com/raw/wgkJgazE", checker: self)
        pins.removeAll(keepingCapacity: false)
    }
    
    func checkDownloadedData(item: Data)
    {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        let results = JSON(item)
        guard results.array != nil else{return}
        
        for object in results.array! {
            let item = PinterestItem.init(json: object)
            self.pins.append(item)
        }
        
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    func downloadFailure(forUrl url: String, error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let userInfo:[String: Error] = ["error": error]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
    
}
