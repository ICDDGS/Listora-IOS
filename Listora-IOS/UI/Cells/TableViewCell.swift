//
//  TableViewCell.swift
//  Listora-IOS
//
//  Created by Alejandro on 03/06/25.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var presupuestoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        print(nameLabel.text ?? "")
    }
    
}
