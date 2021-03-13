//
//  AddPostViewController.swift
//  CoreDataTest
//
//  Created by Admin on 3/13/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit
import ReachabilitySwift

class AddPostViewController: UIViewController {

    @IBOutlet weak var titleFeild: UITextField!
    
    @IBOutlet weak var bodyFeild: UITextField!
    
     var networkServices = NetworkServices()
     let connected: Bool = Reachability.init()!.isReachable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    func setUpNavigationBar(){
        
        //navigation bar
        //let backButton = UIBarButtonItem(image: UIImage(named: "back icn"), style: .plain, target: self, action: #selector(backButtonAction(_:)))
        //self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.green
        self.navigationItem.title = "Add Post View"
        
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
        if titleFeild.text == "" || bodyFeild.text == "" {
            
            let alert = UIAlertController(title: "Alert", message: "Title or Body Empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            if connected {
            
            let params = [
               "title":titleFeild.text!,
               "body": bodyFeild.text!,
               "userId":"1",
                ] as [String : Any]
            
            
            networkServices.PostRequestNetworkCall(url: "https://jsonplaceholder.typicode.com/posts", headers: ["Content-Type" : "application/json" ,"Authorization": "No \("")",], parameters: params, completionHandler: {responseObject, error in
                    
                    if let key = responseObject?.value(forKey: "key") as? NSDictionary{
                        
                        if let title = key.value(forKey: "title") as? String{
                            
                            
                            let alert = UIAlertController(title: "Alert", message: title + " Saved Successfully", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }else{
                        
                        let alert = UIAlertController(title: "Alert", message: responseObject?.value(forKey: "key") as? String, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                   
                    
                    return
            })
                
            }else{
                let alert = UIAlertController(title: "Alert", message: "No Internet", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
}
