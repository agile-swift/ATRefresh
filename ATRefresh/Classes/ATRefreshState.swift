//
//  ATRefreshState.swift
//  ATRefresh
//
//  Created by 凯文马 on 25/12/2017.
//

import UIKit


/// 刷新状态
///
/// - idle: 闲置状态
/// - isPulling: 正在下拉
/// - isRefreshing: 正在刷新
/// - willRefresh: 将要刷新
/// - endWithoutData: 结束刷新（没有数据）
public enum RefreshState
: String
, CustomStringConvertible
, CustomDebugStringConvertible
{
    case idle = "闲置状态"
    case isPulling = "下拉状态"
    case isRefreshing = "正在加载"
    case willRefresh = "将要加载"
    case endRefresh = "结束刷新"
    case endWithoutData = "没有数据"
    
    public var description: String {
        return self.rawValue
    }
    
    public var debugDescription: String {
        return description
    }
}
