//
//  UserTableViewCell.swift
//  SwiftMVVM
//
//  Created by jaydeep vadalia on 01/06/22.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(user: User) {
        userImageView.sd_setImage(with: URL(string: user.avatar_url), placeholderImage: nil)
        nameLabel.text = user.login
        typeLabel.text = user.type
    }
    
}
