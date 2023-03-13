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
        GeometryReader { geometry in
            NavigationView {
                if networkMonitor.isConnected {
                    TrendingReposInnerView(viewModel:viewModel)
                        .navigationBarTitle(Text("Trending"))
                        .modifier(Refreshable { //Our custom ViewModifier which does the iOS version check innately
                            viewModel.retryFetchRepos()
                        })
                } else {
                    ZStack {
                        backgroundForOfflineView
                        requestFailedRetryView
                    }
                }
            }
            .modifier(iOSVersionCheckModifier)
            .onReceive(inspection.notice) { self.inspection.visit(self,$0)}
        }
    }
    
    @State var tap = false

    @ViewBuilder
    var requestFailedRetryView: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                LottieView(lottieFile: "request_failed_retry", autoLoop: .loop)
                ZStack {
                    Text("Retry")
                    .foregroundColor(.green)
                    .frame(width: geometry.size.width - 70, height: 40)
                    .overlay(//Better than cornerRadius, greater control
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.green, lineWidth: 1.25)
                            
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.retryFetchRepos()
                        tap.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            tap = false
                        }
                    }
                    .scaleEffect(tap ? 1.2 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6))
                }
               
            }
        }
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
    var iOSVersionCheckModifier: some ViewModifier {
        if #available(iOS 14, *) {
            return EmptyModifier()
        } else {
            return EmphasizeiOSUpgradeModifier()
        }
    }
}

struct TrendingReposInnerView: View {
    @ObservedObject var viewModel: TrendingGithubRepos
    
    var body: some View {
        if !viewModel.repos.isEmpty {
            List(viewModel.repos, id:\.id) { item in
                Row(Repository: item, isLoadingView: viewModel.repos.isEmpty)
            }
        } else {
            loadingView
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        List(emptyRepos, id: \.id) { item in
            Row(Repository: item, isLoadingView: viewModel.repos.isEmpty)
        }
    }
    
    var emptyRepos: [Repository] {
        var repos : [Repository] = []
        for _ in 0..<10 {
            let repo = Repository.init(with: UUID())
            repos.append(repo)
        }
        return repos
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
