//
//  DetailViewController.swift
//  Flix
//
//  Created by Amy Xiong on 6/17/16.
//  Copyright © 2016 Amy Xiong. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        titleLabel.text = title
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        resizeInfoView()
        
        
        let smallBaseURL = "http://image.tmdb.org/t/p/w45"
        let largeBaseURL = "http://image.tmdb.org/t/p/original"
        
        if let posterPath = movie["poster_path"] as? String {
            let smallImageURL = NSURL(string: smallBaseURL + posterPath)
            let largeImageURL = NSURL(string: largeBaseURL + posterPath)
        
            let smallImageRequest = NSURLRequest(URL: smallImageURL!)
            let largeImageRequest = NSURLRequest(URL: largeImageURL!)
        
            self.posterImageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage
                
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.posterImageView.alpha = 1.0
                        }, completion: { (sucess) -> Void in
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterImageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    self.posterImageView.image = largeImage
                                },
                                failure: { (request, response, error) -> Void in
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    
                    //try to load large image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.posterImageView.alpha = 1.0
                        }, completion: { (sucess) -> Void in
                            self.posterImageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: nil,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    self.posterImageView.image = largeImage
                                },
                                failure: { (request, response, error) -> Void in
                            })
                    })
            })
        }
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func resizeInfoView() {
        let newHeight = titleLabel.frame.height + overviewLabel.frame.height
        let oldHeight = infoView.frame.height
        let padding: CGFloat = 30
        
        let moveDist = oldHeight - newHeight - padding
        
        infoView.frame.offsetInPlace(dx: 0, dy: moveDist)
    }

}


/*extension UIView {
    
    func resizeToFitSubviews() {
        
        
        
        /*
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }
        
        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetInPlace(dx: fix.x, dy: fix.y)
        }
        
        frame.offsetInPlace(dx: fix.x, dy: fix.y)
        frame.offsetInPlace(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
 */
    }
}*/
