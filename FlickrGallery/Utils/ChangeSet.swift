//
//  ChangeSet.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import Foundation

struct Changeset<T: Equatable> {
    
    var deletions: [IndexPath]
    var modifications: [IndexPath]
    var insertions: [IndexPath]
    
    var updated: Bool { return !(deletions.isEmpty && modifications.isEmpty && insertions.isEmpty) }
    
    typealias ContentMatches = (T, T) -> Bool
    
    init(oldItems: [T], newItems: [T], contentMatches: @escaping ContentMatches) {
        
        deletions = oldItems.difference(newItems).map { item in
            return Changeset.indexPathForIndex(oldItems.index(of: item)!)
        }
        
        modifications = oldItems.intersection(newItems)
            .filter({ item in
                let newItem = newItems[newItems.index(of: item)!]
                return !contentMatches(item, newItem)
            })
            .map({ item in
                return Changeset.indexPathForIndex(oldItems.index(of: item)!)
            })
        
        insertions = newItems.difference(oldItems).map { item in
            return IndexPath(row: newItems.index(of: item)!, section: 0)
        }
    }
    
    fileprivate static func indexPathForIndex(_ index: Int) -> IndexPath {
        return IndexPath(row: index, section: 0)
    }
}

// MARK: - Array Extensions
extension Array {
    func difference<T: Equatable>(_ otherArray: [T]) -> [T] {
        var result = [T]()
        
        for e in self {
            if let element = e as? T {
                if !otherArray.contains(element) {
                    result.append(element)
                }
            }
        }
        
        return result
    }
    
    func intersection<T: Equatable>(_ otherArray: [T]) -> [T] {
        var result = [T]()
        
        for e in self {
            if let element = e as? T {
                if otherArray.contains(element) {
                    result.append(element)
                }
            }
        }
        
        return result
    }
}
