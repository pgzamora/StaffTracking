//
//  API structs.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/7/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import Foundation
import UIKit


public struct keys{
    static let currentTime = "currentTime"
    static let serverDate = "serverDate"
    static let rememberMe="rememberMe"
    static let username="username"
    static let password="password"
    static let isTimeRunning="isTimeRunning"
    static let isTravel="isTravel"
}
    
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
final class startStopAPI:Encodable {
    var ServerTimeMinutes:Int
    var IntervalType:Int?
    var IsEndOfDayInterval:Bool?
    var Coordinates:CCoordinates
    
    init(ServerTimeMinutes: Int, IntervalType: Int, Longitude: Double, Latitude: Double) {
        self.ServerTimeMinutes=ServerTimeMinutes
        self.IntervalType=IntervalType
        self.Coordinates = CCoordinates.init(Long: Longitude, Lat: Latitude)
    }
    init(ServerTimeMinutes: Int, isEnd: Bool, Longitude: Double, Latitude: Double) {
        self.ServerTimeMinutes=ServerTimeMinutes
        self.IsEndOfDayInterval=isEnd
        self.Coordinates = CCoordinates.init(Long: Longitude, Lat: Latitude)
    }
}
struct CCoordinates:Encodable {
    var Longitude: Double?
    var Latitude: Double?
    init() {
        Longitude = 0.0
        Latitude = 0.0
    }
    init(Long: Double, Lat: Double) {
        self.Longitude = Long
        self.Latitude = Lat
    }
}
struct Point{
    var Name: String
    var Longitude: Double
    var Latitude: Double
    init(Name: String, Long: Double, Lat: Double) {
        self.Name = Name
        self.Longitude = Long
        self.Latitude = Lat
    }}






