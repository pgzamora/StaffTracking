//
//  LoginViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 2/22/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit

var result = Result()
var username: String = ""
var password: String = ""



class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invalidLabel.isHidden=true
        // Do any additional setup after loading the view.
    }
  
    
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var invalidLabel: UILabel!
    @IBAction func loginDidTap( sender:Any ) {
        //Get Username and password
        username = usernameTextBox.text ?? ""
        password = passwordTextBox.text ?? ""
        
        //set up for API request
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let url = URL(string: "https://vpstimedev.vantagepnt.com/Api/Account/LogIn")!
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
            result = try
                JSONDecoder().decode(Result.self, from: data)
        print(result.ReturnValue?.Profile?.PhoneNumber ?? "BAD request")
        
            
          } catch let jsonErr {
            print("error trying to convert data to JSON: ", jsonErr)
            return
          }
            
        }
        
        if(result.ResultCodeName=="Success"){
             performSegue(withIdentifier: "logIn", sender: self)
        }
        else{
            invalidLabel.isHidden=false
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! HomeViewController
       
    }
}
