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
    
    var members: [Member] = []
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
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
            1: {self.sidebar.dismissAnimated(true, completion: { [unowned self] finished in self.listMembers() })},
            2: {self.sidebar.dismissAnimated(true, completion: { [unowned self] finished in self.addMember() })}
        ]
        
        // tableview
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView() // cancel extra separators
        
        // setup button 
        loginBtn.layer.cornerRadius = 5.0
        loginBtn.clipsToBounds = true
        loginBtn.layer.borderColor = UIColor.white.cgColor
        loginBtn.layer.borderWidth = 1.0
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
}


// MARK: Functions for sidebar menu
extension ViewController {
    
    // click logout
    func logout() {
        if Token.current != nil {
            Token.current = nil
            avatar.image = UIImage(named: "loggedOut")
            loginBtn.setTitle("Login", for: .normal)
            loginBtn.isEnabled = true
            // clear tableview
            members = []
            tableView.reloadData()
        } else {
            SVProgressHUD.showInfo(withStatus: "Already logged out")
        }
    }
    
    // click list members
    func listMembers() {
        guard Token.current != nil else {
            SVProgressHUD.showError(withStatus: "Must login to retrieve members")
            return
        }
        
        // check if token is still valid
        if Token.current!.exp > Date() {
            requestMembers()
        } else {
            // refresh token if expired
            urlRequestSender.send(TokenRequest(name:"ken", pwd: "hello")) { [unowned self] token in
                guard let token = token else {
                    SVProgressHUD.showError(withStatus: "Refresh token failed")
                    return
                }
                
                Token.current = token
                self.requestMembers()
            }
        }
        
    }
    
    // click add member with random combination of alphabets
    func addMember() {
        guard Token.current != nil else {
            SVProgressHUD.showError(withStatus: "Must login to add new member")
            return
        }
        
        let newName = String.random(length: 5)
        
        // check if token is still valid
        if Token.current!.exp > Date() {
            reqeustToAddMember(withName: newName)
        } else {
            // refresh token if expired
            urlRequestSender.send(TokenRequest(name:"ken", pwd: "hello")) { [unowned self] token in
                guard let token = token else {
                    SVProgressHUD.showError(withStatus: "Refresh token failed")
                    return
                }
                
                Token.current = token
                self.reqeustToAddMember(withName: newName)
            }
        }
    }
    
    
    
    func requestMembers() {
        urlRequestSender.send(arrayReq: MemberListRequest(authToken: Token.current!.token)) { [unowned self] memberlist in
            guard let memberlist = memberlist else {
                SVProgressHUD.showError(withStatus: "Failed to fetch members")
                return
            }
            
            self.members = memberlist
            self.tableView.reloadData()
        }
    }
    
    func reqeustToAddMember(withName name: String) {
        urlRequestSender.send(operationReq: AddMemberReqeust(authToken: Token.current!.token, name: name)) { [unowned self] success in
            guard success == true else {
                SVProgressHUD.showError(withStatus: "Failed to add new member")
                return
            }
            
            SVProgressHUD.showInfo(withStatus: "Member \"\(name)\" added")
            self.requestMembers()
            
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell!.backgroundColor = .clear
        cell!.textLabel!.textColor = .white
        
        let member = members[indexPath.row]
        cell!.textLabel!.text = "#\(member.id): \(member.name)"
        
        return cell!
    }
}
