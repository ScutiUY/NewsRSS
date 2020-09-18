//
//  NewsViewController.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/20.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
class NewsContentViewController: UIViewController {
    
    private let webKitView: WKWebView = {
        var webKitView = WKWebView()
        webKitView.backgroundColor = .white
        webKitView.contentMode = .scaleToFill
        
        return webKitView
    }()
    
    private let webView: UIWebView = {
        var webView = UIWebView()
        webView.backgroundColor = .white
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = false
        webView.contentMode = .scaleToFill
        //webView.scalesPageToFit = true
        return webView
    }()
    
    private let spinner = UIActivityIndicatorView(style: .gray)
    var articleTitle = ""
    var url = ""
    var htmlStr = """
        
    """
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setURL(url: url)
        print(url)
        print(htmlStr)
    }
    
    private func setLayout() {
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.width.equalTo(view.snp.width)
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setURL(url: String) {
        webView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)
    }
    
}

