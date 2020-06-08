//
//  TagTree.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/05/25.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation

class TreeNode {
    var value: String
    init(value: String) {
        self.value = value
    }
    var children = [TreeNode]()
    func addChild(child: TreeNode) {
        children.append(child)
    }
    func printNode() {
        print(children)
    }
}
var rootNode = TreeNode(value: "rootNode")

