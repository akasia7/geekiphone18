//
//  SignInViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/07/31.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB

class SignInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signIn() {
        
        if (userIdTextField.text?.count)! > 0 &&
            (passwordTextField.text?.count)! > 0  {
            
            NCMBUser.logInWithUsername(inBackground: userIdTextField.text!, password: passwordTextField.text!) { (user,error) in
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
    
    @IBAction func forgetPassword() {
        
    }
    
}

