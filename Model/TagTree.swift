//
//  TagTree.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/05/25.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation

class Tree {
    var value: String
    var children = [Tree]()
    var parent: Tree?
    var densityOfSentence = 0
    var closingTag: Bool?
    var distance_from_Previous_TB: Int?
    var distance_from_Next_TB: Int?
    
    init(_ value: String) {
        self.value = value
        if value.count < 2 {
            self.closingTag = false
        } else {
            if value[value.startIndex...value.index(after: value.startIndex)] == "</" || value[value.index(value.endIndex, offsetBy: -2)...value.index(value.endIndex, offsetBy: -1)] == "/>" {
                self.closingTag = true
            } else if  value[value.startIndex...value.index(after: value.startIndex)] != "</" || value[value.index(value.endIndex, offsetBy: -2)...value.index(value.endIndex, offsetBy: -1)] != "/>" {
                self.closingTag = false
                if value[value.startIndex] != "<" {
                    self.densityOfSentence = densityOfTextBlock(tb: value)
                }
            }
        }
    }
    
    func addChild(node: Tree) {
        self.children.append(node)
        node.parent = self
    }
//    func BFS(currentNode: Tree) -> [Tree:Int] {
//        var dic = [Tree:Int]()
//        var queue = [Tree]()
//        currentNode.childrens.forEach {
//            queue.append($0)
//        }
//
//        while !queue.isEmpty {
//            let node = queue.removeFirst()
//            if node.value.contains("<script") {
//                node.value = ""
//                node.parent?.value = ""
//            }
//            if node.value.contains("align=") {
//                if dic[node.parent!] != nil {
//                    dic[node.parent!]!+=2
//                } else if dic[node.parent!] == nil {
//                    dic[node.parent ?? Tree("toptre")] = 2
//                } else if node.value.contains("img") {
//                    node.value += "width = "
//                }
//            }
//            else if node.value.contains("<p") || node.value.contains("</p>") || node.value.contains("<br") || node.value.contains("<P") || node.value.contains("<P") || node.value.contains("<Br") {
//                if dic[node.parent!] != nil {
//                    dic[node.parent!]!+=1
//                } else if dic[node.parent!] == nil {
//                    dic[node.parent ?? Tree("toptre")] = 1
//                } else if node.value.contains("<div style") {
//                    node.value = ""
//                } else if node.value.contains("style") {
//                    node.parent!.value = ""
//                    node.value = ""
//                }
//            }
//
//            node.childrens.forEach {
//                queue.append($0)
//            }
//        }
//        return dic
//    }
    
    func dfs(currentNode: Tree, _ newHTML: inout String) {
        if currentNode.densityOfSentence > 5 {
            newHTML += currentNode.value
        }
        for element in currentNode.children {
            dfs(currentNode: element, &newHTML)
        }
    }
    func initalizeDOM(rootNode: Tree, treeArr: [Tree]) {
        var currentNode = rootNode
        var textBlockArr = [Tree]()
        var count = 0
        for node in treeArr {
            currentNode.addChild(node: node)
            if let haveEndtag = node.closingTag {
                if !haveEndtag{ // 열린 태그 일 때
                    if node.value.first == "<" { // tag Block
                        currentNode = node // tag라면 parent node를 current node로 변경
                    } else { // textBlock
                        if textBlockArr.count == 0 {
                            textBlockArr.append(node)
                            node.distance_from_Previous_TB = 0
                            count = 0
                        } else {
                            node.distance_from_Next_TB = 0
                            node.distance_from_Previous_TB = count
                            textBlockArr.last!.distance_from_Next_TB = count
                            textBlockArr.append(node)
                            count = 0
                        }
                    }
                } else if haveEndtag { // 닫히는 태그 일 때
                    if let currentParent = node.parent {
                        currentNode = currentParent.parent ?? rootNode // 다음 node를 부모 node로 옮김
                    }
                }
            }
            count += 1
        }
    }
    func densityOfTextBlock(tb: String) -> Int {
        let refinedTextBlock = tb.trimmingCharacters(in: .whitespaces)
        guard refinedTextBlock.count > 0 else { return 0 }
        guard refinedTextBlock.contains(" ") else { return 1 }
        let sentences = refinedTextBlock.components(separatedBy: ".")
        var words = 0
        for sentence in sentences {
            let refinedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if refinedSentence == "" {
                continue
            }
            if refinedSentence.contains(" ") {
                words += sentence.components(separatedBy: " ").count
            } else {
                words += 1
            }
        }
        return words/sentences.count-1
    }
}

extension Tree: Hashable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(value)
    }
}
