//
//  WebViewController.swift
//  WorldTrotter
//
//  Created by Vladislav Tarasevich on 09.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation
import WebKit

final class WebViewController: UIViewController {

    // MARK: - Private properties

    private let webView = WKWebView()

    // MARK: - Overrides

    override func loadView() {
        super.loadView()

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://www.bignerdranch.com/")
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
    }

}
