//
//  FavoritesViewController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import UIKit

class FavoriteViewController: UIViewController {
    let favoritesLoader = FavoriteController()
    var loadingView: UIView = UIView()
    var loadingBackground: UIImageView = UIImageView()
    var addFavoritesTitles: UILabel = UILabel()
    var addFavoritesLabel: UILabel = UILabel()
    var transparentView = UIImageView()
    var nasaLogo = UIImageView()
    var firstLoad = true
    
    
    private let collectionView = UICollectionView(frame: .zero,collectionViewLayout: CollectionViewHelper.generateLayout(size: CollectionViewConstants.LayoutSize(columns: 2, height: 1/3)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewController()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        configureNavigationBar(largeTitleColor: .systemBlue, backgoundColor: .black, tintColor: .black, title: "Favorites", preferredLargeTitle: true)
        populateMedia()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        populateMedia()
        if size.width > size.height {
            self.nasaLogo.isHidden = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupCollectionViewController() {
        view.addSubview(collectionView)
        view.backgroundColor = GeneralConstants.nasaBlue
        configureNavigationBar(largeTitleColor: .black, backgoundColor: .white, tintColor: .white, title: "Favorites", preferredLargeTitle: true)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        CollectionViewHelper.setupCollectionView(self, collectionView: collectionView, traitCollection: traitCollection, identifier: CollectionCell.Favoriteidentifier)
        collectionViewConstraints()
    }
    
    private func collectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
    }
    private func sendToCellDetails() {
        // setup here any data we will pass to the next viewcontroller
        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "CellDetailViewController") as? CellDetailViewController else { return }
        self.navigationController?.pushViewController(destinationVC, animated: true)
        guard let indexPath = collectionView.indexPathsForSelectedItems, let index = indexPath.last?.last else { return }
        destinationVC.thumbnailUrl = favoritesLoader.favorites?[index].thumbnailLink
        destinationVC.favoriteData = favoritesLoader.favorites?[index]
        destinationVC.detailType = DetailType.favoriteDetail
    }
    private func repopulateMedia() {
        if !firstLoad {
            populateMedia()
        }
    }
    private func populateMedia() {
        self.favoritesLoader.retrieveFavorites { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    strongSelf.hideAddFavorites()
                    strongSelf.collectionView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    strongSelf.showAddFavorites()
                    
                }
            }
        }
    }
}

//MARK: CollectionViewDataSource
extension FavoriteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritesLoader.favorites?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCell.Favoriteidentifier, for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
        let index = indexPath.row
        if let favoriteAtRow = favoritesLoader.favorites?[index] {
            if let thumbnailUrl = favoriteAtRow.thumbnailLink{
                cell.configureCellWith(title: favoriteAtRow.title,
                                       date: DateFormat.formatDate(dateString: favoriteAtRow.date),
                                       url: thumbnailUrl,
                                       mediaType: favoriteAtRow.mediaType.rawValue)
            }
        }
        return cell
    }
    
}

//MARK: Compositional Layout
extension FavoriteViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        CollectionViewHelper.traitCollectionDidChange(collectionView: collectionView, traitCollection: traitCollection)
    }
}

// MARK: Navigation Controller Configuration
extension FavoriteViewController {
    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.backgroundColor = backgoundColor
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = title
    }
}

extension FavoriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sendToCellDetails()
    }
}
// MARK: - EmptyFavorite State
extension FavoriteViewController {
    ///hide the view if there is content to display
    func hideAddFavorites() {
        self.loadingView.isHidden = true
        self.loadingView.alpha = 0
    }
    
    ///show the view if the CV is empty
    func showAddFavorites() {
        setupEmptyStateView()
        UIView.animate(withDuration: 0.5) {
            self.loadingView.isHidden = false
            self.loadingView.alpha = 1
        }
        
    }
    
