//
//  ViewController.swift
//  Journal
//
//  Created by stephan rollins on 9/1/19.
//  Copyright © 2019 OmniStack. All rights reserved.
//

import UIKit

struct Post: Decodable {
    let id: Int
    let title, body: String
}


class ViewController: UITableViewController {
    
    @objc fileprivate func fetchPosts()
    {
        Service.shared.fetchPosts { (res) in
            switch res
            {
            case .failure(let err):
                print("Failed to fetch posts", err)
            case .success(let posts):
                //print(posts)
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    var posts = [Post]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        cell.backgroundColor = .red
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchPosts), for: .valueChanged)
        tableView.refreshControl = rc
        fetchPosts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItem = .init(title: "Create Post", style: .plain, target: self, action: #selector(handleCreatePost))
        
        navigationItem.leftBarButtonItem = .init(title: "Login", style: .plain, target: self, action: #selector(handleLogin))
    }
    
    @objc fileprivate func handleLogin()
    {
        guard let url = URL(string: "http://localhost:1440/api/v1/entrance/login") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "PUT"
        
        do
        {
            let params = ["emailAddress": "test1@email.com", "password": "qwertyui"]
            loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            URLSession.shared.dataTask(with: loginRequest) { (data, resp, err) in
                
                if let err = err
                {
                    print("Failed to login: ", err)
                    return
                }
                print("good")
                self.fetchPosts()
            }.resume()
        }
        catch
        {
            print("Failed to serialize data: ", error)
        }

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            print("Delete post")
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id) { (err) in
                if let err = err
                {
                    print("Failed to delete: ", err)
                    return
                }
                //self.tableView.reloadData()
                print("post delete was successfull")
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    @objc fileprivate func handleCreatePost()
    {
        print("creating post")
        Service.shared.createPost(title: "IOS Title", body: "IOS Body") {
            (err) in
            if let err = err {
                print("Failed to create post: ", err)
                return
            }
            
            print("Finished creating post")
            self.fetchPosts()
        }
    }
    
}




























