//
//  RefreshGifHeader.swift
//  ATRefresh
//
//  Created by 凯文马 on 25/12/2017.
//

import UIKit

open class RefreshGifHeader: RefreshHeader {

    private var stateImages : [String : [UIImage]] = [:]
    
    private var lastState : RefreshState?
    
    open var animationDuration : TimeInterval = 0.3
    
    private lazy var imageView : UIImageView = {
        let iv = UIImageView.init(frame: self.bounds)
        iv.contentMode = .center
        self.addSubview(iv)
        return iv
    }()
    
    open func setAnimationImages(_ images: [UIImage], for state: RefreshState) {
        stateImages[state.rawValue] = images
    }
    
    override open func stateDidUpdate(state: RefreshState, percent: CGFloat) {
        let images = stateImages[state.rawValue]
        let count = images?.count ?? 0
        
        switch state {
        case .idle,.isPulling:
            imageView.stopAnimating()
            var index = -1
            if count > 1 {
                index = min(Int(CGFloat(count - 1) * pullingPercent), count - 1)
            } else if count == 1 {
                index = 0
            }
            if index >= 0 {
                imageView.image = images?[index]
            }
            break
        case .willRefresh,.isRefreshing:
            if lastState == state { return }
            imageView.animationImages = images
            imageView.animationDuration = animationDuration
            imageView.startAnimating()
            break
        default:
            imageView.stopAnimating()
            break
        }
        lastState = state
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
}
