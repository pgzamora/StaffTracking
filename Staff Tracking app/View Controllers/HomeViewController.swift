//
//  HomeViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 2/22/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//Global Variables
let defaults = UserDefaults.standard
var isTravel=false
var serverTime = 0
var timer = Timer();
var isTimerRunning = false
var isFinishedGettingCoordinates=false
var hourOffset=0
var minOffset=0
var secOffset=0
var Points=[Point]()

extension HomeViewController:CLLocationManagerDelegate{
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
        mapView.setRegion(region , animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
 
class HomeViewController: UIViewController {
    var locResult = locationResult()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vpButton:UIButton!
    let locationManager = CLLocationManager()
    let regionInMeter: Double = 100500
    
    
    var calender = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        workButton.isEnabled=false
        checkStatus()
        
        if defaults.bool(forKey: keys.isTimeRunning) //isTimerRunning
        {
            timer = Timer.scheduledTimer( timeInterval:1, target:self, selector:#selector(runtime),userInfo:nil,repeats:true)
        }
        checkLocationServices()
        
        if profileResult.ReturnValue?.Profile?.Role == "ProjectManager"{
              if(isFinishedGettingCoordinates){
                      
                  addAnnotions(Points: Points)
              }
              else{
                  activityIndicator.hidesWhenStopped=true
                  activityIndicator.startAnimating()
                
                     self.startButton.isEnabled=false
                     self.startButton.backgroundColor=#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    self.stopButton.backgroundColor=#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                self.workTimerLabel.isEnabled=false
                self.workTimerLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                self.timerLabel.isEnabled=false
                self.timerLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                self.stopButton.isEnabled=false
               
                  message.isHidden=false
                  
                  LoadPeople()
                  
                  //addAnnotions(Points: Points)
              }
        }
        else
        {
            checkStatus()
            activityIndicator.isHidden=true
            message.isHidden=true
            logBookButton.isHidden=true
        }
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
            mapView.setRegion(region, animated: true)
        }
    }
        
        func setupLocationManger(){
            locationManager.delegate=self
            locationManager.desiredAccuracy=kCLLocationAccuracyBest
        }
        
        func checkLocationServices(){
            if CLLocationManager.locationServicesEnabled(){
                setupLocationManger()
                checkLocationAuthorization()
            }else{
                
            }
        }
        func checkLocationAuthorization(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                centerViewOnUserLocation()
                locationManager.startUpdatingLocation()
                break
            case .denied:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted:
                break
            case .authorizedAlways:
                break
            @unknown default:
                fatalError()
            }
        }
        
        // Do any additional setup after loading the view.
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
                    
