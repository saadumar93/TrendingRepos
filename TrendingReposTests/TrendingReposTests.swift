//
//  TrendingReposTests.swift
//  TrendingReposTests
//
//  Created by Saad Umar on 3/2/23.
//

import XCTest
@testable import TrendingRepos
import SwiftUI
import ViewInspector

final class TrendingReposTests: XCTestCase {
    
    //To establish ViewInspector is working fine
    func testViewInspectorBaseline() throws {
        let expected = "Trending"
        let sut = Text(expected)
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, expected)
    }
    
    //Testing row with empty/default fields
    func testRowDefaultText() throws {
        
        let repo = Repo.init(context: PersistenceManager.shared.container.viewContext)
        let view = Row(repo: repo)
        let inspectedRepoAuthor = try view
            .inspect()
            .find(text:AppStrings.defaultRepoAuthor)
            .string()
        XCTAssertEqual(AppStrings.defaultRepoAuthor, inspectedRepoAuthor)
        let inspectedRepoDesc = try view
            .inspect()
            .find(text: AppStrings.defaultRepoDesc)
            .string()
        XCTAssertEqual(AppStrings.defaultRepoDesc, inspectedRepoDesc)
        
    }
    
    //Testing if the loading of repos works fine as expected, asserting that there are one or more items to display
    func testLoadTrendingRepos() throws {
        let viewModel = TrendingGithubRepos(persistenceManager: PersistenceManager.preview)
        let view = TrendingReposView(viewModel: viewModel)
        
        //Setting assertion in view inspection for future (interacting with UI to measure change)
        //For example pullToRefresh should actually bring up new content
        //Which can be done in the following inspection closure
        let expectation = view.inspection.inspect { view in
            XCTAssertNotEqual(viewModel.repos.count, 0)
        }

        //Hosting is required for views to live in, which can be interacted with
        ViewHosting.host(view: view)
        
        self.wait(for: [expectation], timeout: 1.0)
        
    }

}
