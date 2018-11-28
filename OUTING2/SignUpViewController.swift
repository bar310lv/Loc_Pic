//
//  SignUpViewController.swift
//  SwiftLoginApp
//
//  Created by 吉澤 康太 on 2017/10/27.
//  Copyright © 2017年 吉澤 康太. All rights reserved.
//

import UIKit
import NCMB
import Photos

class SignUpViewController: UIViewController {
    // User Name
    @IBOutlet weak var userNameTextField: UITextField!
    // Password
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField_second: UITextField!
    
    // errorLabel
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var profileImageEx :UIImage!
    
    // 画面表示時に実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        // Passwordをセキュリティ入力に設定
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField_second.secureTextEntry = true
        
        
        
    }
    
    // SignUpボタン押下時の距離
    @IBAction func signUpBtn(sender: UIButton) {
        // キーボードを閉じる
        closeKeyboad()
        
        // 入力確認
        if self.userNameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty || self.passwordTextField_second.text!.isEmpty || self.profileImage.image == nil || self.profileImage.image ==  "defaultProfileImage" {
            self.errorLabel.text = "未入力の項目があります"
            // TextFieldを空に
            self.cleanTextField()
            
            return
            
        } else if passwordTextField.text! != passwordTextField_second.text! {
            self.errorLabel.text = "Passwordが一致しません"
            // TextFieldを空に
            self.cleanTextField()
            
            return
            
        }
        
        //NCMBUserのインスタンスを作成
        let user :NCMBUser = NCMBUser(className: "user")
        var saveError: NSError? = nil
        //ユーザー名を設定
        //パスワードを設定
        user.setObject(self.userNameTextField.text, forKey: "userName")
        user.setObject(self.passwordTextField.text, forKey: "password")
        let name = self.userNameTextField.text!
        let image: UIImage! = self.profileImage.image
        let fileName = "\(name).jpg"
        let pngData = NSData(data: UIImagePNGRepresentation(image)!)
        let file = NCMBFile.fileWithName(fileName, data: pngData) as! NCMBFile
        
        let acl = NCMBACL()
        acl.setPublicReadAccess(true)
        acl.setPublicWriteAccess(true)
        file.ACL = acl
        user.setObject(file.name, forKey: "profileImage")
        user.save(&saveError)
        

        //会員の登録を行う
        file.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
            
        })
        
        self.cleanTextField()
        self.performSegueWithIdentifier("signUp", sender: self)
        
        if saveError == nil {
            print("ログインに成功しました。")
        } else {
            print("ログインに失敗しました。 \(saveError)")
        }
    }
    
    // 背景タップするとキーボードを隠す
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
    }
    
    // TextFieldを空にする
    func cleanTextField(){
        userNameTextField.text = ""
        passwordTextField.text = ""
        passwordTextField_second.text = ""
        profileImage.image = nil
        
    }
    
    // errorLabelを空にする
    func cleanErrorLabel(){
        errorLabel.text = ""
        
    }
    
    // キーボードを閉じる
    func closeKeyboad(){
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordTextField_second.resignFirstResponder()
        profileImage.resignFirstResponder()
        
    }
    
}




extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
                        self.profileImageEx = images[0]
                        self.profileImage.image = self.profileImageEx
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
        self.profileImage.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}






