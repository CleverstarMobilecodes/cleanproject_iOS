//
//  CheckEarnItUserAuthentication.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift

func callApiForUpdateTask(earnItTaskChildId : Int,earnItTask: EarnItTask!,success: @escaping(EarnItTask) -> (), failure: @escaping(NSError) -> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    
    
    var headers : HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        
        headers = [
            "Accept": "application/json",
            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json"
        ]
        
        
     }
    
    var taskCommentParam = [[String: Any]]()
    
    for taskcomment in earnItTask.taskComments {
        
        let comment = [
        
        "comment" : taskcomment.comment,
        "createDate": taskcomment.createdDate,
        "updateDate": taskcomment.updateDate,
        "readStatus": taskcomment.readStatus,
        "pictureUrl": taskcomment.taskImageUrl
        
        ] as [String : Any]
        
        taskCommentParam.append(comment)
        
    }
    var param = [String:Any]()
    
    if earnItTask.goal.id != nil{
    
        param = [
        "id": earnItTask.taskId,
        "children":  ["id": earnItTaskChildId],
        "allowance": earnItTask.allowance,
        "createDate": earnItTask.createdDateTimeStamp,
        "dueDate": earnItTask.dueDateTimeStamp,
        "name": earnItTask.taskName,
        "pictureRequired": earnItTask.isPictureRequired,
        "status": earnItTask.status,
        "updateDate": earnItTask.updateDateTimeStamp,
        "taskComments": taskCommentParam,
        "description" : earnItTask.taskDescription!,
        "goal" : ["id": earnItTask.goal.id!]
        
            ] as [String : Any]
        
    }else {
        
        
        param = [
            "id": earnItTask.taskId,
            "children":  ["id": earnItTaskChildId],
            "allowance": earnItTask.allowance,
            "createDate": earnItTask.createdDateTimeStamp,
            "dueDate": earnItTask.dueDateTimeStamp,
            "name": earnItTask.taskName,
            "pictureRequired": earnItTask.isPictureRequired,
            "status": earnItTask.status,
            "updateDate": earnItTask.updateDateTimeStamp,
            "taskComments": taskCommentParam,
            "description" : earnItTask.taskDescription!,
            
            ] as [String : Any]

        
    }
        
    if  earnItTask.repeatMode != .None {
        
        if earnItTask.repeatScheduleDic != nil {
            
            earnItTask.repeatScheduleDic!["repeat"] = earnItTask.repeatMode.rawValue as AnyObject
            
            param.updateValue(earnItTask.repeatScheduleDic!, forKey: "repititionSchedule")
            
        }
        else {
            
            let repeatModeDic = ["repeat" : earnItTask.repeatMode.rawValue]
            param.updateValue(repeatModeDic, forKey: "repititionSchedule")
        }
    }
    
    print(" param : \(param)")
    
    
    
    Alamofire.request("\(EarnItApp_BASE_URL)/tasks",method: .put,parameters: param, encoding: JSONEncoding.default , headers: headers)
        .responseJSON { response in
            switch response.result {
                
            case .success:
                
                let earnItTask = EarnItTask()
                earnItTask.setAttribute(json: JSON(response.result.value))
                print("task update *******\(response.result.value)")
                
                success(earnItTask)
            case .failure(_):
                print("error:\(response.result.error)")
                failure(response.result.error as! NSError)
            }
            
        }
    

}




