//
//  TaskCell.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/6/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class TaskCell : UITableViewCell {
    
    

    @IBOutlet var taskName: UILabel!
    
    @IBOutlet var taskTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
