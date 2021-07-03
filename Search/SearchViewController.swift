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
        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)        // Do any additional setup after loading the view.
        tableView.register(cellNib, forCellReuseIdentifier:TableView.CellIdentifiers.searchResultCell )
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell,bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        searchBar.becomeFirstResponder()
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
extension SearchViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
        }
        searchResults = []
        let url = iTunesURL(searchText: searchBar.text!)
        print("URL: \(url)")
        dataTask?.cancel()
        isLoading = true
        let session = URLSession.shared
         dataTask = session.dataTask(with: url){data,response,error in
            if let error = error as NSError?, error.code == -999  {
              print("Failure! \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 {
                if let data = data {
                  self.searchResults = self.parse(data: data)
                 // self.searchResults.sort(by: <)
                  DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                  }
                  return
                }
            } else {
              print("Failure! \(response!)")
            }
        }
        dataTask?.resume()
        hasSearched = true
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func iTunesURL(searchText:String) ->URL{
        let encodedString = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urlString =  String(format: "https://itunes.apple.com/search?term=%@", encodedString!)
        let url = URL(string: urlString)
        return url!
    }
    

}

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
            let searchResult =  searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artist.isEmpty {
              cell.artistNameLabel.text = "Unknown"
            } else {
              cell.artistNameLabel.text = String(
                format: "%@ (%@)",
                searchResult.artist,
                searchResult.type)
            }
        }
       return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       if searchResults.count == 0 || isLoading {
            return nil
        }else{
            return indexPath
        }
    }
    
}
