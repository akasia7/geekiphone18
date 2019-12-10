//
//  SearchViewController.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/18.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchTableViewCellDelegate {
    
    var users = [NCMBUser]()
    
    var followingUserIds = [String]()
    
    var searchBar: UISearchBar!
    
    @IBOutlet var searchUserTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        searchUserTableView.dataSource = self
        searchUserTableView.delegate = self
        
        // カスタムセルの登録
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        searchUserTableView.register(nib, forCellReuseIdentifier: "SearchCell")
        
        // 余計な線を消す
        searchUserTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(searchText: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: searchBar.text)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchTableViewCell
        
        let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/HlgrPhqq9ECHzZT3/publicFiles/VKD52cVhRFPhLmTY.png"
        
        
    
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        
        cell.userNameLabel.text = users[indexPath.row].object(forKey: "displayName") as? String
        
        // Followボタンを機能させる
        cell.tag = indexPath.row
        cell.delegate = self
        
        if followingUserIds.contains(users[indexPath.row].objectId) == true {
            cell.followButton.isHidden = true
        } else {
            cell.followButton.isHidden = false
        }
        
        return cell
    }
    
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
        let message = displayName! + "をフォローしますか？"
        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.follow(selectedUser: self.users[tableViewCell.tag])
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func follow(selectedUser: NCMBUser) {
        let object = NCMBObject(className: "Follow")
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    self.loadUsers(searchText: nil)
                }
            })
        } else {
            // currentUserが空(nil)だったらログイン画面へ
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
    }
    
    //ユーザーを読み込む
    func loadUsers(searchText: String?) {
        let query = NCMBUser.query()
        
        // 自分を除外
        // query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
        
        // 退会済みアカウントを除外
        query?.whereKey("active", notEqualTo: false)

        // 検索ワードがある場合
        if let text = searchText {
            query?.whereKey("userName", equalTo: text)
        }

        // 新着ユーザー50人だけ拾う
        query?.limit = 50
        
        // 降順にソート
        query?.order(byDescending: "createDate")

        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                print(error)
                 SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                
                // 取得した新着50件のユーザーを格納
                self.users = result as! [NCMBUser]
                print("users")
                print(self.users)
                self.loadFollowingUserIds()
            }
        })
    }

   
     
    func loadFollowingUserIds() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.followingUserIds = [String]()
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                   
                }
                
                self.searchUserTableView.reloadData()
                
            }
        })
    }

}
