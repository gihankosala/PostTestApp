//
//  PostDetailsViewController.swift
//  CoreDataTest
//
//  Created by Admin on 3/12/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit
import ReachabilitySwift
import CoreData

class PostDetailsViewController: UIViewController {

    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postBody: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var noOfComments: UILabel!
    
    var selectedResponseObj:PostListResponseElement?
    var selectedPostId = 0
    var selectedPostUserId = 0
    let connected: Bool = Reachability.init()!.isReachable
    var networkServices = NetworkServices()
    var usersResponseObject:UsersResponse?
    var selecteduser:UsersResponseElement?
    var commentsResponseObject:CommentsResponse?
    var commentsCount = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpNavigationBar()
        
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
       userName.addGestureRecognizer(tapGesture)
        
        //if connected -- getting data from api, otherwise getting from db
        if connected {
            
            postTitle.text = selectedResponseObj?.title
            postBody.text = selectedResponseObj?.body
            getUsers()
            getComments()
            
        }else{
            //getting post data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Posts")
            request.predicate = NSPredicate(format: "id = %@", String(selectedPostId))
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                postTitle.text = ((result as! [NSManagedObject])[0].value(forKey: "title") as! String)
                postBody.text = ((result as! [NSManagedObject])[0].value(forKey: "body") as! String)
                selectedPostUserId = ((result as! [NSManagedObject])[0].value(forKey: "userid")) as! Int
            } catch {
                
                print("Failed")
            }
            
            //getting users data
            let requestUsers = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            requestUsers.predicate = NSPredicate(format: "id = %@", String(selectedPostUserId))
            requestUsers.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(requestUsers)
                userName.text = ((result as! [NSManagedObject])[0].value(forKey: "username") as! String)

                
            } catch {
                
                print("Failed")
            }
            
            //getting comments data
            let requestComments = NSFetchRequest<NSFetchRequestResult>(entityName: "Comments")
            requestComments.predicate = NSPredicate(format: "postid = %@", String(selectedPostId))
            requestComments.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(requestComments)
                noOfComments.text = String(result.count) + " Comments."
                
                
            } catch {
                
                print("Failed")
            }
            
        }
        
        

        
    }
    
    func setUpNavigationBar(){
        
        //navigation bar
        //let backButton = UIBarButtonItem(image: UIImage(named: "back icn"), style: .plain, target: self, action: #selector(backButtonAction(_:)))
        //self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.green
        self.navigationItem.title = "Post Detail View"
        
    }
    
    @objc func tap(_ gesutureRecognizer: UITapGestureRecognizer) {
        
        if connected{
        performSegue(withIdentifier: "show_map", sender: self)
        }
       
  }
    
    func getUsers(){
        
        //getting users from api and serialized to response object codable class
        networkServices.getRequestNetworkCallWithCodable(url: "https://jsonplaceholder.typicode.com/users", headers: ["Content-Type" : "application/json" ,"Authorization": "No \("")"], completionHandler: { response,error in
            
            do {
                if response != nil {
                    let decoder = JSONDecoder()
                    self.usersResponseObject = try decoder.decode(UsersResponse.self, from: response! )
                    
                    DispatchQueue.main.async {
                        
                        for i in 0...self.usersResponseObject!.count - 1 {
                            
                            if (self.usersResponseObject![i].id == self.selectedResponseObj?.userID){
                                
                                self.userName.text = self.usersResponseObject![i].username
                                self.selecteduser = self.usersResponseObject![i]
                                
                            }
                            
                        }
                        
                        
                        self.saveUsersToDb()
                    }
                }else{
                    self.networkServices.ShowFailiureAlert(title: "Alert", message:"Something wents wrong", in: self)
                    
                }
            } catch let error {
                print(error)
                
            }
        })
        
        
        
    }
    
    func getComments(){
        
        
        //getting Comments from api and serialized to response object codable class
        networkServices.getRequestNetworkCallWithCodable(url: "https://jsonplaceholder.typicode.com/comments", headers: ["Content-Type" : "application/json" ,"Authorization": "No \("")"], completionHandler: { response,error in
            
            do {
                if response != nil {
                    let decoder = JSONDecoder()
                    self.commentsResponseObject = try decoder.decode(CommentsResponse.self, from: response! )
                    
                    DispatchQueue.main.async {
                        
                        for i in 0...self.commentsResponseObject!.count - 1 {
                            
                            if (self.commentsResponseObject![i].postID == self.selectedResponseObj?.id){
                                
                                self.commentsCount += 1
                                
                            }
                            
                        }
                        
                        self.noOfComments.text = String(self.commentsCount) + " Comments."
                        
                        self.saveCommentsToDb()
                    }
                }else{
                    self.networkServices.ShowFailiureAlert(title: "Alert", message:"Something wents wrong", in: self)
                    
                }
            } catch let error {
                print(error)
                
            }
        })
        
        
    }
    
    func saveUsersToDb(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
        } catch {
            print("Failed deleting")
        }
        
        
        for i in 0..<usersResponseObject!.count  {
            
            let entity = NSEntityDescription.entity(forEntityName: "Users", in: context)
            let users = NSManagedObject(entity: entity!, insertInto: context)
            
            users.setValue(usersResponseObject![i].id, forKey: "id")
            users.setValue(usersResponseObject![i].name, forKey: "name")
            users.setValue(usersResponseObject![i].username, forKey: "username")
            users.setValue(usersResponseObject![i].email, forKey: "email")
            
            
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
        
    }
    
    func saveCommentsToDb(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Comments")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
        } catch {
            print("Failed deleting")
        }
        
        
        for i in 0..<commentsResponseObject!.count  {
            
            let entity = NSEntityDescription.entity(forEntityName: "Comments", in: context)
            let comments = NSManagedObject(entity: entity!, insertInto: context)
            
            comments.setValue(commentsResponseObject![i].id, forKey: "id")
            comments.setValue(commentsResponseObject![i].name, forKey: "name")
            comments.setValue(commentsResponseObject![i].postID, forKey: "postid")
            comments.setValue(commentsResponseObject![i].email, forKey: "email")
            comments.setValue(commentsResponseObject![i].body, forKey: "body")
            
            
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_map" ,
            let nextScene = segue.destination as? UserLocationViewController {
            nextScene.selecteduser = selecteduser
        
        }
    
    }
    

}
