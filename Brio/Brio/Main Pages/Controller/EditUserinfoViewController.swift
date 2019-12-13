//
//  EditUserinfoViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/07/31.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

protocol EditUserInfoViewControllerDelegate {
    func refreshUserInfo(image: UIImage?, userName: String?, introduction: String?)
}

class EditUserInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userBackImageView: UIImageView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var introductionTextView: UITextView!
    
    var delegate: EditUserInfoViewControllerDelegate?
    var imageChangedFlag = false
    var userNameChangedFlag = false
    var introductionChangedFlag = false
    
    var resizedImage: UIImage!
    
    /*  viewDidLoad＝ViewControllerのviewがリロードされた後に呼び出される、
     つまり立ち上げたときに最初に開かれる画面  */
    /*  InterfaceBuilder(Storyboardやxib)を使用している場合、
     サブビューのセットアップは一般的にここで行うことになる  */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        
        userNameTextField.delegate = self
        userIdTextField.delegate = self
        introductionTextView.delegate = self
        
        
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        
        
        
        let userId = NCMBUser.current().userName
        userIdTextField.text = userId
        
        if let user = NCMBUser.current() {
            userNameTextField.text = user.object(forKey: "displayName") as? String
            userIdTextField.text = user.userName
            introductionTextView.text = user.object(forKey: "introduction") as? String
            
            let file = NCMBFile.file(withName: user.objectId + ".png", data: nil) as!
            NCMBFile
            file.getDataInBackground { (data,error) in
                if error != nil {
                    print(error)
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }
        } else {
            let storyboard  = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier:
                "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
        
    }
    
    //  viewWillAppear＝viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let user = NCMBUser.current() else {
            return
        }
        
        let file = NCMBFile.file(withName: user.objectId + ".png", data: nil) as! NCMBFile
        file.getDataInBackground { (data,error) in
            if error != nil {
                print(error)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func textFieldDidChange(){
        userNameChangedFlag = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        introductionChangedFlag = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    //  画像を取り出す
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        SVProgressHUD.show()
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        userImageView.image = selectedImage
        
        //  写真のサイズを小さくする
        let resizedImage = selectedImage.scaleImage(scaleSize: 0.1)
        
        
        picker.dismiss(animated: true, completion: nil)
        
        //  imageViewをデータ型に変える
        let data = resizedImage.pngData()
        //  NCMBファイルに変換してアップロードする
        let file = NCMBFile.file(withName: NCMBUser.current().objectId + ".png", data: data) as! NCMBFile
        file.saveInBackground({ (error) in
            SVProgressHUD.dismiss()
            if error != nil {
                print(error?.localizedDescription)
            } else {
                self.userImageView.image = selectedImage
            }
        }) { (progress) in
            print(progress)
        }
        imageChangedFlag = true
    }
    
    
    @IBAction func selectImage() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用できません")
            }
            
        }
        
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            
            //  アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用できません")
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion:  nil)
    }
    
    @IBAction func closeEditViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUserInfo() {
        let user = NCMBUser.current()
        
        
        user?.setObject(userNameTextField.text, forKey: "displayName")
        user?.setObject(userIdTextField.text, forKey: "userName")
        user?.setObject(introductionTextView.text, forKey: "introduction")
        user?.saveInBackground( { (error) in
            if error != nil {
                print(error)
            } else {
                var newImage: UIImage?
                var newName: String?
                var newIntroduction: String?
                if self.imageChangedFlag {
                    newImage = self.userImageView.image
                    self.userImageView.setNeedsLayout()
                }
                if self.userNameChangedFlag {
                    newName = self.userNameTextField.text
                }
                if self.introductionChangedFlag {
                    newIntroduction = self.introductionTextView.text
                }
                self.dismiss(animated: true, completion: nil)
                self.delegate?.refreshUserInfo(image: newImage, userName: newName, introduction: newIntroduction)
            }
            
        })
    }
}
