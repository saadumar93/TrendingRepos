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
    @State var isExpanded = false
    
    internal let inspection = Inspection<Self>()
    
    init(Repository:Repository, isLoadingView:Bool = false) {
        self.repo = Repository
        self.isLoadingView = isLoadingView
    }
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                authorImg
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                    .frame(width: 40, height: 40)
                    .modifier(ClipShapeSafe(shape: Circle())) //default clipShape crashes iOS 13, hence custom workaround with version check
                    .padding(.top, 22)
                    .padding([.leading,.trailing])
            }
            VStack(alignment:.leading) {
                Spacer()
                Text(repo.authorName ?? AppStrings.Stuffed.defaultRepositoryAuthor)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                Text(repo.repoName ?? AppStrings.Stuffed.defaultRepository)
                    .lineLimit(1)
                    .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
                if isExpanded {
                    expandedDetail
                }
                Spacer()
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isLoadingView {
                self.isExpanded.toggle()
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self,$0)}
        //.modifier(AnimatingCellHeight(height: isExpanded ? 120 : 75))
    }
    
    var randomColor: Color {
        Color(red:.random(in: 0...1),green: .random(in: 0...1), blue: .random(in: 0...1))
    }
    
    @ViewBuilder
    var authorImg: some View {
        if let urlString = repo.authorImageURL, !urlString.isEmpty {
            if let url = URL(string: urlString) {
                URLImage(url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:40, height:40)
                }
            }
        } else {
            Image(systemName: AppStrings.Stuffed.defaultAuthorImgSysName) //set default person image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            
        }
    }
    
    @ViewBuilder
    var expandedDetail: some View {
        Text(repo.repoDesc ?? AppStrings.Stuffed.defaultRepositoryDesc)
            .lineLimit(3)
            .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
        Spacer()
        HStack {
            Circle()
                .fill(randomColor)
                .frame(width: 12, height: 12)
            Text(repo.language ?? AppStrings.Stuffed.defaultRepositoryLanguage)
                .lineLimit(1)
                .padding(.leading,3)
                .padding(.trailing,12)
                .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
            Image("star_black_20pt")
                .foregroundColor(.yellow)
            Text("\(repo.stars)")
                .redacted(reason: isLoadingView ? .loading : nil, colorScheme)
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

struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}
