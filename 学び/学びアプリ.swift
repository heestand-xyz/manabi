//
//  学びアプリ.swift
//  学び
//
//  Created by Anton Heestand on 2022-08-09.
//

import SwiftUI

@main
struct 学びアプリ: App {
    
    @StateObject var 主要 = 主要モデルを見る()
    
    var body: some Scene {
    
        WindowGroup {
          
            コンテンツ見る(主要: 主要)
        }
    }
}
