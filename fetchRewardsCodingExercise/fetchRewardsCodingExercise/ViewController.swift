//
//  ViewController.swift
//  fetchRewardsCodingExercise
//
//  Created by David Lee on 9/28/20.
//  Copyright © 2020 D.Lee. All rights reserved.
//

import UIKit


// MVC MODEL
// Structure for each object from data (Contains listId, id, and optional name)
struct Item: Decodable {
    let listId: Int
    let id: Int
    let name: String?
}


// MVC CONTROLLER
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Number of data objects
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    // Display each data object in a list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        }
        
        
        cell?.textLabel?.text = list[indexPath.row].name
        cell?.detailTextLabel?.text = "List ID: \(list[indexPath.row].listId)\tID: \(list[indexPath.row].id)"
        cell?.textLabel?.textColor = .white
        cell?.detailTextLabel?.textColor = .white
        return cell!
    }
    
        
    
    let urlString = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
    var list: [Item] = []
    var differentListIds: [Int: Int] = [:]
    let cellID: String = "cellid"
    
    // MVC VIEW
    var mainTableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Fetch and parse JSON data
        reqData { [weak self] (items) in
            self?.list = items
            
            // Filter out items with an empty name or 'null'
            self?.list = (self?.list.filter({ $0.name != "" && $0.name != nil}))!
            
            // Sort data by list ID
            self?.list.sort { $0.listId < $1.listId}
            
            // Sort data again by item name
            self?.list.sort {
                self?.differentListIds[$0.listId] = (self?.differentListIds[$0.listId] ?? 0) + 1
                if $0.listId == $1.listId {
                    return $0.id < $1.id
                }
                return false
            }
            
            // Update list with API data
            DispatchQueue.main.async {
                self?.mainTableView.reloadData()
            }
        }
        
        // MVC VIEW SETUP
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        mainTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        

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
                    print("data: \(data)")
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

