//
//  FriendsTableViewController.swift
//  VkAppTest
//
//  Created by Алексей on 25.11.17.
//  Copyright © 2017 Алексей. All rights reserved.
//

import UIKit
import VK_ios_sdk

class FriendsTableViewController: UITableViewController {
    
    var user:VKUser!
    var friends:VKUsersArray!
    var offset = 0
    var loadMoreStatus = false
    var count:Int = 0;
    var check = true

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var RefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RefreshControl = UIRefreshControl()
        RefreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        RefreshControl?.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(RefreshControl)
        
        
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        
        
        let req:VKRequest = VKApi.friends().get([VK_API_USER_ID : self.user.id, VK_API_COUNT: 20, VK_API_FIELDS:"photo_100"])
//        let req:VKRequest = VKApi.users().search([VK_API_Q : self.searchController.searchBar.text, VK_API_COUNT : 20, VK_API_OFFSET : self.offset,  VK_API_FIELDS: "photo_100"])
        DispatchQueue.global(qos: .background).async {
            req.setPreferredLang("ru")
            req.execute(resultBlock: { (response) -> Void in
                self.friends = (response?.parsedModel)! as! VKUsersArray;
                self.setCount()
                self.tableView.reloadData()
                
            }, errorBlock: { (error) -> Void in
                print("Error2: \(error)")
            })
            
            DispatchQueue.main.async {
                // this runs on the main queue
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.loadMoreStatus = false
                
            }
        }
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
        if self.friends != nil{
            let us1: VKUser = self.friends.lastObject()
            
            var count: Int = 1;
            var i:UInt = 0;
            
            while self.friends[i] != us1 {
                count = count + 1;
                i += 1;
            }
            self.count = count;
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func refreshData() {
        self.offset = 0
        self.count = 0
        var users: VKUsersArray!
        let req:VKRequest = VKApi.friends().get([VK_API_USER_ID : self.user.id, VK_API_COUNT: 20, VK_API_OFFSET: self.offset, VK_API_FIELDS:"photo_100"])
        DispatchQueue.global(qos: .background).async {
            req.setPreferredLang("ru")
            req.execute(resultBlock: { (response) -> Void in
                self.friends = (response?.parsedModel)! as! VKUsersArray;
                self.setCount()
                self.tableView.reloadData()
                
            }, errorBlock: { (error) -> Void in
                print("Error2: \(error)")
            })
            
            DispatchQueue.main.async {
                // this runs on the main queue
                self.RefreshControl?.endRefreshing()
                
            }
         }
        }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.friends != nil){
            return self.count
        }
        else {
            return 0
        }
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
            let req:VKRequest = VKApi.friends().get([VK_API_USER_ID : self.user.id, VK_API_COUNT: 20, VK_API_OFFSET: self.offset, VK_API_FIELDS:"photo_100"])
            DispatchQueue.global(qos: .background).async {
                req.setPreferredLang("ru")
                req.execute(resultBlock: { (response) -> Void in
                    users = (response?.parsedModel)! as! VKUsersArray;
                    self.addToArray(masterUsers: self.friends, slaveUsers: users)
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        
        if (self.friends != nil && self.friends.count > 0) {
            let user: VKUser = self.friends[UInt(indexPath.row)]
            let url = URL(string:user.photo_100)
            let data = try? Data(contentsOf: url!)
            let image: UIImage = UIImage(data: data!)!
            
            cell.mainImageView.image = image
            cell.mainLabel?.text = user.first_name + " " + user.last_name
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

