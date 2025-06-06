//
//  WiFiDownloadViewCell.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/8/22.
//

import UIKit
import GTProgressBar

class WiFiDownloadViewCell: UITableViewCell {

    @IBOutlet var thumbImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressBar: GTProgressBar!
    
    var file: [String: Any] = [:] {
        didSet {
            self.nameLabel.text = file["name"] as? String
            self.progressBar.progress = CGFloat(file["progress"] as! Double)
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            self.progressBar.progress = progress
        }
    }
    
    var index: Int = 0
    
    var thumbnail: UIImage? {
        didSet {
            self.thumbImageView.image = thumbnail
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
