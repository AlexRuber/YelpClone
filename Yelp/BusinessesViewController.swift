//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var businesses: [Business]!
    var filteredBusinesses = [Business]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar = UISearchBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Setting up the Search Controller
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.titleView = searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search restaurants..."
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.scopeButtonTitles = ["All", "Bars", "Fast Food", "Vegetarian"]
        searchController.searchBar.delegate = self
        
        
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                }
            }

            }
        )
        
//        //Example of Yelp search with more search options specified
//        Business.searchWithTerm(term: "Restaurants", sort: .distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: Error!) -> Void in
//         self.businesses = businesses
//
//         for business in businesses {
//         print(business.name!)
//         print(business.address!)
//         }
//         }
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredBusinesses.count
        }
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as? BusinessCell {

            let business: Business
            if isFiltering() {
                business = filteredBusinesses[indexPath.row]
            } else {
                business = businesses[indexPath.row]
            }

            cell.ratingImageView.setImageWith(business.ratingImageURL!)
            cell.thumbImageView.setImageWith(business.imageURL!)
            cell.nameLabel.text = business.name
            cell.addressLabel.text = business.address
            cell.distanceLabel.text = business.distance
            cell.categoriesLabel.text = business.categories
            let tempNumber = business.reviewCount as! Int
            cell.reviewsCountLabel.text = ("\(String(tempNumber)) reviews")
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Helpers
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredBusinesses = businesses.filter({ (business: Business) -> Bool in
            let doesCategoryMatch = (scope == "All") || (business.categories == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && (business.name?.lowercased().contains(searchText.lowercased()))!
            }
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension BusinessesViewController: UISearchResultsUpdating{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }

}

extension BusinessesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}







