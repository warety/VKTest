//
//  DetailViewController.swift
//  VkAppTest
//
//  Created by Алексей on 21.11.17.
//  Copyright © 2017 Алексей. All rights reserved.
//

import UIKit
import VK_ios_sdk

struct Value{
    var str1: String!
    var str2: String!
}

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user: VKUser!
    var values = [Value]()

    @IBOutlet weak var tebleView: UITableView!
    @IBOutlet weak var image: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = user.first_name + " " + user.last_name
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        print(VKSdk.accessToken())
        tebleView.delegate = self
        tebleView.dataSource = self
        let nib = UINib(nibName: "DetailTableViewCell", bundle: nil)
        self.tebleView.register(nib, forCellReuseIdentifier: "CellDetail")
        
        
        if user != nil{
            
            let req:VKRequest! = VKApi.users().get([VK_API_USER_IDS : self.user.id, VK_API_FIELDS : "screen_name, photo_max, sex, relation"])
            req.setPreferredLang("ru")
            req.execute(resultBlock: { (response) -> Void in
                let users = (response?.parsedModel)! as! VKUsersArray
                self.user = users[0]
                self.converToValue(user: self.user)
                let url = URL(string:self.user.photo_max)
                let data = try? Data(contentsOf: url!)
                self.image.image = UIImage(data: data!)!
                self.tebleView.reloadData()
                print("HIII")
            }, errorBlock: { (error) -> Void in
                print("Error2: \(error)")
            })
        }

    }
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(values.count)
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cellDetail = tebleView.dequeueReusableCell(withIdentifier: "CellDetail", for: indexPath) as? DetailTableViewCell
        

        let value = self.values[indexPath.row]
        print(value.str2)
        cellDetail?.label1.text = value.str1
        cellDetail?.label2.text = value.str2
    
        
        
        return cellDetail!
    }
    
    func converToValue(user: VKUser){
        if let firstName = user.first_name{
            self.values.append(Value(str1: "Имя", str2:  firstName))
            print(self.values[0].str2)
        }
        if let lastName = user.last_name{
            self.values.append(Value(str1: "Фамилия", str2: lastName))
        }
        if let screenName = user.screen_name{
            self.values.append(Value(str1: "screenname", str2: screenName))
        }
        if let sex = user.sex{
            if sex == 1{
                self.values.append(Value(str1: "Пол", str2: "Женский"))
            }
            else if sex == 2{
                self.values.append(Value(str1: "Пол", str2: "Мужской"))
            }
            else if sex == 0{
                self.values.append(Value(str1: "Пол", str2: "Пол не указан"))
            }
            
        }
        if let relation = user.relation{
            switch relation{
            case 1: self.values.append(Value(str1: "Семейное положение", str2: "Не в браке"))
            case 2: self.values.append(Value(str1: "Семейное положение", str2: "Есть друг/подруга"))
            case 3: self.values.append(Value(str1: "Семейное положение", str2: "Помолвлен"))
            case 4: self.values.append(Value(str1: "Семейное положение", str2: "В браке"))
            case 5: self.values.append(Value(str1: "Семейное положение", str2: "Все сложно"))
            case 6: self.values.append(Value(str1: "Семейное положение", str2: "В активном поиске"))
            case 7: self.values.append(Value(str1: "Семейное положение", str2: "Влюблен"))
            case 8: self.values.append(Value(str1: "Семейное положение", str2: "В гражданском браке"))
            default:
                self.values.append(Value(str1: "Семейное положение", str2: "Не указано"))
            }
        }
    }
    
    
    @IBAction func friendButtonAction(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriends"
        {
            let FriendsTVC: FriendsTableViewController =  segue.destination as! FriendsTableViewController
            FriendsTVC.user = self.user
            
        }
    }
    


}
