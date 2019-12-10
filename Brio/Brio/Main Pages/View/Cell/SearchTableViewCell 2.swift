//
//  SearchTableViewCell.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/18.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func didTapFollowButton(button: UIButton)
}

class SearchTableViewCell: UITableViewCell {
    
    var delegate: SearchTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var followButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func follow(button: UIButton) {
        self.delegate?.didTapFollowButton(button: button)
    }
    
}
