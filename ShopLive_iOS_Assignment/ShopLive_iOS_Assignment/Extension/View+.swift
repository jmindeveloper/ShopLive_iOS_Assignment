//
//  View+.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit

extension UIView {
    func shadow(
        opacity: Float = 0.1,
        shadowOffset: CGSize = CGSize(width: 0, height: 3),
        shadowRadius: CGFloat = 3
    ) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}
