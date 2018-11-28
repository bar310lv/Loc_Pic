//
//  ViewController.swift
//  OUTING2
//
//  Created by 吉澤 康太 on 2017/10/27.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//

import UIKit
import NCMB
import CoreLocation

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    
    //APIではなく自前の配列
    
    var Posting:NSArray = NSArray() //[Post]()
    private var newButton:ActionButton!
    var locationManager :CLLocationManager!
    var likebutton :PostTableViewCell = PostTableViewCell()
    var numberOfLikes :Int!
    var targetPostObjectId:String!
    var objectid: String!
    //セグエの実行時に値を渡す
    var targetData: NCMBObject = NCMBObject()
    var currentUserDidLike :Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //delegateとdatasourceの初期化
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //高さの設定
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        
        //tableViewへの値の引き渡し
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "postCell")
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "ffa500")
        
        title = "Loc Pic"
        
        createNewButton()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()


        print("didChangeAuthorizationStatus:\(status)")

        if(status == CLAuthorizationStatus.NotDetermined) {

            self.locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    

    //位置情報取得
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        print(manager.location?.coordinate.latitude)
        print(manager.location?.coordinate.longitude)

    }


    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            // 初回のみ許可要求
            locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            // 位置情報許可を依頼するアラートの表示
            alertLocationServiceDisabled()
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            break
        }
    }
    
    // 位置情報許可依頼アラート
    func alertLocationServiceDisabled() {
        let alert = UIAlertController(title: "位置情報が許可されていません", message: "位置情報サービスを有効にしてください", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "設定", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(url)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
        }))
        presentViewController(alert, animated: true, completion: nil)
    }



///////////////////取得/////////////////
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
           fetchPosts()

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //tableviewに反映
    func fetchPosts(){
        
        let query: NCMBQuery = NCMBQuery(className: "Post")
        query.orderByDescending("createDate")
        query.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            
            if (error != nil){
                print("検索に失敗しました。")
            }else{
                self.Posting = objects
                //テーブルビューをリロードする
                self.tableView.reloadData()
            
            }
        })
    }
    
    
    
    private func createNewButton(){
        
        newButton = ActionButton(attachedToView: self.view, items: [])
        newButton.action = { button in
            print("Post Button Pressed")
            
            self.performSegueWithIdentifier("New Post Composer", sender: self)
        }
        
        
        newButton.backgroundColor = UIColor(hex : "ffa500")
    }
    
    //cellの設定
    ///////////////////cellに入れる//////////////////
    ////////////////////////////////////////////////
    ////////////////////////////////////////////////
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostTableViewCell
        
        
        
        
        //PostTableViewCell設定
        //レイアウト設定
        cell!.userProfilePic.layer.cornerRadius = cell!.userProfilePic.layer.bounds.width/2
        
        cell!.userProfilePic.clipsToBounds = true
        cell!.postImage.clipsToBounds = true

        
        //各値をセルに入れる
        let targetData: AnyObject = self.Posting[indexPath.row]
        
        let obj2 :NCMBObject = NCMBObject(className: "Post")
        self.targetPostObjectId = targetData.objectForKey("objectId") as! String
        obj2.objectId = self.targetPostObjectId
        obj2.fetchInBackgroundWithBlock({ (error) -> Void in
            if(error != nil){
                print("検索に失敗しました")
            }else{
                self.numberOfLikes = obj2.objectForKey("numberOfLikes") as? Int
                print("検索成功")
                cell!.likeButton.setTitle("\(self.numberOfLikes) Useful", forState: .Normal)
            }
        })

        print(targetPostObjectId)
        
        cell!.usernameLabel.text = targetData.objectForKey("userName") as? String
        cell!.postText.text = targetData.objectForKey("postText") as? String
        cell!.createdAt.text = targetData.objectForKey("Date") as? String
        cell!.location.text = targetData.objectForKey("address") as? String
        cell!.objectid = targetData.objectForKey("objectId") as? String
        cell!.numberOfLikes = targetData.objectForKey("numberOfLikes") as? Int
        cell!.likeButton.setTitle("\(self.numberOfLikes) Useful", forState: .Normal)
        
        cell!.postImage.image = nil
        cell!.userProfilePic.image = nil
        cell!.likeButton.tintColor = UIColor.orangeColor()
        
        //画像データの取得
        let filename: String = (targetData.objectForKey("filename") as? String)!
        let fileData = NCMBFile.fileWithName(filename, data: nil) as! NCMBFile
        let filename1: String = (targetData.objectForKey("profileImage") as? String)!
        let fileData1 = NCMBFile.fileWithName(filename1, data: nil) as! NCMBFile
        
        fileData1.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            
            if error != nil{
                print("写真の取得失敗")
            }else{
                
                cell!.userProfilePic.image = UIImage(data: imageData!)
                
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
        
        
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Posting.count
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        targetData = self.Posting[indexPath.row] as! NCMBObject
        
        performSegueWithIdentifier("Show Comment Page", sender: nil)
        
        print("cell was tapped")
        
    }
    
    
    
    //データをページ移動の際に一緒に移動させる
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Show Comment Page"){
            
            let segue:CommentViewController = segue.destinationViewController as! CommentViewController
            
            segue.newArray = targetData
            
        }
    }
    
}
