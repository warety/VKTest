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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil);
        searchController.delegate = self;
        searchController.searchBar.delegate = self;
        searchController.searchBar.placeholder = "Поиск";
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.hidesNavigationBarDuringPresentation = false;
        self.navigationItem.titleView = searchController.searchBar;

        
        
        let sdkInstance = VKSdk.initialize(withAppId: AppID);
        sdkInstance?.register(self);
        sdkInstance?.uiDelegate = self;
        self.initWorkingBlock { (finished) -> Void in
        }
//
//        let isLogged = VKSdk.isLoggedIn()
//        if isLogged == true {
//
//            print("Пользователь авторизован")
//
//
//        } else if isLogged == false {
//
//            print("Пользователь не авторизован")
//            VKSdk.authorize(SCOPE);
//            print(VKSdk.isLoggedIn());
//
//        }
//        let request:VKRequest = VKApi.users().get();
//        var response:VKResponse<VKApiObject>;
//        var error:Error;
//        print("hiii");
//
//        request.execute(resultBlock: {(response) -> Void in print(response?.json)}, errorBlock: {(error) -> Void in print("er")})
        // Do any additional setup after loading the view, typically from a nib.

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            let userId = VKSdk.accessToken().userId
            if (userId != nil) {
                let req:VKRequest = VKApi.users().search([VK_API_Q : searchBar.text, VK_API_COUNT : 20])
                req.setPreferredLang("ru")
                req.execute(resultBlock: { (response) -> Void in
                    print(response?.parsedModel);
                    print(response?.json)
                    self.users = (response?.parsedModel)! as! VKUsersArray;
                    self.tableView.reloadData();
                    
                    
                    
                   
                    
                    //                                    let user = response?.parsedModel.fields[0] as! VKUser
                    //
                    //                                    print("Пользователь ВК: \(user.fields)")
                    
                }, errorBlock: { (error) -> Void in
                    print("Error2: \(error)")
                })
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
            self.vkGetUser()
            print("completion VKSdk.wakeUpSession")
        })
    }
    func vkGetUser(){
        if VKSdk.isLoggedIn() {
            let userId = VKSdk.accessToken().userId
            if (userId != nil) {
                VKApi.users().get([VK_API_FIELDS: "first_name, last_name, id, photo_100, sex, bdate, country", VK_API_USER_ID: userId]).execute(resultBlock: { (response) -> Void in
                    print(response);
                    print(response?.json);
                
                
                    
                                    
//                                    let user = response?.parsedModel.fields[0] as! VKUser
//
//                                    print("Пользователь ВК: \(user.fields)")
                                    
                                   }, errorBlock: { (error) -> Void in
                                    print("Error2: \(error)")
                                   })
            }
        }
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!){
        print(result);
        if let token = VKSdk.accessToken(){
            print(token);
            
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
        if (self.users != nil && self.users.count > 0){
            return (Int(self.users.count))
        }
        else{
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if (self.users != nil && self.users.count > 0) {
            print("hello form cell")
            let user: VKUser = self.users[UInt(indexPath.row)]
        
            cell.textLabel?.text = user.first_name + " " + user.last_name
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
