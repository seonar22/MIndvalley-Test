import UIKit

class PinCell: UITableViewCell {
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
