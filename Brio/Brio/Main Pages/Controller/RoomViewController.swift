//
//  ViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/07/21.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD

//  クラス = 変数と関数をまとめたもの
//  データをまとめて１つのオブジェクト（もの）として扱える
//  特徴を引き継ぐことができる（継承）
//  クラスをもとに実態（インスタンス）が作成される
//  例）クラス＝「歌手」、インスタンス＝「あいみょん」
class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RoomTableViewCellDelegate {
    
    //  使用するデータの宣言
    var room: Room!
    
    var selectedPost: Post?
    
    //  投稿内容の配列を作っている
    var posts = [Post]()
    
    //  IB＝「プログラムから命令を受け取るパーツ」
    //  nil（空の値）を代入できる型 = Optional型
    //  ！や？をつけるとOptional型になる
    //  ！＝「一旦はnilに値がなくてもいいが、最終的に値が入っていないといけない」
    //  ？＝「nilが許容される」
    //  アンラップは値を取り出す行為　print(number!)
    //  予期しないnil(空)の状態が見つかるエラーは、関連づけがされてない場合がある
    //  中身がnilのOptional型の変数をアンラップするとエラーが発生する
    @IBOutlet var RoomTableView: UITableView!
    
    /*  viewDidLoad＝ViewControllerのviewがリロードされた後に呼び出される、
     つまり立ち上げたときに最初に開かれる画面  */
    /*  InterfaceBuilder(Storyboardやxib)を使用している場合、
     サブビューのセットアップは一般的にここで行うことになる  */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RoomTableView.dataSource = self
        RoomTableView.delegate = self
        
        //  RoomTableViewCellを呼び出す
        let nib = UINib(nibName: "RoomTableViewCell", bundle: Bundle.main)
        RoomTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //  余計な線を消す
        RoomTableView.tableFooterView = UIView()
        
        RoomTableView.rowHeight = 200
        
        
        setRefreshControl()
        
        loadTimeline()
        
        
    }
    
    //  画像ファイルなど使用している大きなメモリファイルを解放する
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
        }
        if segue.identifier == "toTimeline" {
            let navi = segue.destination as! UINavigationController
            let controller = navi.children.first as! AddPostViewController
            
        }
        
    }
    
    //  tableViewを表示するセルの数
    /*  Int型は整数、Double型は少数、String型は文字列、Char型は文字（記号としての一文字）
     Bool型は真と偽を扱う  */
    //  型の変換を「キャスト」という
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    //  セルの表示内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //  登録したセルを呼び出している
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RoomTableViewCell
        
        /*  postsというデータのまとまりの中から、textやuserNameといったデータを上から
         順番に持ってきてる  */
        //  ?をつけると＝「nilが許容される」
        cell.contentLabel?.text = posts[indexPath.row].text
        
        let user = posts[indexPath.row].user
        
        cell.userNameLabel.text = user.displayName
        
        let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/HlgrPhqq9ECHzZT3/publicFiles/VKD52cVhRFPhLmTY.png"
        
        //  写真を丸くする
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        
        //　 いいね数を表示させている
        cell.likeCountLabel.text = String(posts[indexPath.row].likeCount)
        cell.tag = indexPath.row
        
        //  if letの文＝毎度毎度アンラップする作業をしなくて済む
        //  if let userImageUrl = posts[indexPath.row].user.imageUrl {
        if (NCMBFile.file(withName: NCMBUser.current().objectId + ".png" + posts[indexPath.row].objectId, data: nil) as? NCMBFile) != nil {
            
            //　 kfで画像を取得
            cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                if error != nil {
                    
                }
                
            }
        }
        
        //　 いいねの状態を切り替える
        if let isLiked = posts[indexPath.row].isLiked {
            cell.setLikedStatus(setLiked: isLiked)
        } else {
            cell.setLikedStatus(setLiked: false)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    
    //　 いいね機能
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        //   guard文＝条件を満たさない場合の処理を記述する構文
        //   current=現在
        guard  let currentUser = NCMBUser.current() else {
            let storyboard  = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier:
                "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            
            //  synchronize＝同期する
            ud.synchronize()
            
            //  return=スコープを抜けるための処理。メソッドなどで処理を終了し、呼び出し元に戻る
            //  スコープ＝変数の有効範囲を表す、Swiftでは{}で囲まれた部分
            return
        }
        
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(currentUser.objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        self.posts[tableViewCell.tag].isLiked = true
                        self.loadTimeline()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            self.posts[tableViewCell.tag].isLiked =  false
                            self.loadTimeline()
                        }
                    })
                }
            })
        }
    }
    
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        //  選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        
        //  遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            SVProgressHUD.show()
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            
                            // 再読込
                            self.loadTimeline()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            
            //  自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            
            //  他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadTimeline() {
        guard  let currentUser = NCMBUser.current() else {
            let storyboard  = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier:
                "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            return
        }
        
        let query = NCMBQuery(className: "Post")
        
        //  降順
        query?.order(byDescending: "createDate")
        
        //  投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        //  オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                
                //  投稿を格納しておく配列を初期化
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    
                    //  ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    //  退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool !=
                        false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        // "userName"か"displayName"のデータがないためクラッシュ？
                        //　新規会員時に"displayName"の登録をする必要がある？
                        //  "userName"=「ユーザーID」
                        //  "displayName"=「アカウント名」
                        let userModel = User(objectId: user.objectId, userName: user.object(forKey: "userName") as! String)
                        //  let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = user.object(forKey: "imageUrl") as! String
                        
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate, roomId: "")
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(currentUser.objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        
                        // いいねの件数
                        if let likes = likeUsers {
                            post.likeCount = likes.count
                        }
                        
                        // 配列に加える
                        self.posts.append(post)
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.RoomTableView.reloadData()
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        RoomTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadTimeline()
        
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    @IBAction func addNewTimeline(){
        self.performSegue(withIdentifier: "toTimeline", sender: nil)
    }
    
    
}


extension RoomViewController: AddPostViewControllerDelegate {
    func refreshData() {
        loadTimeline()
    }
    
    
    
}
