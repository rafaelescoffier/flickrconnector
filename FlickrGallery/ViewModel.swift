//
//  ViewModel.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result

class ViewModel {
    typealias PhotosChangeSet = Changeset<Photo>
    
    // Input
    let viewControllerActive = MutableProperty(false)
    
    // Output
    let isLoading: MutableProperty<Bool>
    let refreshObserver: Signal<Void, NoError>.Observer
    let photosChangeSignal: Signal<PhotosChangeSet, NoError>
    
    // Privates
    fileprivate var photos: [Photo]
    fileprivate let photosChangeObserver: Signal<PhotosChangeSet, NoError>.Observer
    
    fileprivate var currentPage = MutableProperty(1)
    
    init() {
        let (photosChangeSignal, photosChangeObserver) = Signal<PhotosChangeSet, NoError>.pipe()
        self.photosChangeSignal = photosChangeSignal
        self.photosChangeObserver = photosChangeObserver
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        isLoading = MutableProperty(false)
        
        self.photos = []
        
        refreshSignal
            .on(event: { _ in self.isLoading.value = true })
            .flatMap(.latest, { _ in
                return SignalProducer<[Photo], NoError> { o, _ in
                    FlickrConnector.search(tag: "kittens", page: self.currentPage.value, completion: { (photos) in
                        o.send(value: photos?.photos ?? [])
                        o.sendCompleted()
                    })
                }
            })
            .on(event: { _ in self.isLoading.value = false })
            .observeValues { [weak self] newPhotos in
                guard let strongSelf = self else { return }
                
                var updatedPhotos = strongSelf.photos
                updatedPhotos.append(contentsOf: newPhotos)
                
                let changeset = Changeset(
                    oldItems: strongSelf.photos,
                    newItems: updatedPhotos,
                    contentMatches: Photo.homeContentMatches
                )
                
                strongSelf.photos = updatedPhotos
                
                photosChangeObserver.send(value: changeset)
            }
        
        // Refresh photos list when view controller is active
        viewControllerActive
            .producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        currentPage
            .signal
            .skipRepeats()
            .map { _ in () }
            .observe(refreshObserver)
    }
    
    func nextPage() {
        guard !isLoading.value else { return }
        
        currentPage.value += currentPage.value
    }
}

// MARK: - Data source
extension ViewModel {
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return photos.count
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
}

// MARK: - ViewController Extensions
extension UIViewController {
    func isActive() -> SignalProducer<Bool, NoError> {
        
        // Track whether view is visible
        let viewDidAppear = self.reactive.trigger(for: #selector(viewDidAppear(_:)))
        let viewWillDisappear = self.reactive.trigger(for: #selector(viewWillDisappear(_:)))
        
        let viewIsVisible = SignalProducer([
            viewDidAppear.map { _ in true },
            viewWillDisappear.map { _ in false }
            ]).flatten(.merge)
        
        // Track whether app is in foreground
        let notificationCenter = NotificationCenter.default
        
        let didBecomeActive = notificationCenter.reactive.notifications(forName: Notification.Name.UIApplicationDidBecomeActive)
        let willBecomeInactive = notificationCenter.reactive.notifications(forName: Notification.Name.UIApplicationWillResignActive)
        
        let appIsActive = SignalProducer([
            didBecomeActive.map { _ in true },
            willBecomeInactive.map { _ in false }
            ]).flatten(.merge)
        
        // View controller is active if both are true:
        let active = SignalProducer([appIsActive, SignalProducer(value: true)]).flatten(.merge)
        
        return SignalProducer.combineLatest(viewIsVisible, active)
            .map { $0 && $1 }
    }
}
