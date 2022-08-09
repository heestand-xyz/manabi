//
//  主要モデルを見る.swift
//  学び
//
//  Created by Anton Heestand on 2022-08-09.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import NaturalLanguage
import SwiftyTranslate
import AVFoundation

final class 主要モデルを見る: ObservableObject {
    
    @Published var 語: 語? {
        didSet {
            話す()
        }
    }
    
    private var 最後のクリップボード: String?
    
    init() {
        
        Task {
            guard let 語 = try? await 自動得る語() else {
                return
            }
            DispatchQueue.main.async {
                self.語 = 語
            }
        }
        
        聞く()
    }
    
    // MARK: - 聞く
    
    #if os(macOS)
    
    private func 聞く() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            
            guard let 文章 = self.クリップボード() else {
                return
            }
            
            if self.最後のクリップボード != 文章 {
    
                Task {
                    guard let 語 = try? await self.得る語(から: 文章) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.語 = 語
                    }
                }
                
                self.最後のクリップボード = 文章
            }
        }
    }
    
    #else
    
    private func 聞く() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(アプリケーションがアクティブになりました),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func アプリケーションがアクティブになりました() {
        
        Task {
            guard let 語 = try? await 自動得る語() else {
                return
            }
            DispatchQueue.main.async {
                self.語 = 語
            }
        }
    }
    
    #endif
    
    // MARK: - 話す
    
    func 話す() {
        
        guard let 語: 語 = 語 else {
            return
        }
        
        let 文章: String
        switch 語.言語 {
        case .英語:
            文章 = 語.日本語
        case .日本語:
            文章 = 語.英語
        }
        
        話す(文章: 文章, 言語: 語.言語.反対)
    }
    
    func 話す日本語() {
        
        guard let 語: 語 = 語 else {
            return
        }
        
        話す(文章: 語.日本語, 言語: .日本語)
    }
    
    func 話す英語() {
        
        guard let 語: 語 = 語 else {
            return
        }
        
        話す(文章: 語.英語, 言語: .英語)
    }
    
    func 話す(文章: String, 言語: 言語) {
        
        let 発話 = AVSpeechUtterance(string: 文章)
        発話.voice = AVSpeechSynthesisVoice(language: 言語.rawValue)
        
        let synth = AVSpeechSynthesizer()
        synth.speak(発話)
    }
    
    // MARK: - 得る語
    
    private func 自動得る語() async throws -> 語? {
        
        guard let 文章 = クリップボード() else {
            return nil
        }
        
        self.最後のクリップボード = 文章
        
        return try await 得る語(から: 文章)
    }
    
    private func 得る語(から 文章: String) async throws -> 語? {
        
        guard let 言語 = 検出(から: 文章) else {
            return nil
        }
        
        let 翻訳: String = try await 翻訳(文章, から: 言語, に: 言語.反対)
        
        let 英語: String = 言語 == .英語 ? 文章 : 翻訳
        let 日本語: String = 言語 == .日本語 ? 文章 : 翻訳
        
        return 学び.語(言語: 言語, 英語: 英語, 日本語: 日本語)
    }
    
    // MARK: - 翻訳
    
    private func 翻訳(
        _ 文章: String,
        から から言語: 言語,
        に に言語: 言語
    ) async throws -> String {
        
        return try await withCheckedThrowingContinuation { 継続 in
            
            SwiftyTranslate.translate(
                text: 文章,
                from: から言語.rawValue,
                to: に言語.rawValue
            ) { 結果 in
                
                switch 結果 {
                case .success(let 翻訳):
                    継続.resume(returning: 翻訳.translated)
                case .failure(let エラー):
                    継続.resume(throwing: エラー)
                }
            }
        }
    }
    
    // MARK: - 検出
    
    private func 検出(から 文章: String) -> 言語? {
        
        let 認識者 = NLLanguageRecognizer()
        
        認識者.processString(文章)
        
        guard let 言語コード = 認識者.dominantLanguage?.rawValue else {
            return nil
        }
        
        return 言語(コード: 言語コード)
    }
    
    // MARK: - クリップボード
    
    private func クリップボード() -> String? {
        #if os(macOS)
        return NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
        #else
        return UIPasteboard.general.string
        #endif
    }
}