                    if(result.ResultCodeName == "Success"){
                        
                         DispatchQueue.main.async {
                             
                              info.forEach{ team in
                                 team.SubordinatesLog?.forEach{ person in
                                     peeps.append(person)
                                  }
                              }
                              APICallDone=true
                              currentPeeps=peeps
                              self.locationGetter()
                         }
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
                   
               }
               task.resume()
    }
    fileprivate func addAnnotions(Points:[Point] ) {
        
        for point in Points{
            
            let UIPoint = MKPointAnnotation()
            
            UIPoint.title=point.Name
        
            UIPoint.coordinate = CLLocationCoordinate2DMake(point.Latitude, point.Longitude)
        
            self.mapView.addAnnotation(UIPoint)
        }
        activityIndicator.isHidden=true
        message.isHidden=true
        
    }
    
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
                    self.count+=1
                    
                    if peeps.count == self.count{
                         isFinishedGettingCoordinates=true
                        if(defaults.bool(forKey: keys.isTimeRunning)){
                            self.startButton.backgroundColor=#colorLiteral(red: 0.01088213548, green: 0.7961999774, blue: 0.2763773501, alpha: 1)
                            self.stopButton.isEnabled=true
                            self.stopButton.backgroundColor=#colorLiteral(red: 0.9993237853, green: 0.1485110521, blue: 0, alpha: 1)
                        }
                        else{
                             self.startButton.isEnabled=true
                             self.startButton.backgroundColor=#colorLiteral(red: 0.01088213548, green: 0.7961999774, blue: 0.2763773501, alpha: 1)
                            self.stopButton.backgroundColor=#colorLiteral(red: 0.9993237853, green: 0.1485110521, blue: 0, alpha: 1)
                        }

                        
                    }
                   
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
            
           return
        }
        
        task.resume()
        return
    }
    var count = 0
    func locationGetter(){
             
              for peep in peeps {
                  if peep.UserId != nil{
                   
                   getCoordinateAPI(peep: peep)
                }
              }
        while(!isFinishedGettingCoordinates){
            
        }
        activityIndicator.stopAnimating()
        checkStatus()
        if(defaults.bool(forKey: keys.isTimeRunning)){
            self.startButton.backgroundColor=#colorLiteral(red: 0.01088213548, green: 0.7961999774, blue: 0.2763773501, alpha: 1)
            self.stopButton.isEnabled=true
            self.stopButton.backgroundColor=#colorLiteral(red: 0.9993237853, green: 0.1485110521, blue: 0, alpha: 1)
        }
        else{
             self.startButton.isEnabled=true
             self.startButton.backgroundColor=#colorLiteral(red: 0.01088213548, green: 0.7961999774, blue: 0.2763773501, alpha: 1)
            self.stopButton.backgroundColor=#colorLiteral(red: 0.9993237853, green: 0.1485110521, blue: 0, alpha: 1)
        }
        message.isHidden=true
        addAnnotions(Points: Points)
    }
    @IBOutlet weak var logBookButton:UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var typeTimerLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var workTimerLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    func checkStatus(){
        
        if defaults.bool(forKey: keys.isTravel)//isTravel {
         {
               workButton.setImage(UIImage(named: "WorkMode"), for: .normal)
             typeTimerLabel.text="TRAVELING"
            typeTimerLabel.textColor=#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
               workTimerLabel.isEnabled=true
               workTimerLabel.backgroundColor = #colorLiteral(red: 0.2114543915, green: 0.808542788, blue: 0.3533751369, alpha: 1)
               timerLabel.isEnabled=false
               timerLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
               
           }
           else {
               workButton.setImage(UIImage(named: "TravelMode"), for: .normal)
            typeTimerLabel.text="WORKING"
            typeTimerLabel.textColor=#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
               timerLabel.isEnabled=true
               timerLabel.backgroundColor = #colorLiteral(red: 0, green: 0.8228648305, blue: 0.2564005256, alpha: 1)
               workTimerLabel.isEnabled=false
               workTimerLabel.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
           }
        if defaults.bool(forKey: keys.isTimeRunning){
            startButton.isEnabled=false
        }
        else{
            startButton.isEnabled=true
            typeTimerLabel.text="None"
            typeTimerLabel.textColor=#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    
    @IBAction func vpButtonRefresh( sender:Any ){
        activityIndicator.startAnimating()
        peeps.removeAll()
        message.isHidden=false
        count=0
        mapView.removeAnnotations(mapView.annotations)
        LoadPeople()
       
    }
    
    @IBAction func workButton( sender:Any ){
           
           defaults.set(!defaults.bool(forKey: keys.isTravel), forKey: keys.isTravel)
           //isTravel = !isTravel
            //defaults.set(isTravel, forKey: keys.isTravel)
           checkStatus()
          
       }
    

    fileprivate func StopAPI(isEndDay:Bool) {
        
        changeServertime()
        
        do{
            let stop = startStopAPI(ServerTimeMinutes: serverTime+1, isEnd: isEndDay, Longitude: (locationManager.location?.coordinate.longitude)!, Latitude: (locationManager.location?.coordinate.latitude)!)
            let loginString = String(format: "%@:%@", username, password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            let url = URL(string: "https://vpstimedev.vantagepnt.com/Api/User/StopTravelInterval")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(stop)
            
            
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
                    result = try
                        JSONDecoder().decode(Result.self, from: data)
                    
                    DispatchQueue.main.async {
                        
                        if(result.ResultCodeName=="Success"){
                            timer.invalidate()
                            //isTimerRunning = false
                            defaults.set(false, forKey: keys.isTimeRunning)
                            
                            if self.workTimerLabel.isEnabled{
                                //workCounter=0.0
                                self.workTimerLabel.text="00.00.00"
                            }
                            else{
                                //counter=0.0
                                self.timerLabel.text="00.00.00"
                            }
                            
                            self.stopButton.isEnabled=false
                            //pauseButton.isEnabled=false
                            self.checkStatus()
                            self.workButton.isEnabled=true
                            
                            
                        }
                        else{
                            
                            defaults.set(true, forKey: keys.isTimeRunning)
                            self.stopButton.isEnabled=true
                            
                            self.checkStatus()
                            self.workButton.isEnabled=false
                            let alertController = UIAlertController(title: "ERROR", message: "Wasn't able to connect to server.", preferredStyle: .alert)
                           alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                           self.present(alertController, animated: true)
                        }
                        
                    }
                    
                    
                } catch let jsonErr {
                    print("error trying to convert data to JSON: ", jsonErr)
                    return
                }
                
                
            }
            task.resume()
        } catch let encodeErr {
            print("error trying to convert data to JSON: ", encodeErr)
            return
        }
    }
    
    @IBAction func stopDidTap( sender:Any ){
        
        let alertController = UIAlertController(title: "Stop?", message: "Do you want to stop for the day?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "End of Day", style: .default, handler: {action in self.StopAPI(isEndDay: true)}))
        alertController.addAction(UIAlertAction(title: "End of timer", style: .default, handler: {action in self.StopAPI(isEndDay: false)}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
        
       
    }
    
    fileprivate func changeServertime() {
        let currentTime = Date()
        var lastHour = 0
        var lastMin = 0
        if(defaults.object(forKey: keys.currentTime)==nil){
            lastHour = calender.component(.hour, from: time)
            
            lastMin = calender.component(.minute, from: time)
        }
        else{
            lastHour = calender.component(.hour, from: defaults.object(forKey: keys.currentTime) as! Date)
            lastMin = calender.component(.minute, from: defaults.object(forKey: keys.currentTime) as! Date)
        }
        
        
        
        let currentHour = calender.component(.hour, from: currentTime)
        let currentMin = calender.component(.minute, from: currentTime)
        
        var minDiff = 0
        var offset=0
        if (currentMin>=lastMin){
            minDiff=currentMin-lastMin
        }
        else{
            minDiff=currentMin-lastMin + 60
            offset+=1
        }
        var hourDiff = 0
        if currentHour>=lastHour{
            hourDiff=currentHour-lastHour-offset
        }
        else{
            hourDiff=currentHour-lastHour+60-offset
        }
        
        
        
        serverTime = serverTime + (hourDiff * 60) + minDiff
        
        defaults.set(currentTime, forKey: keys.currentTime)
        
        defaults.set(serverTime, forKey: keys.serverDate)
    }
    
    fileprivate func startAPI() {
        
        changeServertime()
        
        var intervalType = 0
        
        if(defaults.bool(forKey: keys.isTravel)){intervalType=2}else{intervalType=1} //isTravel){intervalType=2}else{intervalType=1}
        do{
            let start = startStopAPI(ServerTimeMinutes: serverTime+1, IntervalType: intervalType, Longitude: (locationManager.location?.coordinate.longitude)!, Latitude: (locationManager.location?.coordinate.latitude)!)
            let loginString = String(format: "%@:%@", username, password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            let url = URL(string: "https://vpstimedev.vantagepnt.com/Api/User/StartTravelInterval")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(start)
            
            
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
                    result = try
                        JSONDecoder().decode(Result.self, from: data)
                    
                    DispatchQueue.main.async {
                        
                        if(result.ResultCodeName=="Success"){
                            
                            timer = Timer.scheduledTimer( timeInterval:1, target:self, selector:#selector(self.runtime),userInfo:nil,repeats:true)
                            //isTimerRunning=true
                            defaults.set(true, forKey: keys.isTimeRunning)
                            self.workButton.isEnabled=false
                            self.stopButton.isEnabled=true
                            //self.startButton.isEnabled=false
                            self.checkStatus()
                            //isTravel = !isTravel
                            
                            
                            //defaults.set(true, forKey: keys.isTimeRunning)
                            
                        }
                        else{
                            //isTimerRunning=false
                            defaults.set(false, forKey: keys.isTimeRunning)
                            self.workButton.isEnabled=true
                            self.stopButton.isEnabled=false
                            //self.startButton.isEnabled=true
                            self.checkStatus()
                            let alertController = UIAlertController(title: "ERROR", message: "Wasn't able to connect to server.", preferredStyle: .alert)
                          alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                          self.present(alertController, animated: true)
                        }
                        
                    }
                    
                    
                } catch let jsonErr {
                    print("error trying to convert data to JSON: ", jsonErr)
                    return
                }
                
                
            }
            task.resume()
        } catch let encodeErr {
            print("error trying to convert data to JSON: ", encodeErr)
            return
        }
    }
    
    @IBAction func startDidTap( sender:Any ){
        
        let alertController = UIAlertController(title: "Start?", message: "Are you traveling or working?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Traveling", style: .default, handler: {action in
            //isTravel=true
            defaults.set(true, forKey: keys.isTravel)
            self.startAPI()}))
        alertController.addAction(UIAlertAction(title: "Working", style: .default, handler: {action in
            //isTravel=false
            defaults.set(false, forKey: keys.isTravel)
            self.startAPI()}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
        
        
    }

    @objc func runtime(){
        
        let lastDate = defaults.object(forKey: keys.currentTime)
        
        let currentDate=Date()
        
        var second = 0
        var minOffset = 0
        var hourOffset = 0
        var hour = 0
        var minute = 0
        
         if(calender.component(.second, from: currentDate )>=calender.component(.second, from: lastDate as! Date)){
             second = calender.component(.second, from: currentDate )-calender.component(.second, from: lastDate as! Date)
         }
         else{
             second = calender.component(.second, from: currentDate )-calender.component(.second, from: lastDate as! Date) + 60
            minOffset+=1
         }
        
        if(calender.component(.minute, from: currentDate )>=calender.component(.minute, from: lastDate as! Date)){
            minute = calender.component(.minute, from: currentDate )-calender.component(.minute, from: lastDate as! Date) - minOffset
        }
        else{
             minute=calender.component(.minute, from: currentDate )-calender.component(.minute, from: lastDate as! Date)+60 - minOffset
            hourOffset+=1
        }
        
        if(calender.component(.hour, from: currentDate )>=calender.component(.hour, from: lastDate as! Date)){
            hour = calender.component(.hour, from: currentDate )-calender.component(.hour, from: lastDate as! Date) - hourOffset
        }
        else{
            hour=calender.component(.hour, from: currentDate )-calender.component(.hour, from: lastDate as! Date)+60 - hourOffset
        }
    
         var secondString = "\(second)"
         if second<10{
             secondString="0\(second)"
         }
        
        var minuteString = "\(minute)"
        if minute<10{
            minuteString="0\(minute)"
        }
        
        
        
        if workTimerLabel.isEnabled{
            
            workTimerLabel.text = "\(hour):\(minuteString):\(secondString)"
        }
        else{
            timerLabel.text = "\(hour):\(minuteString):\(secondString)"
        }
        
    }

}
extension HomeViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil{
           annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        annotationView?.canShowCallout=true
       return nil
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let regionDistance:CLLocationDistance = 1000;
        let regionSpan = MKCoordinateRegion(center: view.annotation!.coordinate, latitudinalMeters: regionDistance,longitudinalMeters: regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = (view.annotation?.title)!
        mapItem.openInMaps(launchOptions: options)
        print(view.annotation?.title!! ?? "BAD!!!!")
    }
}
