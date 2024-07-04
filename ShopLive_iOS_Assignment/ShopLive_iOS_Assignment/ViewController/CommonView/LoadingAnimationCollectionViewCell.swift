//
//  LoadingAnimationCollectionViewCell.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import UIKit
import Lottie

final class LoadingAnimationCollectionViewCell: UICollectionViewCell {
    static let identifier = "LoadingAnimationCollectionViewCell"
    
    // MARK: - ViewProperties
    private let loadingAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading_animation_lottie")
        view.loopMode = .loop
        view.backgroundColor = .clear
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        contentView.addSubview(loadingAnimationView)
        
        setConstraints()
    }
    
    private func setConstraints() {
        loadingAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(4)
        }
    }
    
    deinit {
        loadingAnimationView.stop()
    }
    
    func start() {
        loadingAnimationView.play()
    }
}

