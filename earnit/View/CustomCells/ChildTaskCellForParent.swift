//
//  ChildTaskCellForParent.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/25/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit


class ChildTaskCellForParent : UITableViewCell {
    
    
    @IBOutlet var moreButton: UIButton!
    
    @IBOutlet var taskName: UILabel!
    
    @IBOutlet var taskTime: UILabel!
    
    @IBOutlet var addTaskButton: UIButton!
    
    var addTaskForChild: (() -> Void)?
    
    var showAllPendingTaskScreen: (() -> Void)?
    
    @IBAction func addTask(_ sender: Any) {
        
        self.addTaskForChild!()
        
    }
    
    @IBAction func moreButtonClicked(_ sender: Any) {
      
        self.showAllPendingTaskScreen!()
        
    }
}
