//
//  Parser.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/23.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation
import UIKit
class Parser: NSObject {
    static var shared = Parser()
    static var count = 0 {
        didSet {
            //print(Model.newsData.count, Parser.count)
            if count == Model.newsData.count {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
                }
            }
        }
    }
    
    static let parsingNoti = Notification.Name("finished parsing")
    private var currentElement: String = ""
    private var datalist: [[String:String]] = []
    private var detaildata: [String: String] = [:]
    static var blank: Bool = false
    
    
    func parseFeed (url: URL) {
        
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            guard var data2String = String(data: data, encoding: .utf8) else { return }
            data2String = data2String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "&lt;", with: "").replacingOccurrences(of: "&gt;", with: "")
            
            let parser = XMLParser(data: data2String.data(using: .utf8)!)
            parser.delegate = self
            parser.parse()
            
        }
        task.resume()
    }
    
    func linkParse (model: Model) {
        var contentStr = ""
        let url = URL(string: model.link)
        var treeArr = [Tree]()
        let rootNode = Tree("root")
        guard let reURL = url else {
            print("link 오류")
            return }
        let request = URLRequest(url: reURL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let html = self.incodingHTML(data)
            guard let html2String = html else {
                fatalError("html 오류")
            }
            
            let newStr = html2String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: ">", with: ">\n").trimmingCharacters(in: .whitespacesAndNewlines)
            let arr = newStr.components(separatedBy: "\n")
            arr.forEach{treeArr.append(Tree($0))}
             
            rootNode.initalizeDOM(rootNode: rootNode, treeArr: treeArr)
            
            let dic: [Tree:Int] = rootNode.BFS(currentNode: rootNode)
            
            
            if dic.max(by: {$0.value < $1.value}) != nil {
                let newContent = dic.max{$0.value < $1.value}!.key
                rootNode.DFS(currentNode: newContent, &contentStr)
                model.content = contentStr
                Parser.self.count+=1
            } else if dic.max(by: {$0.value < $1.value}) == nil {
                let newContent = rootNode
                rootNode.DFS(currentNode: newContent, &contentStr)
                model.content = contentStr
                Parser.self.count+=1
            }
            self.imageValidation(newStr: newStr, model: model)
            
        }
        task.resume()
    }
    func imageValidation(newStr: String, model: Model) {
        if newStr.getArrayAfterRegex(text: "og:image.+").isEmpty {
            DispatchQueue.main.async {
                model.thumbNail = UIImage(named: "No_Image")
            }
            NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
        } else if !newStr.getArrayAfterRegex(text: "og:image.+").isEmpty {
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async {
                    model.thumbNail = self.getImage(newStr.getArrayAfterRegex(text: "og:image.+")[0])
                }
                NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
            }
            
        }
    }
    func incodingHTML(_ data: Data) -> String? {
        var html = String(data: data, encoding: .utf8)
        guard html == nil else { return html }
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
        html = String(data: data, encoding: encoding)
        guard html == nil else { return html }
        html = String(decoding: data, as: UTF8.self)
        return html
    }
    func getImage(_ arr: String) -> UIImage {
        guard arr.contains("http") else { return UIImage(named: "No_Image")!
        }
        var imageURL = arr.getArrayAfterRegex(text: "http.+\"")
        if imageURL == [] {
            imageURL = arr.getArrayAfterRegex(text: "http.+\'")
        }
        if imageURL == [] {
            return UIImage(named: "No_Image")!
        }
        imageURL[0].removeLast()
        guard let urq = URL(string: imageURL[0]) else {
            return UIImage(named: "No_Image")!
        }
        guard let imageData = try? Data(contentsOf: urq) else {
            return UIImage(named: "No_Image")!
        }
        return UIImage(data: imageData)!
    }
        
}

extension Parser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        Parser.blank = true
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if Parser.blank == true && currentElement == "title" || currentElement == "link"{
            detaildata[currentElement] = string
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "link"{
            datalist += [detaildata]
            if detaildata["title"] != "주요 뉴스 - Google 뉴스"{
                let newModel = Model(title: detaildata["title"]!, link: detaildata["link"]!)
                Model.newsData.append(newModel)
                linkParse(model: newModel)
            }
        }
        Parser.blank = false
    }
}
