//
//  TableViewCell.swift
//  VkAppTest
//
//  Created by Алексей on 22.11.17.
//  Copyright © 2017 Алексей. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.layer.cornerRadius = mainImageView.frame.size.height / 2
//        mainImageView.contentMode = .scaleAspectFill
        mainImageView.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
