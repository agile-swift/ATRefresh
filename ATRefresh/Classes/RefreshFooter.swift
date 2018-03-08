//
//  RefreshFooter.swift
//  ATRefresh
//
//  Created by 凯文马 on 26/12/2017.
//

import UIKit

/// 底部加载等多控件，建议使用子类
open class RefreshFooter: RefreshComponent {

    /// 预加载偏移量，默认为0，该数值要求≥0
    public var preloadOffset : CGFloat = 0
    
    /// 显示状态的标签
    public fileprivate(set) lazy var textLabel : UILabel = {
        let l = UILabel()
        l.textColor = UIColor.gray
        l.font = UIFont.systemFont(ofSize: 12)
        l.textAlignment = .center
        self.addSubview(l)
        return l
    }()
    
    /// 显示加载动画的菊花
    public fileprivate(set) lazy var activityView : UIActivityIndicatorView = {
        let a = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.addSubview(a)
        a.hidesWhenStopped = true
        return a
    }()
    
    /// 使用闭包创建控件
    ///
    /// - Parameter refreshClosure: 刷新闭包，上拉到一定程度会触发闭包，在闭包中执行加载数据的方法
    required public init(refreshClosure : @escaping (RefreshFooter) -> Void ) {
        super.init(refreshTarget: self, action: #selector(changeRefreshActionTarget))
        self.refreshClosure = refreshClosure
        self.frame.size.height = 44
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 停止刷新，会修改状态，不会关闭触发刷新事件
    open override func endRefresh() {
        endRefresh(false)
    }
    
    /// 停止刷新，会修改状态
    ///
    /// - Parameter noMore: 是否关闭刷新事件
    open func endRefresh(_ noMore: Bool) {
        state = noMore ? .endWithoutData : .endRefresh
    }
    
    /// 重置状态为默认状态
    open func reset() { state = .idle }
    
    /// 状态更新的回调方法
    ///
    /// - Parameter state: 当前状态
    open func stateDidUpdate(_ state: RefreshState) {
        activityView.stopAnimating()
        switch state {
        case .isRefreshing:
            activityView.startAnimating()
            textLabel.isHidden = true
            break
        case .idle, .endRefresh:
            textLabel.text = "上拉加载数据"
            textLabel.isHidden = false
            break
        case .endWithoutData:
            textLabel.text = "没有更多数据"
            textLabel.isHidden = false
            break
        default:
            break
        }
    }

    // MARK: 重写
    
    public override var scrollView: UIScrollView? {
        set {
            if newValue == scrollView { return }
            newValue?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            scrollView?.removeObserver(self, forKeyPath: "contentSize")
            super.scrollView = newValue
        }
        get {
            return super.scrollView
        }
    }
    
    override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isIllegal { return }
        let scrollHeight = scrollView.contentOffset.y + scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        if scrollHeight - contentHeight > -preloadOffset {
            if self.state != .endWithoutData {
                self.state = .isRefreshing
            }
        }
    }
    
    open override var state: RefreshState {
        didSet {
            if oldValue == state { return }
            stateDidUpdate(state)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            let largeEnough = scrollView!.contentSize.height >= (scrollView!.frame.height - scrollView!.contentInset.top - scrollView!.contentInset.bottom)
            if largeEnough {
                self.frame.origin.y = scrollView!.contentSize.height + scrollView!.contentInset.top
                self.frame.size.width = scrollView!.frame.width
            }
            self.isIllegal = !largeEnough
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        activityView.center = CGPoint.init(x: frame.width * 0.5, y: frame.height * 0.5)
        textLabel.frame = self.bounds
    }
    // MARK: 私有
    private var refreshClosure : ((RefreshFooter) -> Void)?

    private var isIllegal : Bool = true
    
    @objc private func changeRefreshActionTarget() {
        refreshClosure?(self)
    }

    deinit {
        scrollView?.removeObserver(self, forKeyPath: "contentSize")
    }
}
