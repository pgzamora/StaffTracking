//
//  API structs.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/7/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import Foundation
import UIKit
public struct profile: Decodable {
    let FirstName: String?
    let LastName: String?
    let PhoneNumber: String?
    let Vehicle: String?
    let Role: String?
    let ProfileImageUrl: String?
    let IsTrackingAppAdmin: Bool?
    let UserId: Int?
    let CurrentTrackingAppTravelStatus: String?
    let ProfileImageLastUpdateDate: String?
    
    init(){
        FirstName=""
        LastName=""
        PhoneNumber=""
        Vehicle=""
        Role=""
        ProfileImageUrl=""
        IsTrackingAppAdmin=false
        UserId=0
        CurrentTrackingAppTravelStatus=""
        ProfileImageLastUpdateDate=""
    }
}
struct trackingAppLastVersionInfo: Decodable {
    let TrackingAppVersionName: String?
    let TrackingAppVersionCode: Int?
    let VersionFileUrl: String?
    
    init(){
        TrackingAppVersionName=""
        TrackingAppVersionCode=0
        VersionFileUrl=""
    }
}
struct returnValue: Decodable{
    let Profile: profile?
    let ServerTimeMinutes: Int?
    let TrackingAppLastVersionInfo: trackingAppLastVersionInfo?
    init(){
        Profile = profile()
        ServerTimeMinutes=0
    TrackingAppLastVersionInfo=trackingAppLastVersionInfo()
    }
}
struct Result: Decodable{
    let ReturnValue: returnValue?
    let ResultCode: Int?
    let ResultCodeName: String?
    let ErrorMessage: String?
    init(){
        ReturnValue=returnValue()
        ResultCode=0
        ResultCodeName=""
        ErrorMessage=""
        }
}

class logBook{
    
   
}