func callApiForUpdateTaskByParent(earnItTaskChildId : Int,earnItTask: EarnItTask!,success: @escaping(EarnItTask) -> (), failure: @escaping(NSError) -> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    
    let user : String = keychain.get("email") as! String
    let password : String = keychain.get("password") as! String
    
    
    var headers : HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password){
        
        headers = [
            "Accept": "application/json",
            "Authorization": authorizationHeader.value,
            "Content-Type": "application/json"
        ]
        
        
    }
    

    var param = [String:Any]()
    
    if earnItTask.goal.id != nil{
        
        param = [
            "id": earnItTask.taskId,
            "children":  ["id": earnItTaskChildId],
            "allowance": earnItTask.allowance,
            "createDate": earnItTask.createdDateTimeStamp,
            "dueDate": earnItTask.dueDateTimeStamp,
            "name": earnItTask.taskName,
            "pictureRequired": earnItTask.isPictureRequired,
            "status": earnItTask.status,
            "updateDate": earnItTask.updateDateTimeStamp,
            "description" : earnItTask.taskDescription!,
            "goal" : ["id": earnItTask.goal.id!]
            
            ] as [String : Any]
        
    }else {
        
        
        param = [
            "id": earnItTask.taskId,
            "children":  ["id": earnItTaskChildId],
            "allowance": earnItTask.allowance,
            "createDate": earnItTask.createdDateTimeStamp,
            "dueDate": earnItTask.dueDateTimeStamp,
            "name": earnItTask.taskName,
            "pictureRequired": earnItTask.isPictureRequired,
            "status": earnItTask.status,
            "updateDate": earnItTask.updateDateTimeStamp,
            "description" : earnItTask.taskDescription!,
            
            ] as [String : Any]
        
        
    }
    
   
    
    if  earnItTask.repeatMode != .None {
        
        if earnItTask.repeatScheduleDic != nil {
            
            earnItTask.repeatScheduleDic!["repeat"] = earnItTask.repeatMode.rawValue as AnyObject
            
            param.updateValue(earnItTask.repeatScheduleDic!, forKey: "repititionSchedule")

        }
        else {
            
            let repeatModeDic = ["repeat" : earnItTask.repeatMode.rawValue]
            param.updateValue(repeatModeDic, forKey: "repititionSchedule")
        }
    }
    
    
     print(" param : \(param)")
  
    
    Alamofire.request("\(EarnItApp_BASE_URL)/tasks",method: .put,parameters: param, encoding: JSONEncoding.default , headers: headers)
      
        .responseJSON { response in
            switch response.result {
                
            case .success:
                
                let earnItTask = EarnItTask()
                earnItTask.setAttribute(json: JSON(response.result.value!))
                print("task update *******\(String(describing: response.result.value))")
                
                success(earnItTask)
            case .failure(_):
                print("error:\(String(describing: response.result.error))")
                failure(response.result.error! as NSError)
            }
    }
    
  
    
    
}






