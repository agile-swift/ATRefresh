//
//  ViewController.swift
//  ATRefresh
//
//  Created by devkevinma@gmail.com on 12/22/2017.
//  Copyright (c) 2017 devkevinma@gmail.com. All rights reserved.
//

import UIKit
import ATRefresh

class UITableViewW : UITableView {
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class ViewController: UIViewController {
    
    var count = 20
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(UIView())
        
//        automaticallyAdjustsScrollViewInsets = false
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        tableView.frame = self.view.bounds
        tableView.contentOffset = .zero
        tableView.contentInset.top = 44
//        tableView.contentInset.bottom = 100
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.delegate = self
        print(tableView.contentInset)
        if #available(iOS 11.0, *) {
            print(tableView.safeAreaInsets)
        } else {
            // Fallback on earlier versions
        }
        print(tableView.contentSize)

//        tableView.registerRefreshHeader(GifRefreshHeader.self) { h in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//                h.endRefresh()
//            })
//        }
        tableView.registerRefreshHeader(GifRefreshHeader.self, config: { (header) in
            header.frame.size.height = 34
            header.isInvalid = true
        }) { (header) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.count = 20
                self.tableView.reloadData()
                header.endRefresh()
            })
        }
        tableView.refreshHeader?.beginRefresh()
        var i = 0
        tableView.registerRefreshFooter(RefreshFooter.self) { (footer) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.count += 20
                self.tableView.reloadData()
                if i == 2 {
                    footer.endRefresh(true)
                } else {
                    footer.endRefresh()
                }
                print(i)
                i += 1
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let a = UserDefaults.standard
        a.synchronize()
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = "\(indexPath)"
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y + scrollView.contentInset.top)
    }
}
