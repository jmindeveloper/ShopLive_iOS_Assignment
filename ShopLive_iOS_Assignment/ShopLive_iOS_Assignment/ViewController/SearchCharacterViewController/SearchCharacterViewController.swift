//
//  SearchCharacterViewController.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit
import SnapKit
import Combine

final class SearchCharacterViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: searchCollectionViewLayout())
        collectionView.register(
            CharacterCardCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterCardCollectionViewCell.identifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색"
        searchBar.autocapitalizationType = .sentences
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.returnKeyType = .default
        searchBar.searchTextField.borderStyle = .none
        searchBar.searchTextField.textColor = .black
        searchBar.returnKeyType = .done
        searchBar.searchTextField.delegate = self
        
        return searchBar
    }()
    
    // MARK: - Properties
    private let viewModel = SearchCharacterViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Search"
        setSubViews()
        connectTarget()
        binding()
    }
    
    private func binding() {
        viewModel.collectionViewUpdatePublisher
            .sink { [weak self] in
                self?.searchCollectionView.reloadData()
            }.store(in: &subscriptions)
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [searchCollectionView, searchBar].forEach {
            view.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        
        searchCollectionView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.top.equalTo(searchBar.snp.bottom).offset(2)
        }
    }
    
    // MARK: - ConnectTarget
    private func connectTarget() {
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc private func searchBarEditingChanged(_ sender: UITextField) {
        viewModel.searchCharacterName = sender.text ?? ""
    }
    
    // MARK: - CompositionalLayout
    private func searchCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 3, bottom: 10, trailing: 3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - SearchCharacterViewController
extension SearchCharacterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.marvelCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCardCollectionViewCell.identifier,
            for: indexPath
        ) as? CharacterCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureView(
            model: viewModel.marvelCharacters[indexPath.row],
            isFavorite: viewModel.checkExistInFavoriteCharacter(
                index: indexPath.row
            )
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SearchCharacterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 1 == viewModel.marvelCharacters.count {
            viewModel.getMarvelCharacters()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.tapMarvelCharacterCardAction(index: indexPath.row)
    }
}

// MARK: - SearchCharacterViewController
extension SearchCharacterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
