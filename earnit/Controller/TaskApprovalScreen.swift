//
//  TaskApprovalScreen.swift
//  earnit
//
//  Created by Srivathsa on 21/10/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit

class TaskApprovalScreen: UIViewController {

    @IBOutlet var taskName: UILabel!
    
    @IBOutlet var taskDescriptionLabel: UILabel!
    
    @IBOutlet var dueDateLabel: UILabel!
    
    @IBOutlet var isPhotoRequiredLabel: UILabel!
    
    @IBOutlet var isRepeatsLabel: UILabel!
    
    @IBOutlet var taskImageView: UIImageView!
    
    @IBOutlet var taskCommentLabel: UILabel!
  
    @IBOutlet var allowanceAmountLabel: UILabel!
    
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var earnItChildUserForParent : EarnItChildUser!

 var completedTask = EarnItTask()
    let colonSpace = ": "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.assignTaskDetails()
    }

    
    
    
    
    
    //MARK: -Custom Methods
    func assignTaskDetails()  {
        self.taskImageView.image = nil

        self.taskName.text = completedTask.taskName
        let taskComment  =  completedTask.taskComments.last
        if completedTask.isPictureRequired == 1{
            
            print("has task image")
            if taskComment?.taskImageUrl != nil{
                self.taskImageView.loadImageUsingCacheForTask(withUrl: (taskComment?.taskImageUrl)!)
                
            }
            
             self.isPhotoRequiredLabel.text = colonSpace +  "Yes"
            
    }
        else {
            
            self.isPhotoRequiredLabel.text = colonSpace +  "No"

        }
        
        
        if(self.completedTask.taskDescription == ""){
            
            self.taskDescriptionLabel.text = "No description available"
            self.taskDescriptionLabel.alpha = 0.5
            
        }else{
            
            self.taskDescriptionLabel.text = completedTask.taskDescription
            self.taskDescriptionLabel.alpha = 1.0
        }
        
        let newtaskComment = taskComment?.comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if newtaskComment == "" {

            self.commentLabel.isHidden = true
        }
        else {
            self.commentLabel.isHidden = false
            self.taskCommentLabel.text = "\(String(describing: newtaskComment!))\n"
        }
        
        self.dueDateLabel.text = colonSpace + getDueDateAndTime(dueDate: completedTask.dueDate)
    
       
        if completedTask.repeatMode == .None {
            
            self.isRepeatsLabel.text = colonSpace + "No"
        }
        else {
            self.isRepeatsLabel.text = colonSpace + completedTask.repeatMode.rawValue.capitalized
        }
        
        self.allowanceAmountLabel.text = colonSpace + "\(completedTask.allowance!)"
    
        self.view.layoutIfNeeded()

    }
    
    //MARK: -UIButton Action Methods
    
    @IBAction func backButtonDidTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func declineButtonDidTapped(_ sender: Any) {
        
        self.completedTask.status = TaskStatus.rejected
        self.setStatusAndCallApiForUpdateTask(taskStatus: TaskStatus.rejected)
    }
    
    @IBAction func approveButtonDidTapped(_ sender: Any) {
        
        self.completedTask.status = TaskStatus.closed
        self.setStatusAndCallApiForUpdateTask(taskStatus: TaskStatus.closed)
    }
    
    
    //MARK: -Custom Logic Methods
    
    func setStatusAndCallApiForUpdateTask(taskStatus: String){
        
        self.showLoadingView()
        self.completedTask.status = taskStatus
        
        callApiForUpdateTask(earnItTaskChildId:self.earnItChildUserForParent.childUserId ,earnItTask:self.completedTask, success: {_ in
            
            var updatedTaskList = [EarnItTask]()
            for task in self.earnItChildUserForParent.earnItTasks {
                
                if task.taskId == self.completedTask.taskId{
                    task.status = self.completedTask.status
                }
                updatedTaskList.append(task)
            }
            
            self.earnItChildUserForParent.earnItTasks = updatedTaskList
          
            self.hideLoadingView()
            
            
            self.showNextApprovalTask()
            
        }) { (error) -> () in
            
            self.view.makeToast("Failed")
            self.hideLoadingView()
        
            
        }
        
        
    }
    
    
    func showNextApprovalTask() {
        
        
        for task in  self.earnItChildUserForParent.earnItTasks {
       
            
            if task.status == TaskStatus.completed {
                
           
                self.completedTask = task
                self.assignTaskDetails()
                return
            }
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    

    func showLoadingView(){
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
    }

    func hideLoadingView(){
        self.activityIndicator.isHidden = true
        self.view.isUserInteractionEnabled = true

    }

}



class customLabel:UILabel{
    
    override func draw(_ rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
