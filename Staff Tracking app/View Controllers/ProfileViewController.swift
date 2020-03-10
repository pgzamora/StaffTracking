//
//  ProfileViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/4/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit

extension UIImageView {
       func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
           contentMode = mode
           URLSession.shared.dataTask(with: url) { data, response, error in
               guard
                   let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                   let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                   let data = data, error == nil,
                   let image = UIImage(data: data)
                   else { return }
               DispatchQueue.main.async() {
                   self.image = image
               }
           }.resume()
       }
       func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
           guard let url = URL(string: link) else { return }
           downloaded(from: url, contentMode: mode)
       }
   }


class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: (result.ReturnValue?.Profile?.ProfileImageUrl ?? "")!)!
        var request = URLRequest(url: url)
      
        imageView.downloaded(from: url)
       
        
        let firstName = (result.ReturnValue?.Profile?.FirstName ?? "")
        let lastName = (result.ReturnValue?.Profile?.LastName ?? "")
            nameLabel.text = firstName + "" + lastName
        
        vehicleLabel.text = result.ReturnValue?.Profile?.Vehicle
        phoneLabel.text = result.ReturnValue?.Profile?.PhoneNumber
               
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
   
}
