//
//  LogbookViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/4/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit
class thing{
    struct logBookResults:Decodable{
        let ReturnValue: [returnValue]?
           
       }

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
              let ProfileImageURL: String?
              let LastIntervalImageURL: String?
              let DurationMinutes: Int?
              let DurationString:String?
              let TodayTravelMinutes: Int?
              let TodayTravelString: String?
              let TodayWorkMinutes: Int?
              let TodayWorkString: String?
              let TodayTotalMinutes: Int?
              let TodayTotalString: String?
              let TodayTotalMiles: Double?
              let LastUpdateDateTimeUTC: String?
              init(){
                     UserId=0
                     FirstName=""
                     LastName=""
                     TravelStatus=""
                     ExtendedTravelStatus=""
                     Miles=0.0
                     ProfileImageURL=""
                     LastIntervalImageURL=""
                     DurationMinutes=0
                     DurationString=""
                     TodayTravelMinutes=0
                     TodayTravelString=""
                     TodayWorkMinutes=0
                     TodayWorkString=""
                     TodayTotalMinutes=0
                     TodayTotalString=""
                     TodayTotalMiles=0.0
                     LastUpdateDateTimeUTC=""
                 }
          }
}
    

   



class LogbookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var info = [thing.returnValue]()
    var peeps=[thing.subordinatesLog]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        
        return peeps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text="\(peeps[indexPath.row].FirstName ?? "") \(peeps[indexPath.row].LastName ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPerson", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PeopleViewController{
            destination.person=peeps[tableView.indexPathForSelectedRow!.row]
        }
    }

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
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
            var result = try
                JSONDecoder().decode(thing.logBookResults.self , from: data)
                self.info = result.ReturnValue ?? [thing.returnValue]()
               
                   
            } catch let jsonErr {
            print("error trying to convert data to JSON: ", jsonErr)
            return
            }
            self.info.forEach{ team in
                team.SubordinatesLog?.forEach{ person in
                    self.peeps.append(person)
                }
            }
          
            
            self.tableView.reloadData()
        }
        task.resume()
        
        // Do any additional setup after loading the view.
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
