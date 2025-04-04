//
//  PostCell.swift
//  ios101-project5-tumblr
//
//  Created by Andry on 4/4/25.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
        // Configure the label
        summaryLabel.textColor = .black    // Choose a visible color
        summaryLabel.numberOfLines = 0   
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
