//
//  ViewController.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    let viewModel = ViewModel()
    
    let selectedIndexPath = MutableProperty(IndexPath())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PhotoCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        setupSearchViewController()
        bindViewModel()
        
        viewModel.search(for: "Kittens")
    }
    
    private func setupSearchViewController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Kittens"
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        
        definesPresentationContext = true
    }
    
    private func bindViewModel() {
        // Notifies the viewModel of the viewController active status
        viewModel.viewControllerActive <~ isActive()
        
        activityIndicator.reactive.isHidden <~ viewModel.isLoading.producer.map { !$0 }
        
        // Reload the collection view when photo changes
        viewModel
            .photosChangeSignal
            .observe(on: UIScheduler())
            .observeValues({ [weak self] changeset in
                if changeset.deletions.count == 0 && changeset.modifications.count == 0 && changeset.insertions.count == 0 { return }
                
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.deleteItems(at: changeset.deletions)
                    self?.collectionView.reloadItems(at: changeset.modifications)
                    self?.collectionView.insertItems(at: changeset.insertions)
                    
                }, completion: { (completion) in
                })
            })
        
        selectedIndexPath.signal.observeValues { [weak self] _ in
            self?.performSegue(withIdentifier: "PhotoVCSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? PhotoViewController else {
            return
        }
        
        vc.photo = viewModel.photoForIndexPath(selectedIndexPath.value)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            viewModel.nextPage()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            fatalError("Wrong cell type!")
        }
        
        cell.setup(photo: viewModel.photoForIndexPath(indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath.value = indexPath
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let diff = flowLayout.sectionInset.left + (flowLayout.minimumInteritemSpacing / 2)
        
        let size = collectionView.frame.size.width / 2 - diff
        
        return CGSize(width: size , height: size)
    }
}

extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(for: searchController.searchBar.text ?? "")
    }
}
