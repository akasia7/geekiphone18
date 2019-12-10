//
//  RoomTableViewCell.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/03.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit

protocol RoomTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}

class RoomTableViewCell: UITableViewCell {
    
    var delegate: RoomTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var commentTextView: UITextView!
    
    @IBOutlet var commentCountLabel: UILabel!
    
    @IBOutlet var timestampLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func setLikedStatus(setLiked: Bool){
        if setLiked == true {
            likeButton.setImage(UIImage(named: "icon-heart-filled") , for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "icon-heart-white") , for: .normal)
        }
    }
    
    
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    

}
