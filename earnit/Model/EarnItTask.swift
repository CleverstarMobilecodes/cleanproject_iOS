//
//  EarnItTask.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import SwiftyJSON


struct TaskStatus {
    
    static let created = "Created"
    static let overdue = "Overdue"
    static let completed = "Completed"
    static let closed = "Closed"
    static let rejected = "Rejected"
}




class EarnItTask : NSObject {
    
    //taskId
    var taskId : Int!
    
    //taskName
    var taskName : String!
    
    //allowance 
    var allowance : Double!
    
    //dueDate
    var dueTime : String!
    
    //createdDateTime
    var createdDateTime : String!
    
    //isPictureRequired
    var isPictureRequired : Int!
    
    //dueDate
    var dueDate = Date()
    
    //dateMonth
    var dateMonthString : String!
    
    //createdDateMonthString
    var createdDateMonthString : String!
    
    //createdDate
    var createdDateTimeStamp : Int64!
    
    //dueDate
    var dueDateTimeStamp : Int64!
    
    //updateDate
    var updateDateTimeStamp : Int64!
    
    //status
    var status : String!
    
    //taskComments
    var taskComments = [TaskComment]()
    
    //task Description
    var taskDescription : String?
    
    //Goal Id
    var goal =  EarnItChildGoal()
    
    //Repeat mode of task
    var repeatMode : repeatMode = .None
    
    var repeatScheduleDic : [String: AnyObject]?
    var taskImage = UIImage()
    
    
    
    override init(){
        
        super.init()
    }
    
    
    init(taskId: Int, taskName: String, allowance: Double, dueTime: String, isPictureRequired: Int,createdDateTimeStamp: Int64, dueDateTimeStamp: Int64,updateDateTimeStamp: Int64, status: String, taskComments: [String] ){
      
     super.init()
     self.taskId = taskId
     self.taskName = taskName
     self.dueTime = dueTime
     self.isPictureRequired = isPictureRequired
     self.createdDateTimeStamp = createdDateTimeStamp
     self.dueDateTimeStamp = dueDateTimeStamp
     self.updateDateTimeStamp = updateDateTimeStamp
     self.status = status
     //self.taskComments = ["",""]
        
    }
    
    init(json: JSON){
    
    super.init()
    self.taskId = json["id"].intValue
    self.taskName = json["name"].stringValue
    self.dueTime = json["dueDate"].stringValue
    self.isPictureRequired = json["pictureRequired"].intValue
    self.dueDateTimeStamp = json["dueDate"].int64Value
    self.createdDateTimeStamp = json["createDate"].int64Value
    self.updateDateTimeStamp = json["updateDate"].int64Value
    self.status = json["status"].stringValue
    self.allowance = json["allowance"].doubleValue
    //self.taskComments = json["taskComments"].arrayObject as! [String]
        
    }
    
    
    func setAttribute(json: JSON){
        
        self.taskId = json["id"].intValue
        self.taskName = json["name"].stringValue
        self.dueTime = json["dueDate"].stringValue
        self.isPictureRequired = json["pictureRequired"].intValue
        self.dueDateTimeStamp = json["dueDate"].int64Value
        self.createdDateTimeStamp = json["createDate"].int64Value
        self.updateDateTimeStamp = json["updateDate"].int64Value
        self.status = json["status"].stringValue
        self.allowance = json["allowance"].doubleValue
        //self.taskComments = json["taskComments"].arrayObject as! [String]
        self.taskDescription = json["description"].stringValue
        
        
        for (_,json) in json["taskComments"]{
            
            
            let earnItTaskComment = TaskComment()
            earnItTaskComment.setAttribute(json: json)
            self.taskComments.append(earnItTaskComment)
            
        }
        
        if json["goal"]["id"] != nil {
            
            let earnItGoal = EarnItChildGoal()
            earnItGoal.setAttribute(json: json["goal"])
            self.goal = earnItGoal
            
        }
        
        if json["repititionSchedule"] != .null {
            
            let repeatDic = json["repititionSchedule"]
            
            self.repeatScheduleDic = json["repititionSchedule"].dictionaryObject! as [String : AnyObject]
            
            print(self.repeatScheduleDic)
            
            switch  repeatDic ["repeat"].string! {
                
            case  "daily" :
                 self.repeatMode = .Daily
                 break;
            case  "weekly" :
                self.repeatMode = .Weekly
                break;
            case  "monthly" :
                self.repeatMode = .Monthly
                break;
            default :
                self.repeatMode = .None
            }
            }
        
        }
    
}
