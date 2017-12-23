//
//  Sizes.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//


struct Sizes: Decodable {
    let sizes: [Size]
    
    enum SizesKeys: String, CodingKey {
        case sizes = "sizes"
    }
    
    enum SizeKeys: String, CodingKey {
        case size = "size"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SizesKeys.self)
        let sizeContainer = try container.nestedContainer(keyedBy: SizeKeys.self, forKey: .sizes)
        
        let sizes = try sizeContainer.decode([Size].self, forKey: .size)
        self.sizes = sizes
    }
}

struct Size: Decodable {
    let label: SizeType
    let source: String
    
    enum SizeKeys: String, CodingKey {
        case label = "label"
        case source = "source"
    }
    
    init(label: String, source: String) {
        self.label = SizeType(rawValue: label) ?? .unknown
        self.source = source
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SizeKeys.self)
        
        let label = (try? container.decode(SizeType.self, forKey: .label)) ?? .unknown
        let source = try container.decode(String.self, forKey: .source)
        
        self.label = label
        self.source = source
    }
}

enum SizeType: String, Decodable {
    case square = "Large Square"
    case large = "Large"
    case original = "Original"
    case unknown
}
