//
//  ViewController.swift
//  Search
//
//  Created by Shinto Joseph on 30/06/21.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier:TableView.CellIdentifiers.searchResultCell )
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell,bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        performSearch()
    }
    
    // MARK: - Helper Methods
    
    func iTunesURL(searchText: String, category: Int) -> URL {
      let kind: String
      switch category {
      case 1: kind = "musicTrack"
      case 2: kind = "software"
      case 3: kind = "ebook"
      default: kind = ""
      }
      let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
      let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=200&entity=\(kind)"
      let url = URL(string: urlString)
      return url!
    }
    
    func parse(data:Data) ->[SearchResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch{
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops", message: "There was error accessing itunes store.Please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
// MARK: - Search Bar Delegate
extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      performSearch()
    }
    
    func performSearch() {
      if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()

        hasSearched = true
        searchResults = []

        let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) {data, response, error in
          // 4
          if let error = error as NSError?, error.code == -999 {
            return
          } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            if let data = data {
              self.searchResults = self.parse(data: data)
              //self.searchResults.sort(by: <)
              DispatchQueue.main.async {
                  self.tableView.reloadData()
                }
                return
                self.isLoading = false
            }
          } else {
            print("Failure! \(response!)")
          }
          DispatchQueue.main.async {
            self.hasSearched = false
            self.isLoading = false
            self.tableView.reloadData()
            self.showNetworkError()
          }
        }
        dataTask?.resume()
      }
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "ShowDetail" {
       let detailViewController = segue.destination as! DetailViewController
       let indexPath = sender as! IndexPath
       let searchResult = searchResults[indexPath.row]
       detailViewController.searchResult = searchResult
     }
    }
}

// MARK: - Table View Delegate
extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched{
            return 0
            
        }else if searchResults.count == 0{
            return 1
        }
        else{
            return searchResults.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = TableView.CellIdentifiers.searchResultCell
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! SearchResultCell
        if isLoading {
            let cell = tableView.dequeueReusableCell(
              withIdentifier: TableView.CellIdentifiers.loadingCell,
              for: indexPath)
                
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
          } else if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier:TableView.CellIdentifiers.nothingFoundCell , for: indexPath)
        }
        else{
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
       return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)  
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       if searchResults.count == 0 || isLoading {
            return nil
        }else{
            return indexPath
        }
    }
}
