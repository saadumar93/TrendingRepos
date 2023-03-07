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
    var viewModel: TrendingGithubRepos
    
    internal let inspection = Inspection<Self>()
    
    var body: some View {
        NavigationView {
            List(viewModel.repos) { item in
                Row(repo: item)
            }
            .navigationBarTitle(Text("Trending"))
        }
        .onReceive(inspection.notice) { self.inspection.visit(self,$0)}
    }
    
}


struct TrendingReposView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingReposView(viewModel: TrendingGithubRepos(persistenceManager: .preview))
    }
}

struct TrendingReposView_Dark_Previews: PreviewProvider {
    static var previews: some View {
        TrendingReposView(viewModel: TrendingGithubRepos(persistenceManager: .preview))
            .preferredColorScheme(.dark)
    }
}
