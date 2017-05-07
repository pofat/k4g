//
//  ViewController.swift
//  knock4games
//
//  Created by Pofat Tseng on 2017/5/1.
//  Copyright © 2017年 Pofat. All rights reserved.
//

import UIKit
import FrostedSidebar
import SVProgressHUD

class ViewController: UIViewController {

    var isLoggingIn: Bool = false
    var sidebar: FrostedSidebar!
    let urlRequestSender = URLSessionRequestSender()
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    
    // make status bar text white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup sidebar menu
        sidebar = FrostedSidebar(itemImages: [
            UIImage(named: "logout")!,
            UIImage(named: "listMember")!,
            UIImage(named: "addMember")!
            ], colors: nil, selectionStyle: .none)
        
        sidebar.actionForIndex = [
            // logout
            0: {self.sidebar.dismissAnimated(true, completion: { [unowned self] finished in self.logout() })},
            1: {self.sidebar.dismissAnimated(true, completion: { finished in print("index 1 pressed") })},
            2: {self.sidebar.dismissAnimated(true, completion: { finished in print("index 2 pressed") })}
        ]
    }
    
    // show sidebar menu
    @IBAction func onBurger() {
        sidebar.showInViewController(self, animated: true)
    }
    
    // login
    @IBAction func onLogin() {
        
        guard !isLoggingIn else {
            return
        }
        // roughly prevent multiple login
        isLoggingIn = true
        
        urlRequestSender.send(TokenRequest(name:"ken", pwd: "hello")) { [unowned self] token in
            guard let token = token else {
                SVProgressHUD.showError(withStatus: "Login failed")
                self.isLoggingIn = false
                return
            }
            
            Token.current = token
            self.avatar.image = UIImage(named: "loggedIn")
            self.loginBtn.setTitle(token.name, for: .normal)
            self.loginBtn.isEnabled = false
            self.isLoggingIn = false
        }
    }
    
    // logout
    func logout() {
        if Token.current != nil {
            Token.current = nil
            avatar.image = UIImage(named: "loggedOut")
            loginBtn.setTitle("Login", for: .normal)
            loginBtn.isEnabled = true
        } else {
            SVProgressHUD.showInfo(withStatus: "Already logged out")
        }
        
    }

}

