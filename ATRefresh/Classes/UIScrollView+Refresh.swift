//
//  UIScrollView+Refresh.swift
//  ATRefresh
//
//  Created by 凯文马 on 25/12/2017.
//

import UIKit

private var RefreshHeaderKey : Void? = nil
private var RefreshFooterKey : Void? = nil

public extension UIScrollView {

    /// 注册下拉刷新组件，只能注册一次，多次注册不会报错，但不会有效
    ///
    /// - Parameters:
    ///   - headerType: 下拉组件的类
    ///   - config: 配置
    ///   - refreshClosure: 刷新操作
    public func registerRefreshHeader(_ headerType: RefreshHeader.Type, config : ((RefreshHeader) -> Void)? = nil, refreshClosure :@escaping (RefreshHeader) -> Void) {
        if refreshHeader != nil { return }
        let header = headerType.init(refreshClosure: refreshClosure)
        config?(header)
        self.refreshHeader = header
    }
    
    /// 注册上拉刷新组件，只能注册一次，多次注册不会报错，但不会有效
    ///
    /// - Parameters:
    ///   - footerType: 上拉组件的类
    ///   - config: 配置
    ///   - refreshClosure: 刷新操作
    public func registerRefreshFooter(_ footerType: RefreshFooter.Type, config : ((RefreshFooter) -> Void)? = nil, refreshClosure :@escaping (RefreshFooter) -> Void) {
        if refreshFooter != nil { return }
        let footer = footerType.init(refreshClosure: refreshClosure)
        config?(footer)
        self.refreshFooter = footer
    }
    
    /// 下拉组件，使用时可以获取，但不能设置
    public internal(set) var refreshHeader : RefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &RefreshHeaderKey) as? RefreshHeader
        }
        set {
            refreshHeader?.removeFromSuperview()
            objc_setAssociatedObject(self, &RefreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let newHeader = newValue else {
                return
            }
            newHeader.scrollView = self
            addSubview(newHeader)
            newHeader.frame = CGRect.init(x: 0, y: -newHeader.frame.height, width: self.frame.width, height: newHeader.frame.height)
        }
    }
    
    /// 上拉组件，使用时可以获取，但不能设置
    public internal(set) var refreshFooter : RefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &RefreshFooterKey) as? RefreshFooter
        }
        set {
            refreshFooter?.removeFromSuperview()
            objc_setAssociatedObject(self, &RefreshFooterKey,newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let newFooter = newValue else {
                return
            }
            newFooter.scrollView = self
            addSubview(newFooter)
            newFooter.frame = CGRect.init(x: 0, y: contentSize.height, width: frame.width, height: newFooter.frame.height)
        }
    }

}
