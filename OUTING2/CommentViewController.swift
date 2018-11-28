//
//  CommentViewController.swift
//  OUTING2
//
//  Created by 吉澤 康太 on 2017/12/05.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//
//

import UIKit
import NCMB

class CommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var newButton: ActionButton!
    
    var Commenting: NSArray = NSArray()
    var currentUser :String = ""
    var createDate :String = ""
    var postText :String = ""
    var postimage:UIImage!
    var userprofileimage:UIImage!
    var numberoflikes:Int!
    var newArray :NCMBObject = NCMBObject()
    var newArray2 :NCMBObject = NCMBObject()
    var targetPostObjectId :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetPostObjectId = newArray.objectId
        tableView.delegate = self
        tableView.dataSource = self
        
        print("この投稿のobjectID:\(targetPostObjectId)")
        
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "ffa500")
        
        let nib = UINib(nibName: "PostinCommentTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "postInCommentCell")
        
        let nib2 = UINib(nibName: "CommentTableTableViewCell", bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: "commentCell")
        
        createNewButton()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "New Comment Composer"){
            let segue:NewCommentViewController = segue.destinationViewController as! NewCommentViewController
            
            segue.newArray = self.newArray
            
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //tableviewに反映
    func fetchComments(){
        
        //データストア検索
        
        let query: NCMBQuery = NCMBQuery(className: "Comment")
        query.whereKey("targetPostObjectId", equalTo: targetPostObjectId)
        query.orderByAscending("createDate")
        query.findObjectsInBackgroundWithBlock ({ (NSArray objects2, NSError error) in
            
            if (error != nil){
                print("検索に失敗しました。")
            }else{
                self.Commenting = objects2
                //テーブルビューをリロードする
                self.tableView.reloadData()
                
            }
        })
    }
    
    private func createNewButton(){
        
        newButton = ActionButton(attachedToView: self.view, items: [])
        newButton.action = { button in
            print("Post Button Pressed")
            
            self.performSegueWithIdentifier("New Comment Composer", sender: nil)
            
        }
        
        
        newButton.backgroundColor = UIColor(hex: "ffa500")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("postInCommentCell") as? PostinCommentTableViewCell
            
            
            
            let obj2 :NCMBObject = NCMBObject(className: "Post")
            self.targetPostObjectId = newArray.objectForKey("objectId") as! String
            obj2.objectId = self.targetPostObjectId
            obj2.fetchInBackgroundWithBlock({ (error) -> Void in
                if(error != nil){
                    print("検索に失敗しました")
                }else{
                    self.numberoflikes = obj2.objectForKey("numberOfLikes") as? Int
                    print("検索成功")
                    cell!.likeButton.setTitle("\(self.numberoflikes) Useful", forState: .Normal)
                }
            })
            
            
            cell!.usernameLabel.text = newArray.objectForKey("userName") as? String
            cell!.postText.text = newArray.objectForKey("postText") as? String
            cell!.createdAt.text = newArray.objectForKey("Date") as? String
            cell!.location.text = newArray.objectForKey("address") as? String
            cell!.objectid = newArray.objectForKey("objectId") as? String
            cell!.numberOfLikes = newArray.objectForKey("numberOfLikes") as? Int
            cell!.postImage.image = nil
            cell!.profileImage.image = nil
            
            cell!.likeButton.tintColor = UIColor.orangeColor()
            
            let filename: String = (newArray.objectForKey("filename") as? String)!
            let fileData = NCMBFile.fileWithName(filename, data: nil) as! NCMBFile
            let filename1: String = (newArray.objectForKey("profileImage") as? String)!
            let fileData1 = NCMBFile.fileWithName(filename1, data: nil) as! NCMBFile
            
            fileData1.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                
                if error != nil{
                    print("写真の取得失敗")
                }else{
                    
                    cell!.profileImage.image = UIImage(data: imageData!)
                    
                }
                
            }
            
            
            fileData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                
                if error != nil{
                    print("写真の取得失敗")
                }else{
                    
                    cell!.postImage.image = UIImage(data: imageData!)
                    
                }
                
            }
            
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cell!.accessoryType = UITableViewCellAccessoryType.None
            
            
            return cell!
            
            
        }else{
            
            let cell1 = tableView.dequeueReusableCellWithIdentifier("commentCell") as? CommentTableTableViewCell
            
            let targetData: AnyObject = self.Commenting[indexPath.row - 1]
            
            print("targetData: \(targetData)")
            
            //            //なぜかデータが格納されない（1/21）
            
            cell1!.usernameLabel.text = targetData.objectForKey("userName") as? String
            cell1!.commentLabel.text = targetData.objectForKey("commentText") as? String
            cell1!.createdAt.text = targetData.objectForKey("Date") as? String
            
            cell1!.userProfileImage.image = nil
            
            
            let filename1: String = (targetData.objectForKey("profileImage") as? String)!
            let fileData1 = NCMBFile.fileWithName(filename1, data: nil) as! NCMBFile
            
            fileData1.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                
                if error != nil{
                    print("写真の取得失敗")
                }else{
                    
                    cell1!.userProfileImage.image = UIImage(data: imageData!)
                    
                }
                
            }
            
            
            cell1!.selectionStyle = UITableViewCellSelectionStyle.None
            cell1!.accessoryType = UITableViewCellAccessoryType.None
            
            
            return cell1!
            
            
        }
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Commenting.count + 1)
        
    }
    
}