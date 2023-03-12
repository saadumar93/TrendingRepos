//
//  ContentView.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/2/23.
//

import SwiftUI
import Shimmer
import CoreData

struct TrendingReposView: View {
    @ObservedObject var viewModel: TrendingGithubRepos
    @EnvironmentObject var networkMonitor: NetworkMonitor

    
    internal let inspection = Inspection<Self>()
    
    var body: some View {
        NavigationView {
            if networkMonitor.isConnected {
                TrendingReposInnerView(viewModel:viewModel)
                .navigationBarTitle(Text("Trending"))
            } else {
                ZStack {
                    backgroundForOfflineView
                    LottieView(lottieFile: "request_failed_retry", autoLoop: .loop)
                }
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self,$0)}
    }
    
    @ViewBuilder
    var backgroundForOfflineView: some View {
        if #available(iOS 14.0, *) {
            Color.white.ignoresSafeArea()
        } else {
            Color.white
        }
    }
    
  ///We can uncomment and use the following modifier to display a popup suggesting user to
    ///use iOS 14 and above because of the known frame issue in iOS 13
//    var iOSVersionCheckModifier: some ViewModifier {
//        if #available(iOS 14, *) {
//            return EmptyModifier()
//        } else {
//            return EmphasizeiOSUpgradeModifier()
//        }
//    }
}

struct TrendingReposInnerView: View {
    @ObservedObject var viewModel: TrendingGithubRepos
    
    var body: some View {
        if !viewModel.repos.isEmpty {
            List(viewModel.repos) { item in
                Row(Repository: item, isLoadingView: viewModel.repos.isEmpty)
            }
        } else {
            loadingView
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        let emptyRepos = Array.init(repeating: Repository.init(context: PersistenceManager.shared.container.viewContext), count: 9)
        List(emptyRepos) { item in
            Row(Repository: item, isLoadingView: viewModel.repos.isEmpty)
        }
    }
}


struct TrendingReposView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingReposView(viewModel: TrendingGithubRepos(persistenceManager: .preview))
            .environmentObject(NetworkMonitor())
    }
}

struct TrendingReposView_Dark_Previews: PreviewProvider {
    static var previews: some View {
        TrendingReposView(viewModel: TrendingGithubRepos(persistenceManager: .preview))
            .preferredColorScheme(.dark)
            .environmentObject(NetworkMonitor())
    }
}
