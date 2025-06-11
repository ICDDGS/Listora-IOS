//
//  RecipeTableViewCell.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
    }
}

