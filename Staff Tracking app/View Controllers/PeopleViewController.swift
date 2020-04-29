//
//  PeopleViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/9/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit
import MapKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var travelStatusLbl: UILabel!
    @IBOutlet weak var travelMinLbl: UILabel!
    @IBOutlet weak var workMinLbl: UILabel!
    @IBOutlet weak var totalMinLbl: UILabel!
    @IBOutlet weak var totalMiles: UILabel!
    @IBOutlet weak var lastUpdateLbl: UILabel!
    @IBOutlet weak var directionsButton:UIButton!
    var person:thing.subordinatesLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if(!(person?.ProfileImageUrl!.isEmpty)!){
                   let url = URL(string: (person?.ProfileImageUrl ?? " "))!
                   imageView.downloaded(from: url)
               }
        
        nameLbl.text="\(person?.FirstName ?? "") \(person?.LastName ?? "")"
        
        userIdLbl.text=String(person?.UserId ?? -1)
        travelStatusLbl.text = person?.TravelStatus
        travelMinLbl.text = String(person?.TodayTravelMinutes ?? 0)
        workMinLbl.text = String(person?.TodayWorkMinutes ?? 0)
        totalMinLbl.text = String(person?.TodayTravelMinutes ?? 0)
        totalMiles.text = String(person?.TodayTotalMiles ?? 0)
        lastUpdateLbl.text = person?.LastUpdateDateTimeUtc 
        
      
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func directionsTap( sender:Any ) {
        if userIdLbl.text != nil{
            getCoordinateAPI(UserID: userIdLbl.text!)
        }
        
        
    }
     var locResult = locationResult()
    fileprivate func getCoordinateAPI(UserID: String) {
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        var url = URLComponents(string: "https://vpstimedev.vantagepnt.com/Api/Supervisor/GetSubordinateTravelHistoryList")
        
        url?.queryItems = [
            URLQueryItem(name: "UserID", value: UserID),
            URLQueryItem(name: "PagingArgs.Page", value: String(1))
        ]
        
        
        var request = URLRequest(url: (url?.url)!)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let urlConnection = URLSession.shared
        
        //API request
        let task = urlConnection.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let data = data else {
                print("Error: did not receive data")
                return
            }
            
            var long = 0.0
            var lat = 0.0
            
            do {
                self.locResult = try
                    JSONDecoder().decode(locationResult.self , from: data)
                if(self.locResult.ResultCodeName=="Success"){
                      lat=self.locResult.ReturnValue?.CurrentCoordinates?.Latitude ?? 0.0
                     long=self.locResult.ReturnValue?.CurrentCoordinates?.Longitude ?? 0.0
                    
                    let currentPoint = Point(Name: self.nameLbl.text ?? "Name Not Found", Long:long, Lat: lat)
                                                 
                    Points.append(currentPoint)
                   
                    let regionDistance:CLLocationDistance = 1000;
                    let Coordinates = CLLocationCoordinate2DMake(lat, long)
                    let regionSpan = MKCoordinateRegion(center: Coordinates, latitudinalMeters: regionDistance,longitudinalMeters: regionDistance)
                    let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                    let placemark = MKPlacemark(coordinate: Coordinates)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = (currentPoint.Name)
                    mapItem.openInMaps(launchOptions: options)
                    //print(view.annotation?.title!! ?? "BAD!!!!")
                }
                else{
                    let alertController = UIAlertController(title: "ERROR", message: "Wasn't able to connect to server.", preferredStyle: .alert)
                  alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                  self.present(alertController, animated: true)
                }
            } catch let jsonErr {
                print("error trying to convert data to JSON: ", jsonErr)
               return
            }
            //print(" \(peep.FirstName!) \(peep.LastName!) Lat: \(lat) Long: \(long)")
           return
        }
        
        task.resume()
        return
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
