//
//  Article.swift
//  Feeder
//
//  Created by Steve on 6/14/19.
//  Copyright © 2019 Steve Galbraith. All rights reserved.
//

import Foundation

struct ArticlesResponse: Decodable {
    let articles: [Article]

    enum CodingKeys: String, CodingKey {
        case articles
    }
}

struct Article: Decodable {

    var id: Int
    var title: String
    var createdAt: Date
    var source: String
    var description: String
    var favorite: Bool
    var heroImage: URL
    var link: URL

    enum DecodingError: Error, Equatable {
        case invalidCreatedAtDate
        case invalidHeroImageAddress
        case invalidLink
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createdAt = "created_at"
        case source
        case description
        case favorite
        case heroImage = "hero_image"
        case link
    }

    // TODO: Remove HeroImageConverter once networking is implemented to fetch actual URLs.
    // Don't forget to remove images from assets too
    private enum HeroImageConverter: String {
        case mcDonalds = "https://i.kinja-img.com/gawker-media/image/upload/s--swRlLlgJ--/c_scale,dpr_2.0,f_auto,fl_progressive,q_80,w_800/egad24b4d3w3qizatlba.jpg"
        case pluto = "https://cdn.arstechnica.net/wp-content/uploads/2019/02/singer2HR-800x480.jpg"
        case prism = "https://i2.wp.com/www.synthtopia.com/wp-content/uploads/2019/03/QuBit-Prism-closeup.jpeg?resize=708%2C300"
        case emails = "https://cdn-images-1.medium.com/max/1200/1*B-6U0rpniq0HWs9KQIXbSg.jpeg"
        case court = "https://media.npr.org/assets/img/2019/01/31/gettyimages-987348078_wide-ebdf36860dc41366f67f12b365e8ef54a4273bab-s700-c85.jpg"

        var localImageName: String {
            switch self {
            case .mcDonalds:
                return "mcdonalds"
            case .pluto:
                return "pluto"
            case .prism:
                return "prism"
            case .emails:
                return "customerSupport"
            case .court:
                return "sodas"
            }
        }

        var imagePath: String {
            return Bundle.main.path(forResource: localImageName, ofType: "jpg")!
        }
    }

    // TODO: Remove this when networking is enabled and HeroImageConverter is removed since the default implementation from Decode can be used
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)

        createdAt = try container.decode(Date.self, forKey: .createdAt)
        source = try container.decode(String.self, forKey: .source)
        description = try container.decode(String.self, forKey: .description)
        favorite = try container.decode(Bool.self, forKey: .favorite)

        let heroImageString = try container.decode(String.self, forKey: .heroImage)

        guard let converter = HeroImageConverter(rawValue: heroImageString) else {
                throw DecodingError.invalidHeroImageAddress
            }

        heroImage = URL(fileURLWithPath: converter.imagePath)
        let URLString = try container.decode(String.self, forKey: .link)

        guard let articleLink = URL(string: URLString) else { throw DecodingError.invalidLink }

        link = articleLink
    }
}