func getDayTaskListForChildUser(earnItTasks: [EarnItTask]) -> [DayTask]{
    
    var pendingTasks = [EarnItTask]()
    for task in earnItTasks{
        
        if task.status != TaskStatus.completed {
            
            if task.status != TaskStatus.closed {
            
            pendingTasks.append(task)
                
            }
            
        }
    
    }
    
    let sortedEarnItTasks =  pendingTasks.sorted {
        let earnitTask1 = $0.dueDate
        let earnitTask2 = $1.dueDate
        return earnitTask1 > earnitTask2
    }
    
    var dateList = [Date()]
    
    dateList.remove(at: 0)
    for task in sortedEarnItTasks{
        
        dateList.append(task.dueDate)
    }
    
    dateList = Array(Set(dateList))
    
    dateList = dateList.sorted{
        
        let date1 = $0
        let date2 = $1
        return date1 < date2
    }
    
    var dayList = [String]()
    for day in dateList{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let day = formatter.string(from: day as Date)
        dayList.append(day)
    }
    
    dayList = Array(Set(dayList))
    
    var dayTasks = [DayTask]()
    
    for day in dayList {
        
        var tasks = [EarnItTask]()
        
        tasks = sortedEarnItTasks.filter{($0.dateMonthString == day)}
        
        tasks = tasks.sorted{
            
            let task1 = $0.dueDate
            let task2 = $1.dueDate
            return task1 < task2
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let dateString = day
        
        let calendar = Calendar.current
        
        let weekday = calendar.component(.weekday, from: (tasks.first?.dueDate)!)
        
        let weekdayname = getWeekDayName(weekdayValue: weekday)
        
        let dayTask = DayTask( dayName: weekdayname, date: dateString, earnItTasks: tasks, dueDate: (tasks.first?.dueDate)!)
        
        dayTasks.append(dayTask)
        
        
    }
    
    dayTasks = dayTasks.sorted{
        
        let date1 = $0.dueDate
        let date2 = $1.dueDate
        return date1! < date2!
    }
    
    return dayTasks
    
}

func getDayTaskListForParent(earnItTasks: [EarnItTask]) -> [DayTask]{
    
    
    var pendingTasks = [EarnItTask]()
    for task in earnItTasks{
        
        if task.status != TaskStatus.closed{
            
            pendingTasks.append(task)
        }
        
    }

    let sortedEarnItTasks =  pendingTasks.sorted {
        let earnitTask1 = $0.dueDate
        let earnitTask2 = $1.dueDate
        return earnitTask1 > earnitTask2
    }
    
    var dateList = [Date()]
    
    dateList.remove(at: 0)
    for task in sortedEarnItTasks{
        
        dateList.append(task.dueDate)
    }
    
    dateList = Array(Set(dateList))
    
    dateList = dateList.sorted{
        
        let date1 = $0
        let date2 = $1
        return date1 < date2
    }
    
    var dayList = [String]()
    for day in dateList{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let day = formatter.string(from: day as Date)
        dayList.append(day)
    }
    
    dayList = Array(Set(dayList))
    
    var dayTasks = [DayTask]()
    
    for day in dayList {
        
        var tasks = [EarnItTask]()
        
        tasks = sortedEarnItTasks.filter{($0.dateMonthString == day)}
        
        tasks = tasks.sorted{
            
            let task1 = $0.dueDate
            let task2 = $1.dueDate
            return task1 < task2
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let dateString = day
        
        let calendar = Calendar.current
        
        let weekday = calendar.component(.weekday, from: (tasks.first?.dueDate)!)
        
        let weekdayname = getWeekDayName(weekdayValue: weekday)
        
        let dayTask = DayTask( dayName: weekdayname, date: dateString, earnItTasks: tasks, dueDate: (tasks.first?.dueDate)!)
        
        dayTasks.append(dayTask)
        
        
    }
    
    dayTasks = dayTasks.sorted{
        
        let date1 = $0.dueDate
        let date2 = $1.dueDate
        return date1! < date2!
    }
    
    
     return dayTasks
}

func getDayTaskListForParentDashBoard(earnItTasks: [EarnItTask]) -> [DayTask]{
    
    
    var pendingTasks = [EarnItTask]()
    for task in earnItTasks{
        
        if task.status != TaskStatus.closed{
            if task.status != TaskStatus.completed{
                pendingTasks.append(task)
            }
            
        }
        
    }
    
    let sortedEarnItTasks =  pendingTasks.sorted {
        let earnitTask1 = $0.dueDate
        let earnitTask2 = $1.dueDate
        return earnitTask1 > earnitTask2
    }
    
    var dateList = [Date()]
    
    dateList.remove(at: 0)
    for task in sortedEarnItTasks{
        
        dateList.append(task.dueDate)
    }
    
    dateList = Array(Set(dateList))
    
    dateList = dateList.sorted{
        
        let date1 = $0
        let date2 = $1
        return date1 < date2
    }
    
    var dayList = [String]()
    for day in dateList{
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let day = formatter.string(from: day as Date)
        dayList.append(day)
    }
    
    dayList = Array(Set(dayList))
    
    var dayTasks = [DayTask]()
    
    for day in dayList {
        
        var tasks = [EarnItTask]()
        
        tasks = sortedEarnItTasks.filter{($0.dateMonthString == day)}
        
        tasks = tasks.sorted{
            
            let task1 = $0.dueDate
            let task2 = $1.dueDate
            return task1 < task2
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let dateString = day
        
        let calendar = Calendar.current
        
        let weekday = calendar.component(.weekday, from: (tasks.first?.dueDate)!)
        
        let weekdayname = getWeekDayName(weekdayValue: weekday)
        
        let dayTask = DayTask( dayName: weekdayname, date: dateString, earnItTasks: tasks, dueDate: (tasks.first?.dueDate)!)
        
        dayTasks.append(dayTask)
        
        
    }
    
    dayTasks = dayTasks.sorted{
        
        let date1 = $0.dueDate
        let date2 = $1.dueDate
        return date1! < date2!
    }
    
    
    return dayTasks
}


func getWeekDayName(weekdayValue : Int) -> String{
    
    
//    switch weekdayValue {
//        
//    case 1:
//        return "Sunday"
//    case 2:
//        return "Monday"
//    case 3:
//        return "Tuesday"
//    case 4:
//        return "Wednesday"
//    case 5:
//        return "Thrusday"
//    case 6:
//        return "Friday"
//    case 7:
//        return "Saturday"
//    default:
//        return "Saturday"
//    }
    
    
    switch weekdayValue {
        
    case 1:
        return "Sun"
    case 2:
        return "Mon"
    case 3:
        return "Tue"
    case 4:
        return "Wed"
    case 5:
        return "Thu"
    case 6:
        return "Fri"
    case 7:
        return "Sat"
    default:
        return "Sat"
    }

}

func getPendingApprovalTasks(earnItTasks: [EarnItTask]) -> [EarnItTask] {
    
    var pendingTasks = [EarnItTask] ()
    for task in earnItTasks{
        
        if task.status == TaskStatus.completed {
            
                pendingTasks.append(task)
            
        }
        
    }
    
    let sortedPendingTasks =  pendingTasks.sorted {
        let earnitTask1 = $0.dueDate
        let earnitTask2 = $1.dueDate
        return earnitTask1 > earnitTask2
    }
    
return sortedPendingTasks
    
}

func getColorStatusForTaskForParentDashBoard(earnItTask: EarnItTask) -> UIColor{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    var taskColor = UIColor()
    
    let dueDay = earnItTask.dateMonthString
    
    if earnItTask.status == TaskStatus.completed || earnItTask.status == TaskStatus.closed{
        
        return UIColor.earnItTaskCompletedColor()
    
    }else if earnItTask.status == TaskStatus.rejected{
        
        taskColor = UIColor.earnItTaskDueColor()
        //return UIColor.earnItTaskDueColor()
    }
    
    if (dueDay == currentDay){
        
        if currentDate > earnItTask.dueDate{
            
            taskColor =  UIColor.earnItTaskOverDueColor()
            
        }else {
            
            taskColor =  UIColor.earnItTaskDueColor()
        }
        
    }else if currentDate > earnItTask.dueDate{
        
        taskColor =  UIColor.earnItTaskOverDueColor()
        
    }else{
        
        taskColor =  UIColor.earnItTaskNoStatusColor()
    }
    
    return taskColor

}

func getColorStatusForTaskForChildDashBoard(earnItTask: EarnItTask) -> UIColor{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    var taskColor = UIColor()
    
    let dueDay = earnItTask.dateMonthString
    
    if earnItTask.status == TaskStatus.completed || earnItTask.status == TaskStatus.closed{
        
        return UIColor.earnItTaskCompletedColor()
        
    }else if earnItTask.status == TaskStatus.rejected{
        
        taskColor = UIColor.earnItTaskDueColor()
        //return UIColor.earnItTaskDueColor()
    }
    
    if (dueDay == currentDay){
        
        if currentDate > earnItTask.dueDate{
            
            taskColor =  UIColor.earnItTaskOverDueColor()
            
        }else {
            
            taskColor =  UIColor.earnItTaskDueColor()
        }
        
    }else if currentDate > earnItTask.dueDate{
        
        taskColor =  UIColor.earnItTaskOverDueColor()
        
    }else{
        
        taskColor =  UIColor.earnItTaskNoStatusColor()
    }
    
    return taskColor
    
}

func isCurrentDate(earnItTaskDate: String) -> Bool{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    if currentDay == earnItTaskDate {
        
        return true
        
    }else{
        
        return false
    }
}

// Changed for tasks grouping

func getOverDueTaskListForParentDashBoard(earnItTasks: [EarnItTask]) -> [EarnItTask]{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    var overDueTaskList = [EarnItTask]()
    
    for task in earnItTasks {
        
        if currentDay != task.dateMonthString {
            
            if currentDate > task.dueDate {
                
                if task.status != TaskStatus.closed  {
                    
                    if task.status != TaskStatus.completed{
                        overDueTaskList.append(task)
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    for task in overDueTaskList {
        
        
        print("overdue taskName \(task.taskName)")
        print("overdue taskName \(task.status)")
    }
    
    return overDueTaskList
    
}
func getOverDueTaskListForChildDashBoard(earnItTasks: [EarnItTask]) -> [EarnItTask]{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    var overDueTaskList = [EarnItTask]()
    
    for task in earnItTasks {
        
        if currentDay != task.dateMonthString {
            
            if currentDate > task.dueDate {
                
                if task.status == TaskStatus.closed || task.status == TaskStatus.completed  {
                    
                    continue
                }
                    
                else {
                    
                    overDueTaskList.append(task)
                    
                }
            }
            
        }
        
    }
    
    for task in overDueTaskList {
        
        
        print("overdue taskName \(task.taskName)")
        print("overdue taskName \(task.status)")
    }
    
    return overDueTaskList
    
}

//Old Methods without grouping
func getOverDueTaskListForParent(earnItTasks: [EarnItTask]) -> [EarnItTask]{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    var overDueTaskList = [EarnItTask]()
    
    for task in earnItTasks {
        
        if currentDay != task.dateMonthString {
            
            if currentDate > task.dueDate {
                
                if task.status != TaskStatus.closed  {
                    
                    overDueTaskList.append(task)
                    
                }
            }
            
        }

    }
    
    for task in overDueTaskList {
        
        
        print("overdue taskName \(task.taskName)")
        print("overdue taskName \(task.status)")
    }
    
    return overDueTaskList
    
}

func getOverDueTaskListForChild(earnItTasks: [EarnItTask]) -> [EarnItTask]{
    
    let currentDate = Date()
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "M/dd"
    let currentDay = formatter.string(from: currentDate as Date)
    
    var overDueTaskList = [EarnItTask]()
    
    for task in earnItTasks {
        
        if currentDay != task.dateMonthString {
            
            if currentDate > task.dueDate {
                
                if task.status != TaskStatus.completed {
                
                if task.status != TaskStatus.closed{
                    
                    overDueTaskList.append(task)
                    
                    }
                    
                }
            
            }
            
        }
        
    }
    
    for task in overDueTaskList {
        
        
        print("overdue taskName \(task.taskName)")
        print("overdue taskName \(task.status)")
    }
    
    return overDueTaskList
    
}


func getTodayandFutureTask(earnItTasks : [EarnItTask]) -> [EarnItTask] {
    
    var tasks = earnItTasks
    
    
    for daytask in earnItTasks{
        
        
        let currentDate = Date()
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = "M/dd"
        let currentDay = formatter.string(from: currentDate as Date)
        
        
        if  currentDay != daytask.dateMonthString {
            
            if currentDate > daytask.dueDate {
                
                tasks.remove(at: tasks.index(of: daytask)!)
                
            }
            
        }
        
    }
    
  return tasks
}







func getDueDateAndTime(dueDate: Date) -> String{
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.ReferenceType.local
    formatter.dateFormat = "h:mm a"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    let dueTime = formatter.string(from: dueDate  as Date)
    formatter.dateFormat = "M/dd"
    let dateMonthString = formatter.string(from: dueDate  as Date)
    return  dateMonthString + " @ " + dueTime

}
