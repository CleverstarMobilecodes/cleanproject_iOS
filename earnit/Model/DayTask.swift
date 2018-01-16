//
//  DayTask.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/11/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation


class DayTask : NSObject {
    
    //dayName
    var dayName: String!
    
    //date
    var date: String!
    
    
    var earnItTasks : [EarnItTask]!
    
    //duedate
    
    var dueDate : Date!
    
    
    /**
     User initializer with specific attribute value
     
     - Parameters:
     - firstName - child user firstName
     - updateDate- child user updatedate
     - childAvatar- child user avatar
     - phonenumber- child user phone number
     - id         - child user id
     
     **/
    
    init(dayName: String, date: String, earnItTasks: [EarnItTask], dueDate: Date){
        
        super.init()
        self.dayName = dayName
        self.date = date
        self.earnItTasks = earnItTasks
        self.dueDate = dueDate
    }
    
    
}
