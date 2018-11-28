//
//  PostinCommentTableViewCell.swift
//  OUTING2
//
//  Created by 吉澤 康太 on 2017/12/05.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//

import UIKit
import NCMB

class PostinCommentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var likeButton: DesignableButton!

    var currentUserDidLike: Bool = false
    var numberOfLikes :Int!
    
    var userDidLike :String!
    
    var targetPostObjectID: String!
    
    let obj :NCMBObject = NCMBObject(className: "Post")
    var objectid :String!
    var saveError: NSError? = nil

    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.layer.bounds.width/2
        profileImage.clipsToBounds = true
        
        
    }
    
    
    @IBAction func likeButtonClicked(sender: DesignableButton) {
        
        
        
        
        obj.objectId = self.objectid
        print(numberOfLikes)
        
        obj.fetchInBackgroundWithBlock { (error) -> Void in
            if(error == nil){
                
                if (self.currentUserDidLike == false){
                    self.numberOfLikes = self.numberOfLikes + 1
                    self.obj.setObject(self.numberOfLikes, forKey: "numberOfLikes")
                    self.obj.save(&self.saveError)
                    self.currentUserDidLike = true
                    self.likeButton.tintColor = UIColor.orangeColor()
                    
                    self.likeButton.setTitle("\(self.numberOfLikes) Useful", forState: .Normal)
                    
                }else{
                    
                    self.numberOfLikes = self.numberOfLikes - 1
                    self.obj.setObject(self.numberOfLikes, forKey: "numberOfLikes")
                    self.likeButton.tintColor = UIColor.orangeColor()
                    self.obj.save(&self.saveError)
                    
                    self.currentUserDidLike = false
                    
                    self.likeButton.setTitle("\(self.numberOfLikes) Useful", forState: .Normal)
                }
                
                
            }else{
                print("取得失敗")
            }
            
        }

        //アニメーション
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
        
        
    }
    
    
}
