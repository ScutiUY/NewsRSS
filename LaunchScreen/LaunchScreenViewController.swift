//
//  ViewController.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/18.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
class LaunchScreenViewController: UIViewController {
    
    var timer = Timer()
    
    private let mainLogoImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "MainLogo")
        return imageView
    }()
    
    private let leftImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "RSS")
        return imageView
    }()
    
    private let rightLogoImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "earth")
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        var label = UILabel()
        label.text = "최신 뉴스를 제공합니다. \n뉴스의 키워드를 알아보세요"
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 3
        label.sizeToFit()
        return label
    }()
    
    private let versionLabel : UILabel = {
        var label = UILabel()
        label.textColor = .lightGray
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "v \(version)"
        }
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        startTimer()
        // Do any additional setup after loading the view.
    }

    private func setLayout() {
        view.backgroundColor = .white
        view.addSubview(mainLogoImageView)
        view.addSubview(leftImageView)
        view.addSubview(rightLogoImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(versionLabel)
        
        mainLogoImageView.snp.makeConstraints { (m) in
            m.center.equalTo(view.snp.center)
            m.width.equalTo(view.snp.width).multipliedBy(0.5)
            m.height.equalTo(mainLogoImageView.snp.width)
        }
        
        leftImageView.snp.makeConstraints { (m) in
            m.bottom.equalTo(mainLogoImageView.snp.bottom)
            m.width.equalTo(mainLogoImageView.snp.width).multipliedBy(0.3)
            m.height.equalTo(mainLogoImageView.snp.height).multipliedBy(0.3)
            m.leading.equalTo(5)
        }
        
        rightLogoImageView.snp.makeConstraints { (m) in
            m.bottom.equalTo(mainLogoImageView.snp.bottom)
            m.width.equalTo(mainLogoImageView.snp.width).multipliedBy(0.3)
            m.height.equalTo(mainLogoImageView.snp.height).multipliedBy(0.3)
            m.trailing.equalTo(-5)
        }
        
        descriptionLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(view.snp.centerX)
            m.top.equalTo(mainLogoImageView.snp.bottom).offset(20)
        }
        
        versionLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(view.snp.centerX)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(exitLaunchScreen), userInfo: nil, repeats: false)
        
    }
    @objc func exitLaunchScreen() {
        let MainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main")
        let newNavCon = UINavigationController(rootViewController: MainVC)
        newNavCon.modalPresentationStyle = .overFullScreen
        self.present(newNavCon, animated: false, completion: nil)
    }
}

