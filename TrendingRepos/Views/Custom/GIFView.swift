//
//  GIFView.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/12/23.
//

import SwiftUI
import FLAnimatedImage

struct GIFView: UIViewRepresentable {
    private var named: String
    
    private let imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    init(named: String) {
        self.named = named
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        guard let url = Bundle.main.url(forResource: named, withExtension: "gif") else { return }
        
        if let data = try? Data(contentsOf: url) {
            let image = FLAnimatedImage(animatedGIFData: data)
            
            DispatchQueue.main.async {
                imageView.animatedImage = image
            }
        }
    }
}
