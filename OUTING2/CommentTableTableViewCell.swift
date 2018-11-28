//
//  CommentTableTableViewCell.swift
//  OUTING2
//
//  Created by 吉澤 康太 on 2017/12/05.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//

import UIKit
import NCMB

class CommentTableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userProfileImage.layer.cornerRadius = userProfileImage.layer.bounds.width/2
        userProfileImage.clipsToBounds = true
        
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}





