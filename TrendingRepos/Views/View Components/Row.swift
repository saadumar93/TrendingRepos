//
//  Row.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/2/23.
//

import SwiftUI

struct Row: View {
    private(set) var repo:Repo
    
    init(repo:Repo) {
        self.repo = repo
    }
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "circle")
            Spacer()
            VStack(alignment:.leading) {
                Spacer()
                Text(repo.authorName ?? "Non existent author")
                Text(repo.repoName ?? "Non existent repo")
                Text(repo.repoDesc ?? "Non existent description")
                Spacer()
                HStack {
                    Text(repo.language ?? "Uninvented language :(")
                    Text("\(repo.stars)")
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        List {
            Row(repo: Repo.init(context: PersistenceManager.shared.container.viewContext))
        }
    }
}
struct Row_Dark_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        List {
            Row(repo: Repo.init(context: PersistenceManager.shared.container.viewContext))
        }
        .preferredColorScheme(.dark)
    }
}
