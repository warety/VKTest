//
//  ViewController.swift
//  VkAppTest
//
//  Created by Алексей on 18.11.17.
//  Copyright © 2017 Алексей. All rights reserved.
//
import VK_ios_sdk
import UIKit

class ViewController: UIViewController, VKSdkDelegate, VKSdkUIDelegate{
    
    var AppID:String! = "6265700";

    override func viewDidLoad() {
        super.viewDidLoad()
        let sdkInstance = VKSdk.initialize(withAppId: AppID);
        sdkInstance?.register(self);
        sdkInstance?.uiDelegate = self;
        let request:VKRequest = VKApi.users().get([VK_API_USER_IDS : 2]);
        var response:VKResponse<VKApiObject>;
        var error:Error;
        
        print("hi");
        
        request.execute(resultBlock: {(response) -> Void in print(response?.json)}, errorBlock: {(error) -> Void in print("er")})
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!)-> Void {
        
    }
    
    func vkSdkUserAuthorizationFailed() {
        
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

