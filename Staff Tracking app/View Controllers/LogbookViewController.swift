//
//  LogbookViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/4/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit

    struct locationResult:Decodable{
        let ReturnValue: coordinateValue?
        let ResultCodeName: String?
        init() {
            ReturnValue=coordinateValue()
            ResultCodeName = " "
        }
        
    }
    struct coordinateValue:Decodable{
        let CurrentCoordinates:CurCoordinates?
        //let UserId: Int?
        init() {
            CurrentCoordinates=CurCoordinates()
            //UserId=0
        }
    }
    struct CurCoordinates:Codable {
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

class thing{
    struct logBookResults:Decodable{
        let ReturnValue: [returnValue]?
        let ResultCodeName: String?       }

    struct returnValue:Decodable{
              let TrackingAppTeamID: Int?
              let Team: String?
              let IsProjectManagersTeam:Bool?
              let SubordinatesLog: [subordinatesLog]?
              
          }
       struct subordinatesLog:Decodable{
              let UserId: Int?
              let FirstName: String?
              let LastName: String?
              let TravelStatus: String?
              let ExtendedTravelStatus: String?
              let Miles: Double?
              let ProfileImageUrl: String?
              let LastIntervalImageUrl: String?
              let DurationMinutes: Int?
              let DurationString:String?
              let TodayTravelMinutes: Int?
              let TodayTravelString: String?
              let TodayWorkMinutes: Int?
              let TodayWorkString: String?
              let TodayTotalMinutes: Int?
              let TodayTotalString: String?
              let TodayTotalMiles: Double?
              let LastUpdateDateTimeUtc: String?
              init(){
                     UserId=0
                     FirstName=""
                     LastName=""
                     TravelStatus=""
                     ExtendedTravelStatus=""
                     Miles=0.0
                     ProfileImageUrl=""
                     LastIntervalImageUrl=""
                     DurationMinutes=0
                     DurationString=""
                     TodayTravelMinutes=0
                     TodayTravelString=""
                     TodayWorkMinutes=0
                     TodayWorkString=""
                     TodayTotalMinutes=0
                     TodayTotalString=""
                     TodayTotalMiles=0.0
                     LastUpdateDateTimeUtc=""
                 }
          }
}
    

   


var peeps=[thing.subordinatesLog]()
var currentPeeps=[thing.subordinatesLog]()
var info = [thing.returnValue]()

var APICallDone=false
class LogbookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPeeps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text="\(currentPeeps[indexPath.row].FirstName ?? "") \(currentPeeps[indexPath.row].LastName ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPerson", sender: self)
        
    }
    var text = ""
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        text=searchText
        currentPeeps = peeps.filter({ (subordinatesLog) -> Bool in
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            if searchText.isEmpty{return true}
            return (subordinatesLog.FirstName?.lowercased().contains(searchText.lowercased()) ?? false)
        case 1:
            if searchText.isEmpty{return true}
            return (subordinatesLog.LastName?.lowercased().contains(searchText.lowercased()) ?? false)
        default:
            return false
            }
        })
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            if text.isEmpty{currentPeeps=peeps}
            else{
                currentPeeps=peeps.filter({ (subordinatesLog) -> Bool in (subordinatesLog.FirstName?.lowercased().contains(text.lowercased()) ?? false)})
            }
        case 1:
            if text.isEmpty{currentPeeps=peeps}
            else{
            currentPeeps=peeps.filter({ (subordinatesLog) -> Bool in (subordinatesLog.LastName?.lowercased().contains(text.lowercased()) ?? false)})
            }
        default:
            return currentPeeps=peeps
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PeopleViewController{
            destination.person=currentPeeps[tableView.indexPathForSelectedRow!.row]
        }
    }
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    func LoadPeople(){
               let loginString = String(format: "%@:%@", username, password)
               let loginData = loginString.data(using: String.Encoding.utf8)!
               let base64LoginString = loginData.base64EncodedString()
               let url = URL(string: "https://vpstimedev.vantagepnt.com/Api/Supervisor/GetSummarySubordinatesLogList")!
               var request = URLRequest(url: url)
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
                        
                   //parse Json
                   do {
                    let result = try
                       JSONDecoder().decode(thing.logBookResults.self , from: data)
                       info = result.ReturnValue ?? [thing.returnValue]()
                       
                       DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.tableView.isHidden=false
                            info.forEach{ team in
                               team.SubordinatesLog?.forEach{ person in
                                   peeps.append(person)
                                }
                            }
                            APICallDone=true
                            currentPeeps=peeps
                            self.tableView.reloadData()
                            self.locationGetter()
                        }
                       
                       
                   } catch let jsonErr {
                   print("error trying to convert data to JSON: ", jsonErr)
                   return
                   }
                   
               }
               task.resume()
    }
    
    
    var locResult = locationResult()
    fileprivate func getCoordinateAPI(peep: thing.subordinatesLog) {
           
           let loginString = String(format: "%@:%@", username, password)
           let loginData = loginString.data(using: String.Encoding.utf8)!
           let base64LoginString = loginData.base64EncodedString()
           var url = URLComponents(string: "https://vpstimedev.vantagepnt.com/Api/Supervisor/GetSubordinateTravelHistoryList")
           
           url?.queryItems = [
               URLQueryItem(name: "UserID", value: String(peep.UserId!)),
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
                       
                       let currentPoint = Point(Name:"\(peep.FirstName!) \(peep.LastName!)", Long:long, Lat: lat)
                                                    
                       Points.append(currentPoint)
                       isFinishedGettingCoordinates = true
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
       
       func locationGetter(){
            
             for peep in peeps {
                 if peep.UserId != nil{
                  
                  getCoordinateAPI(peep: peep)
               }
             }
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        searchBar.delegate=self
       
        if(!APICallDone){
            tableView.isHidden=true
            activityIndicator.hidesWhenStopped=true
            activityIndicator.startAnimating()
            LoadPeople()
        }
        else{
            currentPeeps=peeps
            tableView.reloadData()
            activityIndicator.isHidden=true
        }
        
        refreshControl.tintColor = UIColor.blue
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data...",attributes: [NSAttributedString.Key.foregroundColor: refreshControl.tintColor!] )
        refreshControl.addTarget(self, action: #selector(LogbookViewController.refreshData), for: UIControl.Event.valueChanged)
        if #available(iOS 10.0, *){
            tableView.refreshControl=refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshData(){
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let url = URL(string: "https://vpstimedev.vantagepnt.com/Api/Supervisor/GetSummarySubordinatesLogList")!
        var request = URLRequest(url: url)
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
                 
            //parse Json
            do {
                let result = try
                JSONDecoder().decode(thing.logBookResults.self , from: data)
                info = result.ReturnValue ?? [thing.returnValue]()
            
            
               // self.activityIndicator.stopAnimating()
                
                //self.tableView.isHidden=false
                
            } catch let jsonErr {
            print("error trying to convert data to JSON: ", jsonErr)
            return
            }
            info.forEach{ team in
                team.SubordinatesLog?.forEach{ person in
                    peeps.append(person)
                }
            }
          
            currentPeeps=peeps
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    //@IBOutlet weak var profileButton: UIButton!
    //@IBOutlet weak var logbookButton: UIButton!
    //@IBOutlet weak var homeButton: UIButton!
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
