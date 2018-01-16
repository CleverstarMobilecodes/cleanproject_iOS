//
//  ImageViewHeader.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/9/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class ImageViewHeader : UIView {
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var userProfileImageView: UIImageView!
    
    @IBOutlet var userName: UILabel!
    
    @IBOutlet var email: UILabel!
    
    override func awakeFromNib() {
        super .awakeFromNib()
        self.userProfileImageView.layoutIfNeeded()
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.size.height / 2
        self.userProfileImageView.clipsToBounds = true
        self.userProfileImageView.layer.borderWidth = 1
        self.userProfileImageView.layer.borderColor = UIColor.white.cgColor
        self.backgroundImageView.backgroundColor = UIColor.white
        self.userProfileImageView.contentMode = .scaleAspectFill
        self.userProfileImageView.backgroundColor = UIColor.white

    }
    
    
}