    ///initial setup for the state view
    func setupEmptyStateView() {
        DispatchQueue.main.async {
            //loadingView setup
            self.loadingView.isHidden = false
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.loadingView.backgroundColor = UIColor.black
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            //loadingBackground setup
            self.loadingBackground.image = #imageLiteral(resourceName: "noFavorites")
            self.loadingBackground.alpha = 1
            self.loadingBackground.frame = self.loadingView.frame
            self.loadingBackground.clipsToBounds = true
            self.addFavoritesTitles.text = FavoritesTabConstants.addFavTitle
            self.addFavoritesLabel.text = FavoritesTabConstants.addFavDescription
            
            // transparentView setup works as container
            self.transparentView.backgroundColor = .black
            self.transparentView.alpha = 0.5
            self.transparentView.layer.cornerRadius = 20
            
            // nasaLogo setup
            let size = self.view.frame.size
            self.nasaLogo.image = #imageLiteral(resourceName: "NASA_logo.svg")
            self.nasaLogo.isHidden = size.width > size.height ? true : false
 
            // favoritesLabel setup
            self.addFavoritesLabel.textColor = UIColor.white
            self.addFavoritesLabel.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
            self.addFavoritesLabel.numberOfLines = 4
            self.addFavoritesLabel.adjustsFontSizeToFitWidth = true
            self.addFavoritesLabel.minimumScaleFactor = 0.2
            self.addFavoritesLabel.textAlignment = .center
            
            // favoritesTitles setup
            self.addFavoritesTitles.textColor = UIColor.white
            self.addFavoritesTitles.font = UIFont.systemFont(ofSize: 46, weight: .bold)
            self.addFavoritesTitles.numberOfLines = 1
            self.addFavoritesTitles.adjustsFontSizeToFitWidth = true
            self.addFavoritesTitles.minimumScaleFactor = 0.2
            self.addFavoritesTitles.textAlignment = .center
            
            self.addBackgroundViews()
            self.setupBackgroundConstraints()
            
        }
        
    }
    func addBackgroundViews() {
        loadingView.addSubview(loadingBackground)
        loadingView.addSubview(transparentView)
        loadingView.addSubview(nasaLogo)
        loadingView.addSubview(addFavoritesLabel)
        loadingView.addSubview(addFavoritesTitles)
        view.addSubview(loadingView)
    }
    
    func setupBackgroundConstraints() {
        nasaLogo.translatesAutoresizingMaskIntoConstraints = false
        transparentView.translatesAutoresizingMaskIntoConstraints = false
        addFavoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        addFavoritesTitles.translatesAutoresizingMaskIntoConstraints = false
        
        nasaLogo.bottomAnchor.constraint(equalTo: transparentView.topAnchor, constant: -20.0).isActive = true
        nasaLogo.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        if self.traitCollection.verticalSizeClass == .regular {
            nasaLogo.widthAnchor.constraint(equalTo: loadingView.widthAnchor, multiplier: 0.3).isActive = true
        } else {
            nasaLogo.widthAnchor.constraint(equalTo: loadingView.widthAnchor, multiplier: 0.5).isActive = true
        }
        nasaLogo.heightAnchor.constraint(equalTo: nasaLogo.widthAnchor, multiplier: 0.85).isActive = true
        
        
        transparentView.heightAnchor.constraint(equalTo: loadingView.heightAnchor, multiplier: 0.3).isActive = true
        transparentView.widthAnchor.constraint(equalTo: loadingView.widthAnchor, multiplier: 0.8).isActive = true
        transparentView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        transparentView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        addFavoritesLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        addFavoritesLabel.topAnchor.constraint(equalTo: addFavoritesTitles.bottomAnchor, constant: 20).isActive = true
        addFavoritesLabel.widthAnchor.constraint(equalTo: transparentView.widthAnchor, multiplier: 0.8).isActive = true
        addFavoritesLabel.bottomAnchor.constraint(equalTo: transparentView.bottomAnchor, constant: -10).isActive = true
        
        addFavoritesTitles.centerXAnchor.constraint(equalTo: transparentView.centerXAnchor).isActive = true
        addFavoritesTitles.topAnchor.constraint(equalTo: transparentView.topAnchor, constant: 20.0).isActive = true
        addFavoritesTitles.leadingAnchor.constraint(equalTo: transparentView.leadingAnchor, constant: 10.0).isActive = true
        addFavoritesTitles.trailingAnchor.constraint(equalTo: transparentView.trailingAnchor, constant: -10.0).isActive = true
        addFavoritesTitles.bottomAnchor.constraint(equalTo: transparentView.centerYAnchor, constant: -20).isActive = true
    }
}
