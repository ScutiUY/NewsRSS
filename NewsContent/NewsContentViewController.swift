//
//  NewsViewController.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/20.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import SnapKit

class NewsContentViewController: UIViewController {
    
    private let webView: UIWebView = {
        var webView = UIWebView()
        webView.backgroundColor = .white
        return webView
    }()
    
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setURL(url: url)
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
        let request = URLRequest(url: URL(string: url)! as URL)
        webView.loadRequest(request)
    }
    
    
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


