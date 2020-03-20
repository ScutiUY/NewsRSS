//
//  MainViewController.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/18.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    
    private let newsTableView: UITableView = {
       var tableView = UITableView()
        return tableView
    }()
    private let redView : UIView = {
        var view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTableView.delegate = self
        newsTableView.dataSource = self
        setLayout()
        newsTableView.register(NewsListTableViewCell.self, forCellReuseIdentifier: "NewsListTableViewCell")
        // Do any additional setup after loading the view.
    }
    private func setLayout() {
        
        view.addSubview(newsTableView)
        
        newsTableView.snp.makeConstraints { (m) in
            m.height.equalTo(view.safeAreaLayoutGuide.snp.height)
            m.width.equalTo(view.snp.width)
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

}
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Model.arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = Model.arr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListTableViewCell", for: indexPath) as? NewsListTableViewCell
        cell?.configureCell(model: model)
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
