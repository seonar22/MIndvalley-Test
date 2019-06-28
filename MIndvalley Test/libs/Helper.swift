import UIKit

class Helper {
    static func createEmptyDataError() -> NSError {
        let userInfo: [NSObject : AnyObject] =
            [
                NSLocalizedDescriptionKey as NSObject :  NSLocalizedString("Empty Data", value: "Url response was empty", comment: "") as AnyObject,
                NSLocalizedFailureReasonErrorKey as NSObject : NSLocalizedString("Empty Data", value: "Url response was empty", comment: "") as AnyObject
        ]
        let emptyError = NSError(domain: "DownloaderResponseErrorDomain", code: 200, userInfo: userInfo as? [String : Any])
        
        return emptyError
    }
    
    static func displayAlert(title: String, message: String, inViewController controller: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
        })
        controller.present(alert, animated: true) {}
    }
}
