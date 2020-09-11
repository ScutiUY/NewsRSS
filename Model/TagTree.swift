//
//  TagTree.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/05/25.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation

class Tree {
    var value = ""
    var childrens = [Tree]()
    var parent: Tree?
    var closingTag: Bool?
    
    init(_ value: String) {
        if value.contains("</div>") {
            self.closingTag = true
        } else if value.contains("<div ") {
            self.closingTag = false
        }
        self.value = value
    }
    
    func addChild(child: Tree) {
        childrens.append(child)
        child.parent = self
    }
    
    func BFS(currentNode: Tree) -> [Tree:Int] {
        var dic = [Tree:Int]()
        var queue = [Tree]()
        currentNode.childrens.forEach {
            queue.append($0)
        }
        
        while !queue.isEmpty {
            let node = queue.removeFirst()
            if node.value.contains("align=") {
                if dic[node.parent!] != nil {
                    dic[node.parent!]!+=2
                } else if dic[node.parent!] == nil {
                    dic[node.parent ?? Tree("toptre")] = 2
                } else if node.value.contains("img") {
                    node.value += "width = "
                }
            }

            else if node.value.contains("<p") || node.value.contains("</p>") || node.value.contains("<br") || node.value.contains("<P") || node.value.contains("<P") || node.value.contains("<Br") {
                if dic[node.parent!] != nil {
                    dic[node.parent!]!+=1
                } else if dic[node.parent!] == nil {
                    dic[node.parent ?? Tree("toptre")] = 1
                } else if node.value.contains("<div style") {
                    node.value = ""
                } else if node.value.contains("style") {
                    node.value = node.value.replacingOccurrences(of: "style", with: "")
                }
            }
            
            node.childrens.forEach {
                queue.append($0)
            }
        }
        return dic
    }
    
    func DFS(currentNode: Tree, _ newHTML: inout String) {
        newHTML += currentNode.value
        for element in currentNode.childrens {
            DFS(currentNode: element, &newHTML)
        }
    }
    func initalizeDOM(rootNode: Tree, treeArr: [Tree]) {
        var currentNode = rootNode
        
        for node in treeArr {
            currentNode.addChild(child: node)
            if let haveEndtag = node.closingTag {
                if !haveEndtag{
                    if node.value.first == "<" {
                        currentNode = node
                    }
                } else if haveEndtag {
                    if let currentParent = node.parent {
                        currentNode = currentParent.parent ?? Tree("TOPTag")
                    }
                }
            }
        }
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
