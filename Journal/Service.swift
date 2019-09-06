//
//  Service.swift
//  Journal
//
//  Created by stephan rollins on 9/4/19.
//  Copyright © 2019 OmniStack. All rights reserved.
//

import Foundation

class Service: NSObject {
    static let shared = Service()
    
    let baseUrl = "http://localhost:1440"
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> ())
    {
        guard let url = URL(string: "\(baseUrl)/home") else { return }
        
        var fetchPostsRequest = URLRequest(url: url)
        fetchPostsRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        URLSession.shared.dataTask(with: fetchPostsRequest) { (data, resp, err) in
            DispatchQueue.main.async {
                if let err = err
                {
                    print("Failed to retrieve posts: ", err)
                    return
                }
                
                guard let data = data else { return }
                
                do
                {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                }
                catch
                {
                    completion(.failure(error))
                }
            }
            
            }.resume()
    }
    
    func createPost(title: String, body: String, completion: @escaping (Error?) -> ())
    {
        guard let url = URL(string: "\(baseUrl)/post") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let params = ["title": title, "postBody": body]
        do
        {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
            
            URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
                guard let data = data else { return }
                
                completion(nil)
                
                print(String(data: data, encoding: .utf8)!)
                }.resume()
        }
        catch
        {
            completion(error)
        }
    }
    
    func deletePost(id: Int, completion: @escaping (Error?) -> ())
    {
        guard let url = URL(string: "\(baseUrl)/post/\(id)") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
            //            guard let data = data else { return }
            DispatchQueue.main.async {
                
                if let err = err
                {
                    completion(err)
                }
                
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200
                {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                    completion(NSError(domain: "", code: resp.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                    return
                }
                
                completion(nil)
            }
            }.resume()
    }
}
