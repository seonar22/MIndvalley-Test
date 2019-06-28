import UIKit

class PinTableViewController: UITableViewController {
    private let notificationName = Notification.Name("pinsReceived")
    var pins = [PinterestItem]()
    let pinsDChecker = PinDownloadChecker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PinCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PinCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 250;
        tableView.estimatedRowHeight = 250;
        tableView.tableFooterView = UIView()
        
        pinsDChecker.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: notificationName, object: nil)
    }
    @objc func updateUI(_ notification: NSNotification) {
        if let error = notification.userInfo?["error"] as? NSError {
            Helper.displayAlert(title: "Error", message: "Failed with error \(error.localizedDescription)", inViewController: self)
            return
        }
        pins = pinsDChecker.pins
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension PinTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinCell
        let pin = pins[indexPath.row]
        cell.pinImageView.image = UIImage(named: "placeholder")
        if pin.urls?.small != nil {
            Downloader.shared.download(url: (pin.urls?.small)!, success: { (data) in
                let image = UIImage(data: data)
                guard image != nil else {return}
                DispatchQueue.main.async {
                    cell.pinImageView.image = image
                }
            }, error: { (error) in
                Helper.displayAlert(title: "Pin download error!", message: "Downloading one of pins results in error!", inViewController: self)
            })
        }
        cell.caption.text = pin.user?.name ?? "Anonymous"
        return cell
    }
}
