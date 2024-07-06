//
//  SearchCharacterViewController.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit
import SnapKit
import Lottie

final class SearchCharacterViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: searchCollectionViewLayout())
        collectionView.register(
            CharacterCardCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterCardCollectionViewCell.identifier
        )
        
        collectionView.register(
            LoadingAnimationCollectionViewCell.self,
            forCellWithReuseIdentifier: LoadingAnimationCollectionViewCell.identifier
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
    
    private let loadingAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading_animation_lottie")
        view.loopMode = .loop
        view.backgroundColor = .clear
        view.isHidden = true
        
        return view
    }()
    
    
    
    // MARK: - Properties
    private var viewModel: SearchCharacterViewModelProtocol
    private var subscriptions = Set<SLAnyCancellable>()
    
    // MARK: - LifeCycle
    init(viewModel: SearchCharacterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            .sink { [weak self] section in
                if let section = section {
                    self?.searchCollectionView.reloadSections(IndexSet((section...section)))
                } else {
                    self?.searchCollectionView.reloadData()
                }
            }.store(in: &subscriptions)
        
        viewModel.isSavingFavoriteCharacterPublisher
            .sink { [weak self] isSaving in
                self?.loadingAnimationView.isHidden = !isSaving
                if isSaving {
                    self?.loadingAnimationView.play()
                } else {
                    self?.loadingAnimationView.stop()
                }
            }.store(in: &subscriptions)
        
        viewModel.errorPublisher
            .sink { error in
                AlertManager(title: "Error", message: error.localizedDescription)
                    .addAction(actionTitle: "확인", style: .default)
                    .present()
            }.store(in: &subscriptions)
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [searchCollectionView, loadingAnimationView, searchBar].forEach {
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
        
        loadingAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(80)
        }
    }
    
    // MARK: - ConnectTarget
    private func connectTarget() {
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc private func searchBarEditingChanged(_ sender: UITextField) {
        viewModel.searchCharacterNamePublisher.value = sender.text ?? ""
    }
    
    // MARK: - CompositionalLayout
    private func characterCellLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 3, bottom: 10, trailing: 3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return section
    }
    
    private func loadingAnimationCellLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(68))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func searchCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] section, _ -> NSCollectionLayoutSection? in
            guard let self = self else {
                return nil
            }
            switch section {
            case 0:
                return characterCellLayoutSection()
            case 1:
                return loadingAnimationCellLayoutSection()
            default:
                return nil
            }
        }
    }
}

// MARK: - SearchCharacterViewController
extension SearchCharacterViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.marvelCharacters.count
        case 1: return viewModel.isFetchingCharacters ? 1 : 0
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
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
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LoadingAnimationCollectionViewCell.identifier,
                for: indexPath
            ) as? LoadingAnimationCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            if viewModel.isFetchingCharacters {
                cell.startAnimation()
            } else {
                cell.stopAnimation()
            }
            
            return cell
        default: return UICollectionViewCell()
        }
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
