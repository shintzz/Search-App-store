//
//  ViewController.swift
//  Search
//
//  Created by Shinto Joseph on 30/06/21.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        // Do any additional setup after loading the view.
    }


}
extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        
        if searchBar.text != "Justin Bieber"{
            for i in 0...2{
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d",i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
            
        }
        print("The search text is: '\(searchBar.text!)'")
        hasSearched = true
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched{
            return 0
            
        }else if searchResults.count == 0{
            return 1
        }
        else{
            return searchResults.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        if searchResults.count == 0{
            cell.textLabel?.text = "Nothing Found"
            cell.detailTextLabel!.text = ""
        }
        else{
            let searchResult =  searchResults[indexPath.row]
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = searchResult.artistName
        }
       
        return cell
        //return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       
        if searchResults.count == 0{
            return nil
        }else{
            return indexPath
        }
    }
    
    
}
