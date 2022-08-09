//
//  コンテンツ見る.swift
//  学び
//
//  Created by Anton Heestand on 2022-08-09.
//

import SwiftUI

struct コンテンツ見る: View {
    
    @ObservedObject var 主要: 主要モデルを見る
    
    var body: some View {
    
        VStack(spacing: 50) {
            
            if let 語 = 主要.語 {
                
                Spacer()
                
                Button {
                    主要.話す日本語()
                } label: {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .buttonStyle(.plain)
                
                Group {
                    
                    Text(語.日本語)
                        .foregroundColor(語.言語 == .日本語 ? .purple : .primary)
                    
                    Text(語.英語)
                        .foregroundColor(語.言語 == .英語 ? .purple : .primary)
                }
                .font(.title)
                
                Button {
                    主要.話す英語()
                } label: {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .buttonStyle(.plain)
                
                Spacer()
                
            } else {
                Text("何も言わない")
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct コンテンツ見る_Previews: PreviewProvider {
    static var previews: some View {
        コンテンツ見る(主要: 主要モデルを見る())
    }
}
