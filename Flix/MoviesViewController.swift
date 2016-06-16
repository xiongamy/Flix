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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var pHUD: M13ProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
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
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            
            self.pHUD!.hide(true)
            
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.tableView.reloadData()
                }
            }
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
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let posterURL = NSURL(string: baseURL + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(posterURL!)
        
        return cell
    }

}
