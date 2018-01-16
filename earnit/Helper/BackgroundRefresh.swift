//
//  BackgroundRefresh.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/11/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import KeychainSwift


//func  refreshUserDetail(delay:Double, success:@escaping (Bool)->()) {
//    
//    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(60000)) {
//            
//            let keychain = KeychainSwift()
//            let _ : Int = Int(keychain.get("userId")!)!
//            let email : String = (keychain.get("email")!)
//            let password : String = (keychain.get("password")!)
//            
//            
//            checkUserAuthentication(email: email, password: password, success: {
//                
//                (responseJSON) ->() in
//                
//                if (responseJSON["userType"].stringValue == "CHILD"){
//                    
//                    EarnItChildUser.currentUser.setAttribute(json: responseJSON)
//                    success(true)
//                    
//                    
//                }else {
//                    
//                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
//                    keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
//                    success(true)
//                }
//                
//            }) { (error) -> () in
//                
//                success(false)
//    
//        }
//        
//        
//    }
//    
//}
//
//
//func  refreshChildTaskDetailsForAParent(delay:Double, success:@escaping ([EarnItChildUser])->()) {
//   
//    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(60000)) {
//        
//        var earnItChildUserList = [EarnItChildUser]()
//        createEarnItAppChildUser( success: {
//            
//            (earnItChildUsers) -> () in
//            
//            earnItChildUserList = earnItChildUsers
//            success(earnItChildUserList)
//            
//            
//        }) {  (error) -> () in
//            
//            success(earnItChildUserList)
//            
//        }
//        
//    }
//    
//}
//







