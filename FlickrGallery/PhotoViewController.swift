//
//  PhotoViewController.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var imageRequest: RetrieveImageTask?
    
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let photo = self.photo else {
            fatalError("Please set photo! 😇")
        }
        
        activityIndicator.isHidden = false
        
        FlickrConnector.shared.sizes(id: photo.id) { [weak self] (sizes) in
            // Fallback to original size if large isn't available
            let size = sizes?.filter({ $0.label == .large }).first ?? sizes?.filter({ $0.label == .original }).first
            
            guard let strSize = size else {
                self?.activityIndicator.isHidden = true
                return
            }
            
            self?.imageRequest = self?.photoImageView.kf.setImage(with: URL(string: strSize.source))
            
            self?.activityIndicator.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        imageRequest?.cancel()
    }
}
