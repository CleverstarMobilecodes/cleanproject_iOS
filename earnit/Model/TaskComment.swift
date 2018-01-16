//
//  TaskComment.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/23/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import SwiftyJSON

class TaskComment : NSObject{
    
    var comment : String?
    
    var createdDate : Int64 = 0
    
    var updateDate : Int64 =  0
    
    var readStatus  =  0
    
    var taskImageUrl : String?
    
    var taskImage = UIImage()
    
    
    //Mark Initializer
    
    /**
     A standard initializer for an object
     */
    
    override init() {
        super.init()
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
    
    init(comment : String?, createdDate: Int64,updatedDate: Int64, readStatus: Int, taskImageUrl: String?){
        
        super.init()
        self.comment = comment
        self.createdDate = createdDate
        self.updateDate = updatedDate
        self.readStatus  = readStatus
        self.taskImageUrl  = taskImageUrl
    }
    
    
    /**
     
     User initializer with a json object
     
     -Parameter
     - json - The taskcomment user attributes
     */
    
    init(json: JSON){
        
        super.init()
        
        self.comment = json["comment"].stringValue
        self.createdDate = json["createDate"].int64Value
        self.updateDate = json["updateDate"].int64Value
        self.readStatus  = json["readStatus"].intValue
        self.taskImageUrl  = json["pictureUrl"].stringValue
        
        
//        var taskImageUrlString = self.taskImageUrl
//        taskImageUrlString = taskImageUrlString?.replacingOccurrences(of: "\"", with:  " ")
//        let url = URL(string: taskImageUrlString!)
//        var taskImage = UIImage()
//        if url != nil{
//            
//            let data = try? Data(contentsOf: url!)
//            
//            if let imageData = data {
//                
//                self.taskImage = UIImage(data: data!)!
//            }
//            
//        }else{
//            
//            //self.taskImage = nil
//            
//        }

        
        
    }
    
     func setAttribute(json: JSON){
      
        self.comment = json["comment"].stringValue
        self.createdDate = json["createDate"].int64Value
        self.updateDate = json["updateDate"].int64Value
        self.readStatus  = json["readStatus"].intValue
        self.taskImageUrl  = json["pictureUrl"].stringValue
        
        var taskImageUrlString = self.taskImageUrl
        self.taskImageUrl = taskImageUrlString?.replacingOccurrences(of: "\"", with:  " ")
 //       let url = URL(string: taskImageUrlString!)
//        var taskImage = UIImage()
//        if url != nil{
//            
//            let data = try? Data(contentsOf: url!)
//            
//            if let imageData = data {
//                
//                self.taskImage = UIImage(data: data!)!
//            }
//            
//        }else{
//            
//            //self.taskImage = nil
//            
//        }
    }
    
}
