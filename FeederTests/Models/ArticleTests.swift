//
//  ArticleTests.swift
//  FeederTests
//
//  Created by Steve on 6/15/19.
//  Copyright © 2019 Steve Galbraith. All rights reserved.
//

import XCTest
@testable import Feeder

class ArticleTests: XCTestCase {

    var jsonString: String!
    var jsonData: Data!
    let dateFormatter = DateFormatter()

    func testDecodingValidArticle() {
        jsonString = getValidArticlesJSON()
        jsonData = jsonString.data(using: .utf8)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let articleResponse = try decoder.decode(ArticlesResponse.self, from: jsonData)
            XCTAssertEqual(articleResponse.articles.count, 2)

            guard let firstArticle = articleResponse.articles.first else {
                XCTFail("Failed to find the first article")
                return
            }

            XCTAssertEqual(firstArticle.id, 1300)
            XCTAssertEqual(firstArticle.title, "Work Makes Us Lonely. BetterUp Is Working on a Solution to Fix That")
            XCTAssertEqual(firstArticle.description, "There have never been more theories spun about what produces happier, more productive workers. BetterUp is using some actual science to get to the bottom of it.")
            XCTAssertEqual(firstArticle.favorite, true)
            XCTAssertEqual(firstArticle.source, "Inc.")
            XCTAssertEqual(firstArticle.createdAt, Date(timeIntervalSince1970: 1559665920.0))
            XCTAssertEqual(firstArticle.link, URL(string: "https://www.inc.com/magazine/201906/leigh-buchanan/betterup-labs-workplace-organization-management-culture-happiness-research-best-workplaces-2019.html")!)
        } catch {
            XCTFail("Failed with error - \(error)")
        }
    }

    func testDecodingInvalidHeroImageJSON() {
        jsonString = getHeroImageErrorJSON()
        jsonData = jsonString.data(using: .utf8)
        var thrownError: Error?
    
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        XCTAssertThrowsError(try decoder.decode(ArticlesResponse.self, from: jsonData)) {
            thrownError = $0
        }
        XCTAssertTrue(thrownError is Article.DecodingError)
        XCTAssertEqual(thrownError as? Article.DecodingError, .invalidHeroImageAddress)
    }

    func testDecodingInvalidLinkJSON() {
        jsonString = getLinkErrorJSON()
        jsonData = jsonString.data(using: .utf8)
        var thrownError: Error?
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        XCTAssertThrowsError(try decoder.decode(ArticlesResponse.self, from: jsonData)) {
            thrownError = $0
        }
        XCTAssertTrue(thrownError is Article.DecodingError)
        XCTAssertEqual(thrownError as? Article.DecodingError, .invalidLink)
    }

    private func getValidArticlesJSON() -> String {
        return "{\"articles\":[{\"id\":1300,\"title\":\"Work Makes Us Lonely. BetterUp Is Working on a Solution to Fix That\",\"created_at\":\"2019-06-04T16:32:00Z\",\"source\":\"Inc.\",\"description\":\"There have never been more theories spun about what produces happier, more productive workers. BetterUp is using some actual science to get to the bottom of it.\",\"favorite\":true,\"hero_image\":\"https://i.kinja-img.com/gawker-media/image/upload/s--swRlLlgJ--/c_scale,dpr_2.0,f_auto,fl_progressive,q_80,w_800/egad24b4d3w3qizatlba.jpg\",\"link\":\"https://www.inc.com/magazine/201906/leigh-buchanan/betterup-labs-workplace-organization-management-culture-happiness-research-best-workplaces-2019.html\"},{\"id\":1301,\"title\":\"Mobile app makes executive-level coaching available to all\",\"created_at\":\"2018-12-11T12:32:00Z\",\"source\":\"EBN\",\"description\":\"Developed with traditional executive style coaching in mind, mobile-based platform BetterUp gives non-executive employees the opportunity to chat one-on-one with a coach to develop professional skills.\",\"favorite\":true,\"hero_image\":\"https://i.kinja-img.com/gawker-media/image/upload/s--swRlLlgJ--/c_scale,dpr_2.0,f_auto,fl_progressive,q_80,w_800/egad24b4d3w3qizatlba.jpg\",\"link\":\"https://www.benefitnews.com/news/mobile-app-brings-executive-coaching-down-from-the-c-suite\"}]}"
    }

    private func getHeroImageErrorJSON() -> String {
        return "{\"articles\":[{\"id\":1300,\"title\":\"Work Makes Us Lonely. BetterUp Is Working on a Solution to Fix That\",\"created_at\":\"2019-06-04T16:32:00Z\",\"source\":\"Inc.\",\"description\":\"There have never been more theories spun about what produces happier, more productive workers. BetterUp is using some actual science to get to the bottom of it.\",\"favorite\":true,\"hero_image\":\"https://www.betterup.co/wp-content/uploads/2018/10/betterup-facebook-share.png\",\"link\":\"https://www.inc.com/magazine/201906/leigh-buchanan/betterup-labs-workplace-organization-management-culture-happiness-research-best-workplaces-2019.html\"}]}"
    }

    private func getLinkErrorJSON() -> String {
        return "{\"articles\":[{\"id\":1300,\"title\":\"Work Makes Us Lonely. BetterUp Is Working on a Solution to Fix That\",\"created_at\":\"2019-06-04T16:32:00Z\",\"source\":\"Inc.\",\"description\":\"There have never been more theories spun about what produces happier, more productive workers. BetterUp is using some actual science to get to the bottom of it.\",\"favorite\":true,\"hero_image\":\"https://i.kinja-img.com/gawker-media/image/upload/s--swRlLlgJ--/c_scale,dpr_2.0,f_auto,fl_progressive,q_80,w_800/egad24b4d3w3qizatlba.jpg\",\"link\":\"\"}]}"
    }
}
