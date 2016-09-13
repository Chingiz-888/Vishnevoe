//
//  MessageTableCell.swift
//  Vishnevoe
//
//  Created by Chingiz Bayshurinon 03.08.16.
//  Copyright © 2016 Chingiz Bayshurin All rights reserved.
//

import UIKit

class MessageTableCell: UITableViewCell {
    

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageDate: UILabel!

    
       override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}