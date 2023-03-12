//
//  AppURLS.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/3/23.
//

import Foundation

///Helper functions
enum AppURLS {
    static func documentsDirectory() -> URL {
        guard let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            fatalError("Unable to get system docs directory - serious problem")
        }
        return URL(fileURLWithPath: docsPath)
    }
}
