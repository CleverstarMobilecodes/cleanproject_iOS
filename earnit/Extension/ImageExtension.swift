//
//  ImageExtension.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift


class EarnItImage {
    
    static func setEarnItAppImage(imageName : String?,backgroundColor: UIColor?) -> UIImageView{
        
        let earnItAppImage = UIImageView()
        if imageName != nil {
            earnItAppImage.image = UIImage(named: imageName!)
        }
        
        earnItAppImage.contentMode = .scaleAspectFit
        earnItAppImage.layer.cornerRadius = 28
        earnItAppImage.clipsToBounds = true
        earnItAppImage.backgroundColor = backgroundColor
        earnItAppImage.layer.borderColor = UIColor.white.cgColor
        
        return earnItAppImage
    }
    
    static func setFontAweseomeImage(imageName: String, textColor: UIColor, width: CGFloat, height: CGFloat, backgroundColor: UIColor) -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.bars, textColor: UIColor.earnItAppPinkColor(), size: CGSize(width, height), backgroundColor: UIColor.clear)
        
    }
    
    static func setEarnItAppHamburgarImage() -> UIImage {
        
    return setFontAweseomeImage(imageName: FontAwesome.bars.rawValue, textColor: UIColor.earnItAppPinkColor(), width: 80, height: 40, backgroundColor: UIColor.earnItAppPinkColor())
    }
    
    
    static func setEarnItCalenderImage() -> UIImage {
        
         return UIImage.fontAwesomeIcon(name: FontAwesome.calendar, textColor: UIColor.earnItAppPinkColor(), size: CGSize(80, 40), backgroundColor: UIColor.clear)
    }
    
    
    static func setEarnItAppDownChevronIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.chevronDown, textColor: UIColor.white, size: CGSize(80, 40), backgroundColor: UIColor.clear)
    }


    static func setEarnItAppCheckInImage() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.check, textColor: UIColor.EarnItAppStandardColor(), size: CGSize(40, 40), backgroundColor: UIColor.clear)
    }
    
    static func setEarnItTaskArrowImage() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.chevronRight, textColor: UIColor.gray, size: CGSize(40, 40), backgroundColor: UIColor.clear)
    }
    
    static func setEarnItUncheckedImage() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.square, textColor: UIColor.white, size: CGSize(40, 40), backgroundColor: UIColor.clear)

    }
    
    static func setEarnItCheckedImage() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.checkSquare, textColor: UIColor.white, size: CGSize(60, 60), backgroundColor: UIColor.clear)
        
    }
    
    
    static func setEarnItAddImage() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.plusCircle, textColor: UIColor.EarnItAppTagLineColor(), size: CGSize(40, 40), backgroundColor: UIColor.clear)
        
    }
    
    static func setEarnItAddIcon() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.plusCircle, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
    }
    
    static func setEarnItCheckMark() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.checkCircle, textColor: UIColor.earnItAppPinkColor(), size: CGSize(30, 30), backgroundColor: UIColor.clear)
    }
    
    static func setEarnItAppThumbsUp() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.thumbsUp, textColor: UIColor.EarnItAppTagLineColor(), size: CGSize(40, 40), backgroundColor: UIColor.clear)
        
    }
    
    static func defaultUserImage() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.user, textColor: UIColor.gray, size: CGSize(40, 40), backgroundColor: UIColor.white)
        
    }
    
    static func setEarnItAppThumbsDown() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.thumbsDown, textColor: UIColor.EarnItAppTagLineColor(), size: CGSize(40, 40), backgroundColor: UIColor.clear)
        
    }
    static func setEarnItAppShowTaskImage() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.eye, textColor: UIColor.white, size: CGSize(40, 40), backgroundColor: UIColor.clear)
        
    }
    
    
    static func setEarnItAppShowTaskIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.eye, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)

    }
    
    static func setEarnItAppBalanceIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.dollar, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }
    
    static func setEarnItPageIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.fileTextO, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }
    static func setEarnItCommentIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.comment, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }

    static func setEarnItGoalIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.star, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }
    
    static func setEarnItLogoutIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.signOut, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }
    
    static func setEarnItProfileIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.user, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }
    
    static func setEarnItCalendarIcon() -> UIImage {
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.calendar, textColor: UIColor.earnItAppCheckInColor(), size: CGSize(25, 25), backgroundColor: UIColor.clear)
        
    }

    
    static func setAccount() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.userCircleO, textColor: UIColor.white, size: CGSize(30, 30), backgroundColor: UIColor.clear)
        
    }
    static func setSetting() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.cog, textColor: UIColor.white, size: CGSize(30, 30), backgroundColor: UIColor.clear)
        
    }
    
    static func setVersion() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.stickyNote, textColor: UIColor.clear, size: CGSize(30, 30), backgroundColor: UIColor.clear)
    }
    static func setLogout() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.lock, textColor: UIColor.white, size: CGSize(30, 30), backgroundColor: UIColor.clear)
        
    }
    static func setHome() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.home, textColor: UIColor.EarnItAppBackgroundColor(), size: CGSize(30, 30), backgroundColor: UIColor.clear)
        
    }

    static func setLoadingImage() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.user, textColor: UIColor.gray, size: CGSize(30, 30), backgroundColor: UIColor.clear)
        
    }
    
    static func setLoadingImageForTask() -> UIImage{
        
        return UIImage.fontAwesomeIcon(name: FontAwesome.pictureO , textColor: UIColor.gray, size: CGSize(30, 30), backgroundColor: UIColor.clear)
        
    }
}
