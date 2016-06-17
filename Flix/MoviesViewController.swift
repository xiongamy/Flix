//
//  MoviesViewController.swift
//  Flix
//
//  Created by Amy Xiong on 6/15/16.
//  Copyright © 2016 Amy Xiong. All rights reserved.
//

import UIKit
import AFNetworking
import M13ProgressSuite

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pHUD: M13ProgressHUD?
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        filteredMovies = movies
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        let (request, session) = makeRequest()
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            self.getData(dataOrNil, response: response, error: error)
        })
        task.resume()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        pHUD = showHUD()
    }

    
    func showHUD() -> M13ProgressHUD {
        let progressView = M13ProgressViewRing.init()
        progressView.indeterminate = true
        self.view.addSubview(progressView)
        let HUD = M13ProgressHUD(progressView: progressView)
        HUD.progressViewSize = CGSizeMake(80.0, 80.0)
        HUD.animationPoint = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        let window: UIWindow! = (UIApplication.sharedApplication().delegate as! AppDelegate).window
        window.addSubview(HUD)
        HUD.show(true)
        
        return HUD
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movies != nil {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let posterURL = NSURL(string: baseURL + posterPath)
            cell.posterView.setImageWithURL(posterURL!)
        } else {
            cell.posterView.image = nil
        }
        
        return cell
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else if movies != nil {
            // The user has entered text into the search box
            // And items exist to iterate over
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredMovies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (dataItem["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        self.pHUD!.show(true)
        
        let (request, session) = makeRequest()
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            self.getData(dataOrNil, response: response, error: error)
                                                                        
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    //Makes a network request to The Movie Databases's Now Playing movie list.
    //Returns a tuple containing the request and the session to be used in a task.
    func makeRequest() -> (request: NSURLRequest, session: NSURLSession) {
        let apiKey = "77e39e6fb6ea72b339bcf3e67eb06034"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        return (request, session)
    }
    
    //Attempt to get movie data
    func getData(dataOrNil: NSData?, response: NSURLResponse?, error: NSError?) {
        self.pHUD!.hide(true)
        
        if error != nil {
            self.networkErrorView.hidden = false
        } else {
            self.networkErrorView.hidden = true
        }
        
        //Get new data
        if let data = dataOrNil {
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                
                self.movies = responseDictionary["results"] as? [NSDictionary]
                filteredMovies = movies
                self.tableView.reloadData()
            }
        }
    }
}
