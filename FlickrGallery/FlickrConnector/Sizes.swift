//
//  Sizes.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//


struct Sizes: Codable {
    let sizes: [Size]
    
    enum SizesKeys: String, CodingKey {
        case sizes = "sizes"
    }
    
    enum SizeKeys: String, CodingKey {
        case size = "size"
    }
    
    init(sizes: [Size]) {
        self.sizes = sizes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SizesKeys.self)
        let sizeContainer = try container.nestedContainer(keyedBy: SizeKeys.self, forKey: .sizes)
        
        let sizes = try sizeContainer.decode([Size].self, forKey: .size)
        self.sizes = sizes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SizesKeys.self)
        var sizeContainer = container.nestedContainer(keyedBy: SizeKeys.self, forKey: .sizes)
        
        try sizeContainer.encode(sizes, forKey: .size)
    }
}

struct Size: Codable {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SizeKeys.self)
        
        try container.encode(label, forKey: .label)
        try container.encode(source, forKey: .source)
    }
}

enum SizeType: String, Codable {
    case square = "Large Square"
    case large = "Large"
    case original = "Original"
    case unknown
}
