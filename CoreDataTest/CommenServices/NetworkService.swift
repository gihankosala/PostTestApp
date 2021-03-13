//
//  NetworkService.swift
//  CoreDataTest
//
//  Created by Admin on 3/12/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import Alamofire
import ReachabilitySwift

class NetworkServices{
    
    var reachability: Reachability = Reachability.init()!
    let connected: Bool = Reachability.init()!.isReachable
    
    
    func getRequestNetworkCallWithCodable(url : String, headers : [String: String], completionHandler: @escaping (Data? , Error?) -> ()) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding:URLEncoding.default, headers: headers).responseJSON{ response in
            
            
            
            switch response.result {
                
            case .success( _):
                
                completionHandler(response.data! , nil)
                
                
            case .failure(let error):
                
                completionHandler(nil, error)
                
                
            }
            
        }
        
    }
    
    func ShowFailiureAlert(title: String, message: String, in vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    func PostRequestNetworkCall(url : String, headers : [String: String], parameters : [String: Any], completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        //print("Parameters: ", parameters)
        Alamofire.request(url, method: .post, parameters: parameters, encoding:JSONEncoding.default, headers: headers).responseJSON{ response in
            
            //print("response=====",response)
            
            switch response.result {
                
            case .success(let value):
                
                let responseObject:NSDictionary =
                    ["key": value]
                completionHandler(responseObject, nil)
                
                
            case .failure(let error):
                
                if self.connected == true {
                    
                    print("failure error",error.localizedDescription)
                    let responseObject:NSDictionary =
                        
                        ["key": "Server error, cannot retrieve data. Please try in a while"]
                    completionHandler(responseObject, error)
                    
                }
                else
                {
                    let responseObject:NSDictionary =
                        
                        ["key": "No Internet"]
                    completionHandler(responseObject, error)
                    
                }
            }
        }
    }
    
}
