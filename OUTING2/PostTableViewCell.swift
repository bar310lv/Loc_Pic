//
//  PostTableViewCell.swift
//  OUTING2
//
//  Created by 吉澤 康太 on 2017/11/04.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//

import UIKit
import NCMB
import CoreLocation

class PostTableViewCell: UITableViewCell,CLLocationManagerDelegate {
    
    //post data
    
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var likeButton: DesignableButton!
    
    var numberOfLikes :Int!

    var userDidLike :String!
    
    var currentUserDidLike: Bool = false
    var targetPostObjectID: String!
    
    let obj :NCMBObject = NCMBObject(className: "Post")
    var objectid :String!
    var saveError: NSError? = nil
    
    private func updateUI(){
        
        
        //画像を丸める
        self.postImage.layer.borderColor = UIColor.orangeColor().CGColor
        self.postImage.layer.borderWidth = 5
        
        userProfilePic.layer.cornerRadius = userProfilePic.layer.bounds.width/2
        postImage.layer.cornerRadius = 5.0
        
        userProfilePic.clipsToBounds = true
        postImage.clipsToBounds = true


        
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func userDidLike(sender: DesignableButton) {
        
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
                    self.likeButton.tintColor = UIColor.lightGrayColor()
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
