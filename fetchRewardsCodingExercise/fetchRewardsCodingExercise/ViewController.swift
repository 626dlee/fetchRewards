//
//  ViewController.swift
//  fetchRewardsCodingExercise
//
//  Created by David Lee on 9/28/20.
//  Copyright © 2020 D.Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Structure for each object from data (Contains listId, id, and optional name)
    struct Item: Decodable {
        let listId: Int
        let id: Int
        let name: String?
    }
    
    
    let urlString = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
    var list: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch and parse JSON data
        reqData { [weak self] (items) in
            self?.list = items
            print("parsed \(self?.list)")
        }
        
        

    }
    
    // Gets an array of Items from API GET request
    func reqData(completion: @escaping ([Item]) -> Void) {
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Error handling
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {

                    let decoder = JSONDecoder()
                    if let tempList = try? decoder.decode([Item].self, from: data) {
                        completion(tempList)
                    }

                }
            }
        }
        task.resume()
        
        
        
    }
    
    

}

