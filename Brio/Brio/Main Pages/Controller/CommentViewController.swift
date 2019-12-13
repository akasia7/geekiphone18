//
//  CommentViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/15.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var postId: String!
    
    var comments = [Comment]()
    var user:[NCMBUser] = []
    
    @IBOutlet var commentTableView: UITableView!
    
    /*  viewDidLoad＝ViewControllerのviewがリロードされた後に呼び出される、
     つまり立ち上げたときに最初に開かれる画面  */
    /*  InterfaceBuilder(Storyboardやxib)を使用している場合、
     サブビューのセットアップは一般的にここで行うことになる  */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.dataSource = self
        
        commentTableView.tableFooterView = UIView()
        
        commentTableView.estimatedRowHeight = 80
        
        commentTableView.rowHeight = UITableView.automaticDimension
        
        loadComments()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell")!
        let userImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let commentLabel = cell.viewWithTag(3) as! UILabel
        // ユーザー画像を丸く
        userImageView.layer.cornerRadius = 22.0
        userImageView.layer.masksToBounds = true
        userImageView.clipsToBounds = true
        
        let user = comments[indexPath.row].user
        //let userImagePath = "https://mbaas.api.nifcloud.com/2013-09-01/applications/HlgrPhqq9ECHzZT3/publicFiles/"  + user.objectId
        
        let currentUser = self.user[indexPath.row]
        guard let userImagePath = currentUser.object(forKey: "imageUrl") as? String else {
            return cell
        }
        let url = URL(string:userImagePath)
        userImageView.kf.setImage(with: url)
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text
        
        return cell
    }
    
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        query?.findObjectsInBackground({[weak self] (result, error) in
            guard let self = self else { return }
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.user = []
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    self.user.append(user)
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    
                    // Commentクラスに格納
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
        })
    }
    
    @IBAction func addComment() {
        let alert = UIAlertController(title: "コメント", message: "コメントを入力して下さい", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            SVProgressHUD.show()
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            object?.saveInBackground({ (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                    self.loadComments()
                }
            })
        }
        
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        self.present(alert, animated: true, completion: nil)
    }
}

