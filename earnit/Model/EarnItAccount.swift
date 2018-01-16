//
//  EarnItAccount.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import SwiftyJSON

private var earnItUser = EarnItAccount()

class EarnItAccount: NSObject {
    
 
    //account id
    var accountId : Int = 0
    
    // user id
    var id : Int = 0
    
    //phone no
    var phoneNumber : String?
    
    //firstName
    var firstName : String!
    
    //lastName
    var lastName : String!
    
    //createDate
    var createDate : Int = 0
    
    //updateDate
    var updateDate : Int = 0
    
    //childAvatar
    var avatar : String?
    
    //email
    var email : String?
    
    //userType 
    var userType : String?
    
    var parentImage = UIImage()
    
    var earnItChildUsers = [EarnItChildUser]()
  
    var password : String!
    
    var fcmToken : String?
    
    //Mark Initializer
    
    /**
     A standard initializer for an object
     */
    
    override init() {
        super.init()
    }
    
    
    
    // MARK: - Instances
    
    /**
     Accesses the current user object.
     */
    class var currentUser : EarnItAccount {
        
        return earnItUser
    }

    
    static func resetCurrentUser() {
        earnItUser = EarnItAccount()
    }
    
    
    
    /**
     User initializer with specific attribute value
     
     - Parameters:
     - firstName - child user firstName
     - updateDate- child user updatedate
     - childAvatar- child user avatar
     - phonenumber- child user phone number
     - id         - child user id
     
     **/
    
    init(accountId : Int, firstName: String,lastName: String, updateDate: Int, avatar: String, phoneNumber: String, email: String,userType: String ){
        
        super.init()
        self.accountId = accountId
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.avatar = avatar
        self.email = email
        self.userType = userType
    }
    
    
    /**
     
     User initializer with a json object
     
     -Parameter
     - json - The child user attributes
     */
    
    init(json: JSON){
        
        super.init()
        self.accountId = json["id"].intValue
        self.firstName = json["firstName"].stringValue
        self.lastName = json["lastName"].stringValue
        self.email = json["email"].stringValue
        self.phoneNumber = json["phone"].stringValue
        self.avatar = json["avatar"].stringValue
        self.updateDate = json["updateDate"].intValue
        self.createDate = json["createDate"].intValue
        self.userType = json["userType"].stringValue
    }
    
    
    /**
     User initializer with json object
     
     - Parameters
     - json: The user's attributes  in a json object
     */
    
    func setAttribute(json: JSON){
        
        self.id = json["id"].intValue
        self.accountId = json["account"]["id"].intValue
        self.firstName = json["firstName"].stringValue
        self.lastName = json["lastName"].stringValue
        self.email = json["email"].stringValue
        self.phoneNumber = json["phone"].stringValue
        self.avatar = json["avatar"].stringValue
        self.updateDate = json["updateDate"].intValue
        self.createDate = json["createDate"].intValue
        self.userType = json["userType"].stringValue
        self.password = json["password"].stringValue
        self.fcmToken = json["fcmToken"].stringValue
        
//    
          var userAvatarUrlString = self.avatar
          self.avatar = userAvatarUrlString?.replacingOccurrences(of: "\"", with:  " ")
//        let url = URL(string: userAvatarUrlString!)
//        var userImage = UIImage()
//        if url != nil{
//            
//            let data = try? Data(contentsOf: url!)
//            
//            if let imageData = data {
//                
//              self.parentImage = UIImage(data: data!)!
//            }
//            
//        }else{
//            
//            self.parentImage = EarnItImage.defaultUserImage()
//            
//        }

        
    }
    
    
}
 

