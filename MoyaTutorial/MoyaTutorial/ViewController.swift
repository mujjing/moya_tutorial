//
//  ViewController.swift
//  MoyaTutorial
//
//  Created by 전지훈 on 2021/06/07.
//

import UIKit
import Moya

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    let userProvider = MoyaProvider<UserService>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readRequest()
    }

    @IBAction func didTapAdd(_ sender: Any) {
        let kilo = User(id: 55, name: "죠르디")
        userProvider.request(.createUser(name: kilo.name)) { result in
            switch result {
            case .success(let response):
                print("create: \(response)")
                let newUser = try! JSONDecoder().decode(User.self, from: response.data)
                self.users.insert(newUser, at: 0)
                self.tableView.reloadData()
            case .failure(let error):
                print("create error : \(error)")
            }
        }
    }
    
    private func readRequest() {
        userProvider.request(.readUsers) { (result) in
            switch result {
            case .success(let response):
                print("read: \(response)")
                //let json = try! JSONSerialization.jsonObject(with: response.data, options: [])
                let users = try! JSONDecoder().decode([User].self, from: response.data)
                self.users = users
                self.tableView.reloadData()
                
            case .failure(let error):
                print("read request error : \(error)")
            }
        }
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let user = users[indexPath.row]
        userProvider.request(.updateUser(id: user.id, name: "[Modified" + user.name)) { result in
            switch result {
            case .success(let response) :
                print("update: \(response)")
                let modifiedUser = try! JSONDecoder().decode(User.self, from: response.data)
                self.users[indexPath.row] = modifiedUser
                self.tableView.reloadData()
            case .failure(let error) :
                print("update error : \(error)")
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let user = users[indexPath.row]
        
        userProvider.request(.deleteUser(id: user.id)) { result in
            switch result {
            case .success(let response) :
                print("Delete: \(response)")
                self.users.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            case .failure(let error) :
                print("delete error : \(error)")
            }
        }

    }
}
