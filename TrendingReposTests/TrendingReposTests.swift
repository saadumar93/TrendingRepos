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
import Network

final class TrendingReposTests: XCTestCase {
    
    //MARK: Baseline
    ///To establish ViewInspector is working fine
    func testViewInspectorBaseline() throws {
        let expected = "Trending"
        let sut = Text(expected)
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, expected)
    }
    
    //MARK: View tests
    ///Testing row with empty/default fields
    func testRowDefaultText() throws {
        
        let repository = Repository.init(context: PersistenceManager(inMemory: true).container.viewContext)
        repository.authorName = AppStrings.Stuffed.defaultRepositoryAuthor
        repository.repoName = AppStrings.Stuffed.defaultRepository
        repository.repoDesc = AppStrings.Stuffed.defaultRepositoryDesc
        repository.language = AppStrings.Stuffed.defaultRepositoryLanguage
        repository.stars = AppStrings.Stuffed.defaultStars
        
        let view = Row(Repository: repository)
        
        let inspectedRepositoryImage = try view
            .inspect()
            .hStack()
            .hStack(0)
            .image(0)
            .actualImage()
        let expectedRepositoryImage = Image(systemName: AppStrings.Stuffed.defaultAuthorImgSysName)
            .resizable()
        XCTAssertEqual(expectedRepositoryImage, inspectedRepositoryImage)
        let inspectedRepositoryAuthor = try view
            .inspect()
            .find(text:AppStrings.Stuffed.defaultRepositoryAuthor)
            .string()
        XCTAssertEqual(AppStrings.Stuffed.defaultRepositoryAuthor, inspectedRepositoryAuthor)
        let inspectedRepository = try view
            .inspect()
            .find(text: AppStrings.Stuffed.defaultRepository)
            .string()
        XCTAssertEqual(AppStrings.Stuffed.defaultRepository, inspectedRepository)
        
        //Test Row, tap and expand behaviour
        let expectation = view.inspection.inspect { view in
            try view.hStack().callOnTapGesture()
            let inspectedRepositoryDesc = try view
                .find(text: AppStrings.Stuffed.defaultRepositoryDesc)
                .string()
            XCTAssertEqual(AppStrings.Stuffed.defaultRepositoryDesc, inspectedRepositoryDesc)
            let inspectedRepositoryLanguage = try view
                .find(text: AppStrings.Stuffed.defaultRepositoryLanguage)
                .string()
            XCTAssertEqual(AppStrings.Stuffed.defaultRepositoryLanguage, inspectedRepositoryLanguage)
            let inspectedReposStars = try view
                .find(text: "\(AppStrings.Stuffed.defaultStars)")
                .string()
            XCTAssertEqual(String(describing: AppStrings.Stuffed.defaultStars), inspectedReposStars)
        }
        
        //ViewHosting allows the Views to be 'alive' by letting them live in itself, hence we are able to interact with the views
        ViewHosting.host(view: view)
        self.wait(for: [expectation], timeout: 1.0)
        
    }
    
    ///Testing that if there is no data yet, shimmer is visible
    @MainActor func testIsShimmeringWorkingIfNoData() throws {
        let viewModel = TrendingGithubRepos()
        let view = TrendingReposView(viewModel: viewModel).environmentObject(NetworkMonitor())
        
        let sut = try view.inspect().find(TrendingReposInnerView.self).actualView()
        if (sut.viewModel.repos.isEmpty) {
            XCTAssertTrue(try sut.loadingView.inspect().list().find(Row.self).actualView().isLoadingView)
        }
        
    }
    
    ///Testing the shimmer is no more visible if there is data, asserting isLoadingView false
    @MainActor func testIsShimmeringIsHiddenIfData() throws {
        let viewModel = TrendingGithubRepos()
        let view = TrendingReposView(viewModel: viewModel).environmentObject(NetworkMonitor())
        
        let sut = try view.inspect().find(TrendingReposInnerView.self).actualView()

        if (!sut.viewModel.repos.isEmpty) {
            XCTAssertFalse(try sut.loadingView.inspect().list().find(Row.self).actualView().isLoadingView)
        }
        
    }

    //MARK: Network tests
    ///To test default animation happens when network fails due to bad/no  internet
    func testNetworkFailureViewReaction() throws {
        let networkMonitor = NetworkMonitor()
        let viewModel = TrendingGithubRepos()
        let view = TrendingReposView(viewModel: viewModel).environmentObject(NetworkMonitor())
        
        //will not be able to find offline animation (GIFView) if it is not up for some reason
        if !networkMonitor.isConnected {
            _ = try view.inspect().find(LottieView.self).actualView()
        } else {
            _ = try view.inspect().find(TrendingReposInnerView.self).actualView()
        }
    }
    
    //MARK: View Model Tests
    ///Testing after loading of Repositories works, asserting that there are one or more items to display
    func testLoadingTrendingRepositories() async throws {
        let viewModel = TrendingGithubRepos(persistenceManager: PersistenceManager.preview)
        let expectation = expectation(description: "Getting repos from network call")
        
        await viewModel.fetchAllRepositories()
        expectation.fulfill()
        
        await waitForExpectations(timeout: 10.0)

        Task { @MainActor in
            XCTAssertFalse(viewModel.repos.isEmpty)
        }
    }
    
}
