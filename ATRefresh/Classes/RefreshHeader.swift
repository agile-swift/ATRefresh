//
//  RefreshHeader.swift
//  ATRefresh
//
//  Created by 凯文马 on 25/12/2017.
//

import UIKit

/// 下拉刷新组件
open class RefreshHeader: RefreshComponent {
    
    /// 使用闭包创建控件
    ///
    /// - Parameter refreshClosure: 刷新闭包，下拉到一定程度会触发闭包，在闭包中执行加载数据的方法
    required public init(refreshClosure : @escaping (RefreshHeader) -> Void ) {
        super.init(refreshTarget: self, action: #selector(changeRefreshActionTarget))
        self.refreshClosure = refreshClosure
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 下拉百分比，可以超过100%
    var pullingPercent : CGFloat = 0 {
        didSet {
            stateDidUpdate(state: state, percent: self.pullingPercent)
        }
    }
    
    /// 开始刷新
    open override func beginRefresh() {
        super.beginRefresh()
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView?.contentOffset.y -= self.frame.height
        })
    }
    
    /// 结束刷新
    open override func endRefresh() {
        super.endRefresh()
    }
    
    
    /// 状态或下拉百分比改变
    ///
    /// - Parameters:
    ///   - state: 当前状态
    ///   - percent: 当前下拉百分比
    open func stateDidUpdate(state: RefreshState, percent: CGFloat) { }
    
    open override var state: RefreshState {
        set {
            if state == newValue { return }
            let oldState = state
            super.state = newValue
            switch newValue {
            case .endRefresh:
                if oldState == .isRefreshing {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.scrollView?.contentInset.top -= self.frame.height
                    }, completion: { _ in
                        self.state = .idle
                        self.pullingPercent = 0
                    })
                } else {
                    self.state = .idle
                    self.pullingPercent = 0
                }
                break
            default:
                break
            }
            stateDidUpdate(state: newValue, percent: self.pullingPercent)
        }
        get {
            return super.state
        }
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if state != .isRefreshing {
            scrollViewOriginalInset = scrollView.contentInset
        }
        
        if state == .isRefreshing {
            scrollView.contentInset.top = frame.height + scrollViewOriginalInset.top
            return
        }
        
        let offsetY = -scrollView.contentOffset.y
        let insetY = scrollViewOriginalInset.top
        if offsetY <= insetY { return }
        
        let refreshOffsetY = self.frame.height
        if scrollView.isDragging {
            pullingPercent = (offsetY - insetY) / refreshOffsetY

            if state == .idle && pullingPercent > 0 {
                state = .isPulling
            } else if state == .isPulling && pullingPercent >= 1 {
                state = .willRefresh
            } else if state == .willRefresh && pullingPercent < 1 {
                state = .isPulling
            }

        } else if state == .willRefresh && pullingPercent >= 1.0{
            state = .isRefreshing
            pullingPercent = 1.0
        } else {
            pullingPercent = (offsetY - insetY) / refreshOffsetY
            if pullingPercent < 0.01 {
                state = .idle
            }
        }
    }
    
    
    private var refreshClosure : ((RefreshHeader) -> Void)?
    
    @objc private func changeRefreshActionTarget() {
        refreshClosure?(self)
    }
}
