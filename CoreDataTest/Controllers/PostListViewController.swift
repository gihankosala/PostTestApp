//
//  PostListViewController.swift
//  CoreDataTest
//
//  Created by Admin on 3/12/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit
import ReachabilitySwift
import CoreData

class PostListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var postListTableView: UITableView!
    
    
    var networkServices = NetworkServices()
    var responseObject:PostListResponse?
    var selectedResponseObj:PostListResponseElement?
    var selectedPostId = 0
    let connected: Bool = Reachability.init()!.isReachable
    var resultfromDb:Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        //if connection available -- getting from api otherwise getting from local db
        if connected {
            
            getPostList()
            
        }else{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Posts")
            request.returnsObjectsAsFaults = false
            
            do {
                resultfromDb = try context.fetch(request)
                
            } catch {
                
                print("Failed Fetching")
            }
        }
        
        
        
    }
    
    func setUpNavigationBar(){
        
        //navigation bar
        //let backButton = UIBarButtonItem(image: UIImage(named: "back icn"), style: .plain, target: self, action: #selector(backButtonAction(_:)))
        //self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.green
        self.navigationItem.title = "Post List View"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if connected {
            
            if responseObject != nil{
                return (responseObject?.count)!
            }else{
                return 0;
            }
            
        }else{
            
            return (resultfromDb as! [NSManagedObject]).count
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PostListTableViewCell = (self.postListTableView.dequeueReusableCell(withIdentifier: "post_list_tableview_cell") as! PostListTableViewCell?)!
        
        if connected {
            
            let post = responseObject![indexPath.row]
            
            cell.postTitle.text = post.title
            
        }else{
            
            cell.postTitle.text = ((resultfromDb as! [NSManagedObject])[indexPath.row].value(forKey: "title") as! String)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if connected {
            
            selectedResponseObj = responseObject![indexPath.row]
            
        }else{
            
            selectedPostId = ((resultfromDb as! [NSManagedObject])[indexPath.row].value(forKey: "id")) as! Int
            
            
        }
        performSegue(withIdentifier: "show_post_details", sender: self)
        
    }
    
    func getPostList(){
        
        //getting post from api and serialized to response object codable class
        networkServices.getRequestNetworkCallWithCodable(url: "https://jsonplaceholder.typicode.com/posts", headers: ["Content-Type" : "application/json" ,"Authorization": "No \("")"], completionHandler: { response,error in
            
            do {
                if response != nil {
                    let decoder = JSONDecoder()
                    self.responseObject = try decoder.decode(PostListResponse.self, from: response! )
                    
                    DispatchQueue.main.async {
                        self.postListTableView.reloadData()
                        self.saveToDb()
                    }
                }else{
                    self.networkServices.ShowFailiureAlert(title: "Alert", message:"Something wents wrong", in: self)
                    
                }
            } catch let error {
                print(error)
                
            }
        })
        
    }
    
    //adding db to posts
    func saveToDb(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Posts")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
        } catch {
            print("Failed deleting")
        }
        
        
        for i in 0..<responseObject!.count  {
            
            let entity = NSEntityDescription.entity(forEntityName: "Posts", in: context)
            let posts = NSManagedObject(entity: entity!, insertInto: context)
            
            posts.setValue(responseObject![i].id, forKey: "id")
            posts.setValue(responseObject![i].userID, forKey: "userid")
            posts.setValue(responseObject![i].title, forKey: "title")
            posts.setValue(responseObject![i].body, forKey: "body")
            
            
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        
        performSegue(withIdentifier: "show_add_post", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_post_details" ,
            let nextScene = segue.destination as? PostDetailsViewController {
            
            if connected {
                nextScene.selectedResponseObj = selectedResponseObj
            }else{
                nextScene.selectedPostId = selectedPostId
            }
            
            
        }
        
        if segue.identifier == "show_add_post" ,
            let _ = segue.destination as? AddPostViewController {
            
            
        }
    }
    
}
