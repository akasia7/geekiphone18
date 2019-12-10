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
    
    @IBOutlet var likeButton: ImageButton!
    
    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var commentTextView: UITextView!
    
    @IBOutlet var commentCountLabel: UILabel!
    
    @IBOutlet var timestampLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.imageView?.contentMode = .scaleAspectFit
        
    }

    
    func setLikedStatus(setLiked: Bool){
        if setLiked {
            likeButton.setImage(UIImage(named: "icon-heart-filled") , for:.normal)
            
        } else {
            likeButton.setImage(UIImage(named: "icon-heart-clear") , for: .normal)
            likeButton.isEnabled = true
        }
    }
    
    
    @IBAction func like(button: ImageButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    

}
