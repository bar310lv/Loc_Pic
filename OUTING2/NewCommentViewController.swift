////
////  NewCommentViewController.swift
////  OUTING2
////
////  Created by 吉澤康太 on 2017/12/11.
////  Copyright © 2017年 吉澤 康太. All rights reserved.
////
//
import UIKit
import NCMB

class NewCommentViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentText: UITextView!
    
//Commentクラスを作成してPostIdで指定
    
    var text :String = ""
    var currentUser = NCMBUser.currentUser()
    var pImage :UIImage!
    
    var lm:CLLocationManager!
    var longtitude :CLLocationDegrees!
    var latitude :CLLocationDegrees!
    var addressStinrg: String = ""
    var numberOfLikes:Int! = 0
    var targetPostObjectId:String!
    var objectid: String!
    var PostId: String!
    var newArray:NCMBObject = NCMBObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PostId = newArray.objectId
        
        print(PostId)
        
        let query = NCMBQuery(className: "user")
        query.orderByAscending("createDate")
        query.findObjectsInBackgroundWithBlock { (NSArray objects, NSError error) -> Void in
            if (error != nil){
                print("検索に失敗しました1")
            }else{
                self.objectid = self.currentUser.objectId
                print(self.objectid)
                
                
                
                let obj2 :NCMBObject = NCMBObject(className: "user")
                obj2.objectId = self.objectid
                obj2.fetchInBackgroundWithBlock({ (error) -> Void in
                    if(error != nil){
                        print("検索に失敗しました2")
                    }else{
                        print("検索成功")
                        print(obj2.objectId)
                        let filename1: String = (obj2.objectForKey("profileImage") as? String)!
                        let fileData1 = NCMBFile.fileWithName(filename1, data: nil) as! NCMBFile
                        
                        fileData1.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                            
                            if error != nil{
                                print("写真の取得失敗")
                            }else{
                                
                                self.profileImage.image = UIImage(data: imageData!)
                                
                            }
                            
                        }
                    }
                })
                
            }
        }


        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.barTintColor = UIColor(hex:"ffA500")
        
        commentText.text = ""
        commentText.becomeFirstResponder()
        
        usernameLabel.text = currentUser.userName        
        
        profileImage.layer.cornerRadius = profileImage.layer.bounds.width/2
        profileImage.clipsToBounds = true
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        
        commentText.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func commentButtonClicked(sender: AnyObject) {
        
        
        if commentText.text.isEmpty{
            
        }else{
            
            let image: UIImage! = self.profileImage.image
            
            
            //createdAt表示用
            let now = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let string = formatter.stringFromDate(now)
            
            var saveError : NSError? = nil
            let obj: NCMBObject = NCMBObject(className: "Comment")
            
            obj.setObject(self.currentUser.userName, forKey: "userName")
            obj.setObject(self.commentText.text, forKey: "commentText")
            obj.setObject(string, forKey: "Date")
            obj.setObject(PostId, forKey: "targetPostObjectId")
            
            let name = self.currentUser.userName
            
            let fileName = "\(name).jpg"
            let pngData = NSData(data: UIImagePNGRepresentation(image)!)
            let file = NCMBFile.fileWithName(fileName, data: pngData) as! NCMBFile
            
            // ACL設定（読み書き可）
            let acl = NCMBACL()
            acl.setPublicReadAccess(true)
            acl.setPublicWriteAccess(true)
            
            obj.setObject(file.name, forKey: "profileImage")
            obj.save(&saveError)
            
            
            //ファイルはバックグラウンド実行をする
            file.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                
            })
            
            self.commentText.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
            
            if saveError == nil {
                print("success save data.")
            } else {
                print("failure save data. \(saveError)")
            }

        }
        
    }

}