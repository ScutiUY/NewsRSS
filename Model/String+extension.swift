//
//  extension.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/04/01.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation

extension String {
    func getArrayAfterRegex(text: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: text, options: .caseInsensitive)
        let text2NS = self as NSString
        let result = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: text2NS.length)).map({ text2NS.substring(with: $0.range)
        })
        if let result = result {
            return result
        } else {
            return [""]
        }
    }
}
