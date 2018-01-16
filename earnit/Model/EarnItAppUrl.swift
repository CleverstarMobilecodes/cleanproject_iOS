//
//  EarnItAppUrl.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation


//let EarnItApp_BASE_URL = "https://api.myearnitapp.com:8443/earnit-api"
//let EarnItApp_AWS_BUCKET_NAME = "earnit-dev"
let EarnItApp_AWS_PARENTIMAGE_FOLDER = "profile/parent"
let EarnItApp_AWS_CHILDIMAGE_FOLDER = "profile/child"
let EarnItApp_AWS_TASKIMAGE_FOLDER = "tasks"
let AWS_URL = "https://s3-us-west-2.amazonaws.com/"
let AWS_ACCESS_ID = "AKIAJIN35A42G33VAWQA"
let AWS_SECRET_KEY = "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"

#if DEVELOPMENT
let EarnItApp_BASE_URL = "http://35.162.48.144:8080/earnit-api"
let EarnItApp_AWS_BUCKET_NAME = "earnitapp-dev"
    
#else
    
let EarnItApp_BASE_URL = "https://api.myearnitapp.com:8443/earnit-api"
let EarnItApp_AWS_BUCKET_NAME = "earnitapp"
    
#endif
