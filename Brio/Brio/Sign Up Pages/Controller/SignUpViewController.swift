//
//  SignUpViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/07/21.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB

// UITextFieldDelegate（デリゲート）をもちいるためにSignUpViewControllerはUITextFieldDelegatewを継承する
class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var displayNameTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameTextField.delegate = self
        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        confirmField.isSecureTextEntry = true
        
        // textFieldの境界線をつける
        [displayNameTextField, userIdTextField, emailTextField, passwordTextField, confirmField].forEach { (textField) in
            textField?.layer.borderColor = UIColor.black.cgColor
            textField?.layer.borderWidth = 1.0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUp() {
        let user = NCMBUser()
        
        // ８文字以下なら処理を途中でやめる
        if userIdTextField.text!.count < 8 {
            print("文字数不足")
            return
        }
        
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if passwordTextField.text == confirmField.text {
            user.password = passwordTextField.text!
        } else {
            print("パスワードの不一致")
            return
        }
        
        user.signUpInBackground { (error) in
            if error != nil {
                print(error)
            } else {
                let storyboard  = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier:
                    "RootTabBarController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
            }
        }
        
    }
}
