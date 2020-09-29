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
    
    // Number of sections (grouped by List IDs)
    func numberOfSections(in tableView: UITableView) -> Int {
        return listSortedById.keys.count
    }
    
    // Disables highlighting of rows when clicked
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Number of data objects per List ID
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[section].count
    }
    
    // Section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        let bgColor = UIColor(red: 0, green: 128/255, blue: 128/255, alpha: 1)
        headerView.backgroundColor = bgColor
        headerView.text = "\tList ID : \(sectionData[section][0].listId)"
        headerView.shadowColor = .black
        headerView.shadowOffset = CGSize.init(width: 1, height: 0)
        
        headerView.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        headerView.textColor = .white
        headerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return headerView
    }
    
    // Display each data object in a list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        }
        
        
        cell?.textLabel?.text = sectionData[indexPath.section][indexPath.row].name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        cell?.detailTextLabel?.text = "ID:\t\(sectionData[indexPath.section][indexPath.row].id)"
        cell?.detailTextLabel?.textAlignment = .left
        cell?.textLabel?.textColor = .black
        cell?.detailTextLabel?.textColor = .black
        cell?.backgroundColor = .white
        cell?.detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        cell?.detailTextLabel?.leadingAnchor.constraint(equalTo: (cell?.contentView.trailingAnchor)!, constant: -100).isActive = true
        cell?.detailTextLabel?.centerYAnchor.constraint(equalTo: (cell?.contentView.centerYAnchor)!).isActive = true
        return cell!
    }
    
        
    
    let urlString = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
    
    var list: [Item] = []
    var listSortedById: [Int : [Item]] = [:]
    let cellID: String = "cellid"
    var sectionData = [[Item]]()
    
    
  
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
                if $0.listId == $1.listId {
                    return $0.id < $1.id
                }
                return false
            }
            
            // Create separate lists for each List ID
            self?.list.forEach {

                if let _ = self?.listSortedById[$0.listId] {
                    self?.listSortedById[$0.listId]?.append($0)
                }
                else {
                    self?.listSortedById[$0.listId] = [$0]
                }
            }
            
            // Makes grouped object lists compatible with table-view structure
            // Accounts for non-sequential list IDs
            for (_, list) in self!.listSortedById {
                self?.sectionData.append(list)
            }
            
            // Orders the section data by list ID
            self?.sectionData.sort {
                $0[0].listId < $1[0].listId
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
        
        mainTableView.layer.cornerRadius = 15
        
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
                    // HTTP Status Code
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    let decoder = JSONDecoder()
                    // Send parsed JSON data to callback function
                    if let tempList = try? decoder.decode([Item].self, from: data) {
                        completion(tempList)
                    }

                }
            }
        }
        task.resume()
        
        
        
    }
    
    

}

