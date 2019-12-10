//
//  MyPageViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/07/31.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB

class MyPageViewController: UIViewController {
    
    //  変数の宣言
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    /*  viewDidLoad＝ViewControllerのviewがリロードされた後に呼び出される、
        つまり立ち上げたときに最初に開かれる画面  */
    /*  InterfaceBuilder(Storyboardやxib)を使用している場合、
        サブビューのセットアップは一般的にここで行うことになる  */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  ImageViewを丸くする
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        //  ImageViewのサイズ比率そのままで、ImageViewに空白ができないように表示する
        //  ImageViewと画像の比率が違う場合、ImageViewをはみ出す
        //  画像の中心とImageViewの中心は同じになる
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true

    }
    
        //  viewWillAppear＝viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  名前や自己紹介文を表示
        if let user = NCMBUser.current() {
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroductionTextView.text = user.object(forKey: "introduction") as? String
            self.navigationItem.title = user.userName
            
            //  ユーザー画像を取得して表示
            let file = NCMBFile.file(withName: user.objectId + ".png", data: nil) as!
            NCMBFile
            file.getDataInBackground { (data,error) in
                if error != nil {
                    print(error)
                    self.userImageView.image =  UIImage(named: "placeholder-human")
                } else {
                    if data != nil {
                        
                        //  guard文は条件を満たさない場合の処理を記述する構文
                        //  条件を満たさない場合には、スコープを抜けるための処理を書く必要がある
                        //  return メソッドなどで処理を終了し、呼び出し元に戻る
                        guard let image = UIImage(data: data!) else { return }
                        self.userImageView.image = image
                        print("データ取得")
                    } else {
                        self.userImageView.image =  UIImage(named: "placeholder-human")
                    }
                }
            }
        } else {
            
            //  サインインの画面に飛ぶ
            let storyboard  = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier:
                "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showEditProfile(){
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "EditUserInfoViewController") as! EditUserInfoViewController
        controller.delegate = self
        let navi = UINavigationController(rootViewController: controller)
        self.present(navi, animated: true, completion: nil)
    }
    
    @IBAction func showMenu() {
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default)
        { (action) in
            NCMBUser.logOutInBackground { (error) in
                if error != nil {
                    print(error)
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
        }

        
        let deleteAction = UIAlertAction(title: "退会", style: .default)
        { (action) in
            let user = NCMBUser.current()
            user?.deleteInBackground({ (error) in
            if error != nil {
                print(error)
                } else {
                let storyboard  = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier:
                "RootNavigationController")
                 
                
                let ud = UserDefaults.standard
                ud.set(false, forKey: "isLogin")
                ud.synchronize()
                }})
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style:.cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension MyPageViewController: EditUserInfoViewControllerDelegate {
    func refreshUserInfo(image: UIImage?, userName: String?, introduction: String?) {
        if image != nil {
            self.userImageView.image = image
        }
        if userName != nil {
            self.userDisplayNameLabel.text = userName
        }
        if introduction != nil {
            self.userIntroductionTextView.text = introduction
        }
    }
}


