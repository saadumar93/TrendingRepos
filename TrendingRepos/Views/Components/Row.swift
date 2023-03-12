//
//  Row.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/2/23.
//

import SwiftUI
import URLImage

///The basic building block our TrendingRepos app which makes a row for us
struct Row: View {
    @Environment(\.colorScheme) var colorScheme
    private(set) var repo:Repository
    var isLoadingView = false
    
    init(Repository:Repository, isLoadingView:Bool = false) {
        self.repo = Repository
        self.isLoadingView = isLoadingView
    }
    
    var body: some View {
        HStack {
            HStack {
                authorImg
                    .frame(minWidth: 50, minHeight: 50)
                    .padding([.leading,.trailing])
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                    .clipShape(Circle())
            }
            VStack(alignment:.leading) {
                Spacer()
                Text(repo.authorName ?? AppStrings.Stuffed.defaultRepositoryAuthor)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                Text(repo.repoName ?? AppStrings.Stuffed.defaultRepository)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                Text(repo.repoDesc ?? AppStrings.Stuffed.defaultRepositoryDesc)
                    .lineLimit(3)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                Spacer()
                HStack {
                    Text(repo.language ?? AppStrings.Stuffed.defaultRepositoryLanguage)
                        .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                    Text("\(repo.stars)")
                        .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                }
                Spacer()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var authorImg: some View {
        if let urlString = repo.authorImageURL, !urlString.isEmpty {
            if let url = URL(string: urlString) {
                URLImage(url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:50, height:50)
                }
            }
        } else {
            Image(systemName: AppStrings.Stuffed.defaultAuthorImgSysName) //set default person image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        List {
            Row(Repository: Repository.init(context: PersistenceManager.shared.container.viewContext))
        }
    }
}
struct Row_Dark_Previews: PreviewProvider {
    static var previews: some View {
        //It makes more sense to previews Row in a list.
        List {
            Row(Repository: Repository.init(context: PersistenceManager.shared.container.viewContext))
        }
        .preferredColorScheme(.dark)
    }
}
