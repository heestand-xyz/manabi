//
//  言語.swift
//  学び
//
//  Created by Anton Heestand on 2022-08-09.
//

import Foundation

enum 言語: String {
    
    case 英語 = "en"
    case 日本語 = "ja"
    
    var 反対: 言語 {
        switch self {
        case .英語:
            return .日本語
        case .日本語:
            return .英語
        }
    }
    
    init?(コード: String) {
        switch コード {
        case "en":
            self = .英語
        case "ja", "zh-Hant":
            self = .日本語
        default:
            return nil
        }
    }
}
