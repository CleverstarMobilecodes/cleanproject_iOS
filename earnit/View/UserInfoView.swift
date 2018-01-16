//
//  UserInfoView.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/20/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class UserInforView : UIView {
    
    
    //layout contraint for the detailView box
    var constX:NSLayoutConstraint?
    
    //layout contraint for the detailView box
    var constY:NSLayoutConstraint?
    
    //Keyboard offset
    var currentTableViewOffset : CGFloat = 0.0

    
    //The welcome label at the top
    var earnItAppBannerLabel : UILabel = {
        
        var earnItAppBannerLabel = UILabel()
        earnItAppBannerLabel = earnItAppBannerLabel.setEarnItAppLabel(title: "Welcome Back!")
        earnItAppBannerLabel.font = FontHelper.EarnItAppBannerLabelFont()
        return earnItAppBannerLabel
        
    }()
    
    //earnItLogo image
    let righImageView : UIImageView = {
        
        var rightImageView = UIImageView()
        
        return rightImageView
    }()
    
    
    let openTaskLabel : UILabel = {
        
        var openTaskLabel = UILabel()
        openTaskLabel = openTaskLabel.setEarnItAppLabel(title: "Open Tasks")
        openTaskLabel.font = FontHelper.EarnItAppLabelFont()
        return openTaskLabel
    }()
    
    let readyForApproval : UILabel = {
        
        var readyForApproval = UILabel()
        readyForApproval = readyForApproval.setEarnItAppLabel(title: "Ready for Approval")
        readyForApproval.font = FontHelper.EarnItAppLabelFont()
        readyForApproval.textAlignment = .right
        return readyForApproval
    }()

    
    
    let taskTableView : UITableView = {
        
        var taskTableView = UITableView()
        return taskTableView
    }()
    
    
    let bottomView : UIView = {
        
        var bottomView = UIView()
        return bottomView
        
    }()
    
    //Hamburgur button
    let calenderButton : UIButton = {
        
        var calenderButton = UIButton()
        calenderButton = calenderButton.setEarnItAppButton(title: "", backgroundColor: UIColor.clear)
        calenderButton.setImage(EarnItImage.setEarnItAppHamburgarImage(), for: .normal)
        return calenderButton
        
    }()
    
   
    var didSetUpConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(earnItAppBannerLabel)
        self.addSubview(righImageView)
        self.addSubview(openTaskLabel)
       // self.addSubview(taskTableView)
       // self.addSubview(bottomView)
        self.addSubview(calenderButton)
        self.addSubview(readyForApproval)
       // self.bottomView.addSubview(sendMessageToUserButton)
        self.backgroundColor = UIColor.EarnItAppBackgroundColor()
        
        
        self.righImageView.layer.cornerRadius = 28
        self.righImageView.layer.borderColor = UIColor.white.cgColor
        self.righImageView.layer.borderWidth = 1.5
        self.righImageView.clipsToBounds = true
        self.righImageView.contentMode = .scaleAspectFill

       // self.taskTableView.isHidden = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateTitle(titleText: String){
        earnItAppBannerLabel.text =  titleText;
    
    }
    
    override func updateConstraints() {
        
        if (!didSetUpConstraints){
            
            righImageView.snp_makeConstraints{ make in
                
                make.top.equalTo(self).inset(20)
                make.leading.equalTo(self).inset(5)
                ///make.trailing.equalTo(self.view).inset(300)
                make.size.equalTo(CGSize(60,60))
            }
            
            earnItAppBannerLabel.snp_makeConstraints{ make in
                
                make.centerX.equalTo(self.center)
                
                make.top.equalTo(self).inset(30)
//                make.top.equalTo(self).inset(30)
//                make.leading.equalTo(righImageView).inset(80)
//                make.size.equalTo(CGSize(200,40))
                
            }
            
            calenderButton.snp_makeConstraints{ make in
                
                make.top.equalTo(25)
                make.leading.equalTo(280)
                make.trailing.equalTo(20)
                make.size.equalTo(CGSize(80,40))
                
            }
            
            openTaskLabel.snp_makeConstraints{ make in
                
                make.top.equalTo(90)
                make.leading.equalTo(10)
           
                
            }
            
            readyForApproval.snp_makeConstraints{ make in
                
                make.top.equalTo(90)
                make.leading.equalTo(240)
                
            }
            
   
            didSetUpConstraints = true
        }

        super.updateConstraints()
    }

 }
