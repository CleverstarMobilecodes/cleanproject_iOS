//
//  ChildTaskDetailCell.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/11/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import Material

class ChildTaskDetailApprovalCell: UITableViewCell {

    @IBOutlet var taskName: UILabel!
    @IBOutlet var statusImage: UIImageView!
    //@IBOutlet var checkButton: UIButton!
   // @IBOutlet var checkBoxImageView: UIImageView!
   // @IBOutlet var checkboxContainer: UIImageView!
    @IBOutlet var approveButton: UIButton!
    @IBOutlet var taskDescription: UILabel!
    @IBOutlet var arrowButton: UIButton!
    
    var askToApproveTheCompletedTask: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func approveClicked(_ sender: Any) {
        askToApproveTheCompletedTask!()
        
        print("button clicked cell")
    }
//    @IBAction func checkButtonClicked(_ sender: Any) {
//        
//        askToApproveTheCompletedTask!()
//        
//        print("button clicked cell")
//        
//    }
   
    
}
