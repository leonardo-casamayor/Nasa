//
//  PopularViewController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 03/08/2024.
//

import UIKit

class PopularViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    var spinner = UIActivityIndicatorView()
    var loadingView: UIView = UIView()
    var loadingBackground: UIImageView = UIImageView()
    let dataLoader = SearchingController()
    private let collectionView = UICollectionView(frame: .zero,collectionViewLayout: CollectionViewHelper.generateLayout(size: CollectionViewConstants.LayoutSize(columns: 2, height: 1/3)))
    private let searchController = UISearchController(searchResultsController: nil)
    private var didSearch: Bool = false
    private var isSearchErrorShowing: Bool = false {
        didSet {
            showErrorView(image: CollectionViewConstants.glass!,
                          text: CollectionViewConstants.noResult,
                          isSearchErrorShowing)
        }
    }
    private var isConectionErrorShowing: Bool = false {
        didSet {
            showErrorView(image: CollectionViewConstants.wifi!,
                          text: CollectionViewConstants.conectionError,
                          isConectionErrorShowing)
        }
    }
    
    override func viewDidLoad() {
        setupCollectionViewController()
        collectionView.dataSource = self
        collectionView.delegate = self
        showActivityIndicator()
        searchController.searchBar.delegate = self
        populateMedia(queryDictionary: MediaApiConstants.defaultPopularSearch)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        let navigationBar = self.navigationController!.navigationBar
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }
    
    @IBAction func logOut(_ sender: UITapGestureRecognizer) {
        UserDefaults.standard.set(false, forKey: LoginConstants.userDefaultKey)
        let _ = LoginViewController()
        self.performSegue(withIdentifier: "unwindToLoginVC", sender: self)
    }
    
    private func setupCollectionViewController() {
        view.addSubview(collectionView)
        view.backgroundColor = GeneralConstants.nasaBlue
        setupSearchBar()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        CollectionViewHelper.setupCollectionView(self, collectionView: collectionView, traitCollection: traitCollection, identifier: CollectionCell.PopularIdentifier)
        collectionViewConstraints()
        collectionView.alpha = 0
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        )
        searchTextField?.leftView?.tintColor = .systemBlue
        searchTextField?.textColor = .systemBlue
    }
    
    private func collectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
    }
    
    private func sendToCellDetails() {
    }
    
    func populateMedia(queryDictionary: [String:String]) {
        dataLoader.retrieveMedia(queryDictionary: queryDictionary) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5){
                        strongSelf.collectionView.alpha = 1
                    }
                    if strongSelf.isSearchErrorShowing { strongSelf.isSearchErrorShowing.toggle() }
                    if strongSelf.isConectionErrorShowing { strongSelf.isConectionErrorShowing.toggle() }
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
                    strongSelf.hideActivityIndicator()
                    if strongSelf.dataLoader.media?.collection.items.count == 0 && strongSelf.didSearch {
                        if !strongSelf.isSearchErrorShowing {
                            strongSelf.isSearchErrorShowing.toggle()
                        }
                    }
                }
            case .failure(_):
                let error = strongSelf.dataLoader.error
                print("\(String(describing: error))")
                DispatchQueue.main.async {
                    strongSelf.hideActivityIndicator()
                    if !strongSelf.isConectionErrorShowing {
                        strongSelf.isConectionErrorShowing.toggle()
                    }
                }
            }
        }
    }
}

//MARK: CollectionViewDataSource
extension PopularViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataLoader.media?.collection.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCell.PopularIdentifier, for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
        
        let path = indexPath.row
        if let imageUrl = dataLoader.media?.collection.items[path].links[0].href {
            
            if let content = dataLoader.media?.collection.items[path].data {
                let title = content[0].title
            let date = DateFormat.formatDate(dateString: content[0].dateCreated)
                var mediaType: String = ""
                switch content[0].mediaType {
                case .video:
                    mediaType = "video"
                default:
                    mediaType = "image"
                }
                
                cell.configureCellWith(title: title, date: date, url: imageUrl, mediaType: mediaType)
            }
        }
        return cell
    }
    
}

//MARK: Compositional Layout
extension PopularViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        CollectionViewHelper.traitCollectionDidChange(collectionView: collectionView, traitCollection: traitCollection)
    }
}

extension PopularViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sendToCellDetails()
    }
}

extension PopularViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if searchText != "" {
            let query = ["q":"\(searchText)",
                         "media_type":"image,video"]
            populateMedia(queryDictionary: query)
            searchController.isActive = false
            didSearch = true
            showActivityIndicator()
        }
    }
}
// Error setup
extension PopularViewController {
    func showErrorView(image: UIImage, text: String, _ option: Bool) {
        self.errorImage.image = image
        self.errorImage.clipsToBounds = true
        self.errorImage.contentMode = .scaleAspectFit
        self.errorLabel.text = text
        self.errorLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        self.errorLabel.textColor = UIColor.white
        UIView.animate(withDuration: 0.5) {
            self.errorView.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
            self.errorView.alpha = option ? 1 : 0
            self.errorView.isHidden = false
        }
        self.labelContainer.alpha = 1
    }
}
// loading View

extension PopularViewController {
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.loadingView.backgroundColor = UIColor.black
            self.loadingView.alpha = 1
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            self.loadingBackground = UIImageView()
            self.loadingBackground.image = #imageLiteral(resourceName: "errorBackground")
            self.loadingBackground.alpha = 1
            self.loadingBackground.frame = self.loadingView.frame
            self.loadingBackground.clipsToBounds = true
            
            self.spinner = UIActivityIndicatorView()
            self.spinner.style = .large
            self.spinner.color = .white
            self.spinner.hidesWhenStopped = true
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            let nasaLogo = UIImageView()
            nasaLogo.image = #imageLiteral(resourceName: "NASA_logo.svg")
            self.loadingView.addSubview(self.loadingBackground)
            self.loadingView.addSubview(self.spinner)
            self.loadingView.addSubview(nasaLogo)
            self.view.addSubview(self.loadingView)
            
            nasaLogo.translatesAutoresizingMaskIntoConstraints = false
            nasaLogo.topAnchor.constraint(equalTo: self.loadingView.topAnchor, constant: 50.0).isActive = true
            nasaLogo.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor).isActive = true
            if self.traitCollection.verticalSizeClass == .regular {
                nasaLogo.widthAnchor.constraint(equalTo: self.loadingView.widthAnchor, multiplier: 0.3).isActive = true
            } else {
                nasaLogo.widthAnchor.constraint(equalTo: self.loadingView.widthAnchor, multiplier: 0.5).isActive = true
            }
            nasaLogo.heightAnchor.constraint(equalTo: nasaLogo.widthAnchor, multiplier: 0.85).isActive = true
            self.spinner.startAnimating()
        }
        
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
}

extension Array {
    public subscript (safe index: Int) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
