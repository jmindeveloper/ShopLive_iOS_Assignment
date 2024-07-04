//
//  CharacterCardCollectionViewCell.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit
import SDWebImage
import Lottie

final class CharacterCardCollectionViewCell: UICollectionViewCell {
    static let identifier = "CharacterCardCollectionViewCell"
    
    // MARK: - ViewProperties
    private let shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let loadingAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading_animation_lottie")
        view.loopMode = .loop
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.shadow()
        setSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [shadowView, thumbnailImageView, loadingAnimationView,
         titleLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        shadowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(thumbnailImageView.snp.width).multipliedBy(0.6)
        }
        
        loadingAnimationView.snp.makeConstraints {
            $0.center.equalTo(thumbnailImageView)
            $0.size.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
    
    func configureView(model: MarvelCharacter, isFavorite: Bool) {
        loadingAnimationView.play()
        if let imageURL = URL(string: "\(model.thumbnail.path).\(model.thumbnail.extension)") {
            thumbnailImageView.sd_setImage(with: imageURL) { [weak self] _, _, _, _ in
                self?.loadingAnimationView.stop()
                self?.loadingAnimationView.isHidden = true
            }
        }
        
        contentView.backgroundColor = isFavorite ? .systemGray2 : .white
        titleLabel.text = model.name
        descriptionLabel.text = model.description
    }
    
    func configureView(coreDataModel: FavoriteMarvelCharacter) {
        if let imageData = coreDataModel.thumbnail {
            thumbnailImageView.image = UIImage(data: imageData)
        }
        titleLabel.text = coreDataModel.name
        descriptionLabel.text = coreDataModel.characterDescription
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingAnimationView.isHidden = false
    }
}
