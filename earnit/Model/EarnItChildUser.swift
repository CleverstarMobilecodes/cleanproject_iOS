//
//  EarnItChildUser.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import SwiftyJSON

private let earnItChildUser = EarnItChildUser()

class EarnItChildUser: NSObject {
    
    
 //child account id
    
    var childAccountId : Int = 0
    
 //child id
    var childUserId : Int = 0
    
 //phone no
    var phoneNumber : String?
    
 //firstName
    var firstName : String!
    
 //lastName
    var lastName : String!
 
 //updateDate
    var updateDate : Int = 0
    
 //email
    var email : String!
    
 //password
    var password : String!
  
 //childAvatar
    var childUserImageUrl : String?
    
 //earnItTaskList
    var earnItTasks = [EarnItTask]()
    
 //earnItTopThreePendingApprovalTask
    var earnItTopThreePendingApprovalTask = [EarnItTask]()
    
  //pendingApprovalTask
    var earnItPendingApprovalTasks = [EarnItTask]()
    
 //sortedEarnitTask based on due
    var sortedEarnItTasks = [EarnItTask]()
 
 //DayTask 
  var dayTasks = [DayTask]()
    
  var childImage = UIImage()
 
  //OverDueTaskList
  var overDueTaskList = [EarnItTask]()
    
 //EarnItGoal
  var earnItGoal = EarnItChildGoal()
    
 //createDate
  var createDate : Int = 0
    
  //message
  
  var childMessage : String?
    
    
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
    class var currentUser : EarnItChildUser {
        
        return earnItChildUser
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
    
    init(childUserId : Int, firstName: String, updateDate: Int, childUserAvatar: String, phoneNumber: String ){
        
        super.init()
        self.childUserId = childUserId
        self.firstName = firstName
        self.phoneNumber = phoneNumber
        self.childUserImageUrl = childUserAvatar
    }
 
    
    /** 
 
   User initializer with a json object
 
   -Parameter
   - json - The child user attributes
   */
    
    init(json: JSON){
        
        super.init()
        self.childUserId = json["id"].intValue
        self.firstName = json["firstName"].stringValue
        self.phoneNumber = json["phone"].stringValue
        self.childUserImageUrl = json["avatar"].stringValue
        self.updateDate = json["updateDate"].intValue
    }
    

    /**
    User initializer with json object
 
   - Parameters
   - json: The user's attributes  in a json object
    */
    
    func setAttribute(json: JSON){
        
        print("Starting set attributes \(json["firstName"].stringValue)")
        print(Date().millisecondsSince1970)
        
        self.firstName = json["firstName"].stringValue
        self.lastName = json["lastName"].stringValue
        self.email = json["email"].stringValue
        self.password = json["password"].stringValue
        self.childUserImageUrl = json["avatar"].stringValue
        self.childUserId = json["id"].intValue
        self.childAccountId = json["account"]["id"].intValue
        self.createDate = json["createDate"].intValue
        self.updateDate = json["updateDate"].intValue
        self.phoneNumber = json["phone"].stringValue
        self.childMessage  = json["message"].stringValue
        self.fcmToken = json["fcmToken"].stringValue
        
        print("ENDING set attributes \(json["firstName"].stringValue)")
        print(Date().millisecondsSince1970)
        
        var userAvatarUrlString = self.childUserImageUrl
        userAvatarUrlString = userAvatarUrlString?.replacingOccurrences(of: "\"", with:  " ")
//        let url = URL(string: userAvatarUrlString!)
//        var userImage = UIImage()
//        if url != nil{
//        
//        let data = try? Data(contentsOf: url!)
//        
//             if let imageData = data {
//        
//                self.childImage = UIImage(data: data!)!
//            }
//        
//        }else{
//        
//        self.childImage = EarnItImage.defaultUserImage()
//        
//        }

        
        var earnItTasks = [EarnItTask]()
      
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone.ReferenceType.local
//        formatter.dateFormat = "h:mm a"
//        formatter.amSymbol = "AM"
//        formatter.pmSymbol = "PM"
        
        for (_,json) in json["tasks"]{
            
            
            let earnItTask = EarnItTask()
            print("START earnItTask creation \(json["name"].stringValue)")
            print(Date().millisecondsSince1970)
            earnItTask.setAttribute(json: json)
            print("END earnItTask creation \(json["name"].stringValue)")
            print(Date().millisecondsSince1970)
            let dueDateValue = Date(milliseconds : earnItTask.dueDateTimeStamp)
            let createdDate = Date(milliseconds: earnItTask.createdDateTimeStamp)
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.ReferenceType.local
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            let dueTime = formatter.string(from: dueDateValue as Date)
            let createdDateTime = formatter.string(from: createdDate as Date)
            formatter.dateFormat = "M/dd"
            earnItTask.dateMonthString = formatter.string(from: dueDateValue as Date)
            earnItTask.createdDateMonthString = formatter.string(from: createdDate as Date)
            
            earnItTask.dueDate = dueDateValue
            earnItTask.dueTime = dueTime
            earnItTask.createdDateTime = createdDateTime
            
        
            earnItTasks.append(earnItTask)
            
        }
        
        
        
        self.earnItTasks = earnItTasks
        self.overDueTaskList = getOverDueTaskListForChild(earnItTasks: self.earnItTasks)
        //self.earnItTopThreeTask = Array(self.earnItTasks.prefix(3))
        var earnItTopThreePendingApprovalTask = [EarnItTask]()
        var earnItPendingApprovalTasks = [EarnItTask]()
    
        for task in self.earnItTasks {
            
            if earnItTopThreePendingApprovalTask.count > 2{
                
              break
            }
            if task.status == TaskStatus.completed{
                
                earnItTopThreePendingApprovalTask.append(task)
  
            }
            
        }
        
        for task in self.earnItTasks {
            
                if task.status == TaskStatus.completed{
                
                earnItPendingApprovalTasks.append(task)
                
            }
            
        }
        
        self.earnItTopThreePendingApprovalTask = earnItTopThreePendingApprovalTask
        self.earnItPendingApprovalTasks = earnItPendingApprovalTasks
    }
    
    
    func earnGetWeekDayName(weekdayValue : Int) -> String{
        
        
        switch weekdayValue {
            
        case 1:
           return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thrusday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "Saturday"
        }
        
    }
    
}

extension Int {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium
        
        return dateFormatter.string(from: date)
    }
}


// Swift 2:
//extension Date {
//    init(ticks: UInt64) {
//        self.init(timeIntervalSince1970: Double(ticks) * 1000)
//    }
//}

//extension Date {
//    init(ticks: UInt64) {
//        self.init(timeIntervalSince1970: Double(ticks) * 1000)
//    }
//}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}



extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}


extension NSDate {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
}


