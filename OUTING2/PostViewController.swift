//
//  PostViewController.swift
//  OUTING2
//
//  Created by 吉澤 康太 on 2017/12/04.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//

import UIKit
import Photos
import NCMB
import CoreLocation
import MapKit

class PostViewController: UIViewController,CLLocationManagerDelegate{

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!

    private var PostImage: UIImage!
    private var label: UILabel!


    // Label

    var text :String = ""
    var currentUser = NCMBUser.currentUser()
    var createDate = NCMBObject(className: "Post")
    var locationManager: CLLocationManager!
    var myLocation: CLLocation!
    var pImage :UIImage!
    
    var lm:CLLocationManager!
    var longtitude :CLLocationDegrees!
    var latitude :CLLocationDegrees!
    var addressStinrg: String = ""
    var numberOfLikes:Int! = 0
    var targetPostObjectId:String!
    var objectid: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        lm = CLLocationManager()
        lm.delegate = self
        
        
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
                                
                                self.userProfileImage.image = UIImage(data: imageData!)
                                
                            }
                            
                        }
                    }
                })

            }
        }
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.NotDetermined {
            print("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示
            self.lm.requestAlwaysAuthorization()
        }
        
        self.lm.delegate = self
        self.lm.desiredAccuracy = kCLLocationAccuracyBest
        self.lm.distanceFilter = 100
        self.lm.startUpdatingLocation()
        
        //UI変更
        
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.barTintColor = UIColor(hex:"ffA500")
        
        userProfileImage.layer.cornerRadius = userProfileImage.layer.bounds.width/2
        userProfileImage.clipsToBounds = true
        
        postText.text = ""
        postText.becomeFirstResponder()
        
        usernameLabel.text = currentUser.userName
        
        
        //notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        
        self.getGeoLocation(locationManager)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        locationManager.startUpdatingLocation()
    }
    
    
    func getGeoLocation(manager: CLLocationManager){
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0] as CLPlacemark
                self.displayLocationInfo(placemark)

            } else {
                print("error")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark)->String {
        
        addressStinrg = " "
        addressStinrg += placemark.subLocality != nil ? placemark.subLocality! : ""
        addressStinrg += ","
        addressStinrg += placemark.locality != nil ? placemark.locality! : ""
        addressStinrg += ","
        addressStinrg += placemark.administrativeArea != nil ? placemark.administrativeArea! : ""
        return addressStinrg
        
    }
    
    override func viewDidDisappear(animated: Bool) {
    
        super.viewDidDisappear(animated)
    }


    func resize (image: UIImage, width: Int, height: Int) -> UIImage {
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        //初期化
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func keyboardWillHide(notification: NSNotification){
        
        self.postText.contentInset = UIEdgeInsetsZero
        self.postText.scrollIndicatorInsets = UIEdgeInsetsZero
        
        
    }

    func keyboardWillShow(notification: NSNotification){
        //ユーザーのiフォンを読み取り
        let userInfo = notification.userInfo ?? [:]
        //キーボードサイズを取ってくる
        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
        self.postText.contentInset = UIEdgeInsets(top:0, left:0, bottom: keyboardSize.height+10, right: 0)
        self.postText.scrollIndicatorInsets = self.postText.contentInset
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //緯度経度
        self.latitude = manager.location!.coordinate.latitude;
        self.longtitude = manager.location!.coordinate.longitude;
        
    }


    @IBAction func backButtonClicked(sender: AnyObject) {
        
        postText.resignFirstResponder()
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }

    //POST BUTTON 

    @IBAction func postButtonClicked(sender: AnyObject) {
    
        self.text = self.postText.text
        
        if PostImage == nil {
            
        } else if postText.text.isEmpty {
            
        } else {
        
            if lm == nil {
                print("位置情報が取得できていません")
            } else {
                print("位置情報が取得できました\(addressStinrg)")
                
            
                let image1 :UIImage! = self.userProfileImage.image
                let image: UIImage! = self.postImage.image
            // 画像をリサイズする
            let imageW : Int = Int(image.size.width*0.2)
            let imageH : Int = Int(image.size.height*0.2)
            let resizeImage = resize(image, width: imageW, height: imageH)
                
                // 画像をリサイズする
            let imageW1 : Int = Int(image1.size.width*0.2)
            let imageH1 : Int = Int(image1.size.height*0.2)
            
            let resizeImage1 = resize(image1, width: imageW1, height: imageH1)
            
            //createdAt表示用
                let now = NSDate()
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let string = formatter.stringFromDate(now)
                
                
                //保存ネーム用
                let nowEx = NSDate()
                let formatterEx = NSDateFormatter()
                formatterEx.dateFormat = "yyyyMMddHHmmss"
                let stringEx = formatterEx.stringFromDate(nowEx)

                var saveError: NSError? = nil
                
                let obj: NCMBObject = NCMBObject(className: "Post")
                obj.setObject(self.currentUser.userName, forKey: "userName")
                obj.setObject(self.text, forKey: "postText")
                obj.setObject(string, forKey: "Date")
                obj.setObject(addressStinrg, forKey: "address")
                obj.setObject(numberOfLikes, forKey: "numberOfLikes")
                
                
                let name = self.currentUser.userName
                
                let fileName1 = "\(name).jpg"
                let pngData1 = NSData(data: UIImagePNGRepresentation(resizeImage1)!)
                let file1 = NCMBFile.fileWithName(fileName1, data: pngData1) as! NCMBFile
                
                let fileName = "\(name)\(stringEx).jpg"
                let pngData = NSData(data: UIImagePNGRepresentation(resizeImage)!)
                let file = NCMBFile.fileWithName(fileName, data: pngData) as! NCMBFile
                
                
                
                // ACL設定（読み書き可）
                let acl = NCMBACL()
                acl.setPublicReadAccess(true)
                acl.setPublicWriteAccess(true)
                file.ACL = acl
                obj.setObject(file1.name, forKey: "profileImage")
                obj.setObject(file.name, forKey: "filename")
                obj.save(&saveError)
                
                
                //ファイルはバックグラウンド実行をする
                file.saveInBackgroundWithBlock({ (error: NSError!) -> Void in

                })
                self.postText.resignFirstResponder()
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
            }
        }
    }
}


extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBAction func picFeaturedImage(sender: AnyObject) {
        //ユーザーのフォトライブラリへのアクセス許可
        let authorization = PHPhotoLibrary.authorizationStatus()
        if authorization == .NotDetermined{
            
            //許可リクエスト通知
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.picFeaturedImage(sender)
                })
                })
            
            return
        }
        //許可された場合
        if authorization == .Authorized{
            
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title:NSLocalizedString("Take aPhoto or Video!",  comment: "ActionTitle"),secondaryTitle: NSLocalizedString("Use this one!", comment: "ActionTitle"), handler: {(_) -> () in
                self.presentCamera()
                
            }, secondaryHandler: {(action, numberOfPhoto) -> () in
                    
                    controller.getSelectedImagesWithCompletion({(images) -> Void in
                        self.PostImage = images[0]
                        self.postImage.image = self.PostImage
                    })
            }))
            
            
            controller.addAction(ImageAction(title:NSLocalizedString("Cancel", comment: "ActionTitle"), style: .Cancel, handler: nil))
            
            presentViewController(controller, animated: true, completion: nil)
            
        }
    }

    func presentCamera(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        //カメラ発動
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        //写真が出てくる
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
         self.postImage.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
