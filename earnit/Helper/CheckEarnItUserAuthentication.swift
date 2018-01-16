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

 func checkUserAuthentication(email: String!, password: String!, success: @escaping(JSON) -> (), failure: @escaping(NSError) -> ()){
    let headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    let param = ["email": email, "password": password] as [String: String]
    print("login url is \(EarnItApp_BASE_URL)/login")
    Alamofire.request("\(EarnItApp_BASE_URL)/login",method: .post,parameters: param, encoding: JSONEncoding.default , headers: headers)
        .responseJSON { response in
            switch response.result {
            case .success:
                let  responseJSON = JSON(response.result.value!)
                     print("response.result.value for user login \(response.result.value)")
                     success(responseJSON)
         
            case .failure(_):
                print("response.result.error Login--- \(response.result.error)")
                failure(response.result.error as! NSError)
            }
    
      }
    
}


func callApiToSendToken(token: String!,success: @escaping(JSON) ->(),failure: @escaping(NSError) -> ()){
    
    let keychain = KeychainSwift()
    guard  let _ = keychain.get("email") else  {
        print(" /n Unable to fetch user credentials from keychain \n")
        return
    }
    let email = keychain.get("email")
    let password = keychain.get("password")
    
    let headers: HTTPHeaders = [
        
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    Alamofire.request("\(EarnItApp_BASE_URL)/token",method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        .responseJSON { response in
            
            switch response.result{
                
            case .success:
                
                let responseJSON = JSON(response.result.value!)
                
            case .failure(_):
                
                print("repsone.result.error token sending \(response.result.error)")
                failure(response.result.error as! NSError)
                
            }
   
      }
    
    
}
