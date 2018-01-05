//
//  PhotoCell.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import UIKit
import Kingfisher
import Moya

class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    fileprivate var request: Cancellable?
    fileprivate var imageRequest: RetrieveImageTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(photo: Photo) {
        titleLabel.text = photo.title
        photoImageView.image = nil
        
        request?.cancel()
        imageRequest?.cancel()
        
        request = FlickrConnector.shared.sizes(id: photo.id) { [weak self] (sizes) in
            guard let squareSize = sizes?.filter({ $0.label == .square }).first else { return }
            
            self?.imageRequest = self?.photoImageView.kf.setImage(with: URL(string: squareSize.source))
        }
    }
}
