//
//  UserLocationViewController.swift
//  CoreDataTest
//
//  Created by Admin on 3/13/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit
import MapKit

class UserLocationViewController: UIViewController {

    @IBOutlet weak var mapViewForUser: MKMapView!
    
    var selecteduser:UsersResponseElement?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupLocation()
       
    }
    
    func setUpNavigationBar(){
         
         //navigation bar
         //let backButton = UIBarButtonItem(image: UIImage(named: "back icn"), style: .plain, target: self, action: #selector(backButtonAction(_:)))
         //self.navigationItem.leftBarButtonItem = backButton
         self.navigationItem.leftBarButtonItem?.tintColor = UIColor.green
         self.navigationItem.title = "Map View"
         
     }
    
    func setupLocation() {
        
        var c = CLLocationCoordinate2D()
        
        let lat:Double = Double((selecteduser?.address.geo.lat)! as String)!
        
        let long:Double = Double((selecteduser?.address.geo.lng)! as String)!
        
        c.latitude = lat
        c.longitude = long
        
        let a = MKPointAnnotation()
        a.coordinate = c
        a.title = selecteduser!.name + ",\n" + selecteduser!.address.street + ",\n" + selecteduser!.address.city
        mapViewForUser.addAnnotation(a)
        mapViewForUser.setCenter(c, animated: true)
        
    }

   

}
