//
//  RefreshComponent.swift
//  ATRefresh
//
//  Created by 凯文马 on 22/12/2017.
//

import UIKit

/// 基类刷新组件
open class RefreshComponent: UIView {
    
    var refreshTarget : AnyObject!
    
    var refreshAction : Selector
    
    public init(refreshTarget target: AnyObject, action: Selector) {
        refreshAction = action
        refreshTarget = target
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 44))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 是否失效，默认有效，请在不需要该控件的时候设置为true
    /// 会修改控件本身isHidden属性，不会改变控件状态
    open var isInvalid : Bool = false {
        didSet {
            self.isHidden = isInvalid
        }
    }
    
    /// 状态
    open internal(set) var state : RefreshState = .idle {
        didSet {
            if oldValue == state { return }
            if state == .isRefreshing {
                _ = self.refreshTarget.perform(refreshAction)
            }
        }
    }
    
    /// 是否正在刷新中
    open var isRefreshing : Bool {
        return self.state == .isRefreshing
    }
    
    public internal(set) weak var scrollView : UIScrollView? {
        didSet {
            if scrollView == oldValue { return }
            scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            oldValue?.removeObserver(self, forKeyPath: "contentOffset")
            scrollViewOriginalInset = scrollView?.contentInset ?? .zero
        }
    }
    
    var scrollViewOriginalInset : UIEdgeInsets = .zero
    
    /// 开始刷新
    open func beginRefresh() {
        if self.superview != nil {
            self.state = .isRefreshing
        }
    }
    
    /// 结束刷新
    open func endRefresh() {
        self.state = .endRefresh
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if isInvalid { return }
            scrollViewDidScroll(scrollView!)
        }
    }
    
    open func scrollViewDidScroll(_ scrollView : UIScrollView) { }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }
}


