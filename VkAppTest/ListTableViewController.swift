//
//  ListTableViewController.swift
//  VkAppTest
//
//  Created by Алексей on 19.11.17.
//  Copyright © 2017 Алексей. All rights reserved.
//

import VK_ios_sdk
import UIKit
import SwiftyJSON


class ListTableViewController: UITableViewController, VKSdkDelegate, VKSdkUIDelegate,UISearchControllerDelegate, UISearchBarDelegate  {
    
    var searchController: UISearchController!
    
    
    var AppID:String! = "6265700";
    let SCOPE = ["friends"];
    var users: VKUsersArray!
    var user: VKUser!
    var count: Int = 0// Кол-во элементов в массиве VKUsersArray(users.count не всегда работает правильно
    var loadMoreStatus = false
    var offset: Int = 0
    var check = true
    
     @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var RefreshControl: UIRefreshControl!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        searchController = UISearchController(searchResultsController: nil);
        searchController.delegate = self;
        searchController.searchBar.delegate = self;
        searchController.searchBar.placeholder = "Поиск";
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.hidesNavigationBarDuringPresentation = false;
        self.navigationItem.titleView = searchController.searchBar;
        self.spinner.isHidden = true;
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 80.0/255.0, green: 114.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        RefreshControl = UIRefreshControl()
        RefreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        RefreshControl?.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(RefreshControl)
//        tableView.refreshControl = refreshControl
        

        
        
        let sdkInstance = VKSdk.initialize(withAppId: AppID);
        sdkInstance?.register(self);
        sdkInstance?.uiDelegate = self;
        self.initWorkingBlock { (finished) -> Void in
        }

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {[weak self] in self?.searchController.searchBar.becomeFirstResponder()})
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if VKSdk.isLoggedIn() {
            self.check = true
            self.offset = 0
            let userId = VKSdk.accessToken().userId
            if (userId != nil) {
                let req:VKRequest = VKApi.users().search([VK_API_Q : searchBar.text, VK_API_COUNT : 20, VK_API_FIELDS: "photo_100"])
                req.setPreferredLang("ru")
                req.execute(resultBlock: { (response) -> Void in
                    self.users = (response?.parsedModel)! as! VKUsersArray;
                    self.setCount()
                    self.refreshData()
                }, errorBlock: { (error) -> Void in
                    print("Error2: \(error)")
                })
            }
        }
    }
    

    
    @objc func refreshData() {
        self.offset = 0
        self.count = 0
        var users: VKUsersArray!
        let req:VKRequest = VKApi.users().search([VK_API_Q : self.searchController.searchBar.text, VK_API_COUNT : 20, VK_API_OFFSET : self.offset,  VK_API_FIELDS: "photo_100"])
        DispatchQueue.global(qos: .background).async {
            req.setPreferredLang("ru")
            req.execute(resultBlock: { (response) -> Void in
                self.users = (response?.parsedModel)! as! VKUsersArray;
                self.setCount()
                self.tableView.reloadData()
                
            }, errorBlock: { (error) -> Void in
                print("Error2: \(error)")
            })
            
            DispatchQueue.main.async {
                // this runs on the main queue
                self.refreshControl?.endRefreshing()
                
            }
    }
    }
    
    
    func initWorkingBlock (_ completion: ((Bool) -> Void)!){
        
        VKSdk.wakeUpSession(SCOPE as [AnyObject], complete: { (state, error) -> Void in
            if (state == VKAuthorizationState.authorized) {
                print("Authorized and ready to go")
            } else if ((error) != nil) {
                print("Some error happend, but you may try later: \(error)")
            } else {
                VKSdk.authorize(self.SCOPE as [AnyObject])
            }
            completion(true)
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.count > 19{
            let lastElement = self.count-1
            if !self.loadMoreStatus && indexPath.row == lastElement {
                spinner.isHidden = false
                spinner.startAnimating()
                self.loadMoreStatus = true
                loadMoreData()
            }
        }
    }
    
    
    func loadMoreData() {
        if self.check {
            self.offset += 20
            var users: VKUsersArray!
              let req:VKRequest = VKApi.users().search([VK_API_Q : self.searchController.searchBar.text, VK_API_COUNT : 20, VK_API_OFFSET : self.offset,  VK_API_FIELDS: "photo_100"])
            DispatchQueue.global(qos: .background).async {
                req.setPreferredLang("ru")
                req.execute(resultBlock: { (response) -> Void in
                    users = (response?.parsedModel)! as! VKUsersArray;
                    self.addToArray(masterUsers: self.users, slaveUsers: users)
                    self.tableView.reloadData()
                    
                }, errorBlock: { (error) -> Void in
                    print("Error2: \(error)")
                })
                
                DispatchQueue.main.async {
                    // this runs on the main queue
                    self.spinner.stopAnimating()
                    self.loadMoreStatus = false
                    
                }
            }
        }
        else{
            self.spinner.stopAnimating()
            self.loadMoreStatus = false
            self.spinner.isHidden = true
        }
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!){
    
        if let token = VKSdk.accessToken(){
//            print(token);
            
        }
        
    }
    
    func vkSdkUserAuthorizationFailed() {
        
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
       
        
        if (self.users != nil){
            return self.count
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        
        if (self.users != nil && self.users.count > 0) {
            let user: VKUser = self.users[UInt(indexPath.row)]
            let url = URL(string:user.photo_100)
            let data = try? Data(contentsOf: url!)
            let image: UIImage = UIImage(data: data!)!
            
            cell.mainImageView.image = image
            cell.mainLabel?.text = user.first_name + " " + user.last_name
            
            
        }
        

        return cell
    }
    
    func addToArray(masterUsers: VKUsersArray, slaveUsers: VKUsersArray) -> Void {
        
        
        if slaveUsers != nil && slaveUsers.lastObject() != nil{
            let us1: VKUser = slaveUsers.lastObject()
            var count: Int = 0;
            var i:UInt = 0;
            
            while slaveUsers[i] != us1 {
                count = count + 1;
                masterUsers.add(slaveUsers[i])
                i += 1;
            }
            self.count += count;
        }
        else if slaveUsers.lastObject() == nil {
            self.check = false
        }
            
    }
    
    func setCount() -> Void {
        if self.users != nil{
            let us1: VKUser = self.users.lastObject()

            var count: Int = 1;
            var i:UInt = 0;
            
            while self.users[i] != us1 {
                count = count + 1;
                i += 1;
            }
            self.count = count;
        }
    }
    


 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backitem = UIBarButtonItem()
        backitem.title = "Назад"
        navigationItem.backBarButtonItem = backitem
        
        if segue.identifier == "goDetail"
        {
            let detailVC: DetailViewController =  segue.destination as! DetailViewController
            detailVC.user = self.user
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        self.user = self.users[UInt(indexPath.row)]
        performSegue(withIdentifier: "goDetail", sender: self)
    }
 

}
