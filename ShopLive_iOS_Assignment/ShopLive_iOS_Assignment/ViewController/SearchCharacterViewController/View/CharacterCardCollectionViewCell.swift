//
//  CharacterCardCollectionViewCell.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit
import SDWebImage

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
        [shadowView, thumbnailImageView, titleLabel, descriptionLabel].forEach {
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
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8).priority(750)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
    
    func configureView(model: MarvelCharacter) {
        // TODO: - 추후 비동기코드로 변경
        if let imageURL = URL(string: "\(model.thumbnail.path).\(model.thumbnail.extension)") {
            thumbnailImageView.sd_setImage(with: imageURL)
        }
        titleLabel.text = model.name
        descriptionLabel.text = model.description
    }
}
