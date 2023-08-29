//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/12/15.
//  ~/Library/Caches/org.swift.swiftpm/
//  file:///Users/william/Desktop/WWCropViewController

import UIKit
import WWPrint
import WWSignInWith3rd_Apple
import WWSignInWith3rd_GitHub

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    /// [GitHub 第三方登入](https://developer.github.com)
    @IBAction func signInWithGithub(_ sender: UIButton) {
        
        WWSignInWith3rd.GitHub.shared.loginWithWeb(presenting: self) { result in
            wwPrint(result)
        }
    }
}

// MARK: - 小工具
extension ViewController {
    
    func initSetting() {
        
        let clientId = "<clientId>"
        let secret = "<secret>"
        let callbackURL = "<callbackURL>"
        
        WWSignInWith3rd.GitHub.shared.configure(clientId: clientId, secret: secret, callbackURL: callbackURL)
    }
}

