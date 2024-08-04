//
//  CellDetailViewController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import UIKit
import SwiftUI

class CellDetailViewController: UIViewController {
    var href: String?
    var thumbnailUrl: String?
    var nasaData: NasaData? {
        didSet {
            nasaDescription = nasaData?.description
            nasaTitle = nasaData?.title
            mediaType = nasaData?.mediaType
            nasaDate = convertDate(data: nasaData?.dateCreated)
        }
    }
    var favoriteData: FavoriteModel? {
        didSet {
            thumbnailUrl = favoriteData?.thumbnailLink
            assetUrl = favoriteData?.assetLink
            nasaDescription = favoriteData?.description
            nasaTitle = favoriteData?.title
            mediaType = favoriteData?.mediaType == FavoriteType.image ? MediaType.image : MediaType.video
            nasaDate = convertDate(data: favoriteData?.date)
        }
    }
    var assetUrl: String?
    var detailType: DetailType?
    let networkManager = NetworkManager()
    
    var nasaDescription: String?
    var nasaTitle: String?
    var mediaType: MediaType?
    var nasaDate : String?
    var isFavorite: Bool?
    
    private lazy var swiftView = makeSwiftUIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isFavorite = isFavoriteStatus()
        self.detailType == DetailType.popularDetail ? setUpPopular() : setUpFavorite()
    }
    
    private func setUpPopular() {
        guard let href = href else { return }
        networkManager.retrieveAssets(assetsUrl: href) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let urls):
                guard let data = strongSelf.nasaData else { return }
                guard let url = strongSelf.findUrl(array: urls, mediaType: data.mediaType) else {
                    return
                }
                strongSelf.assetUrl = NetworkManager.encodeURL(urlString: url)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.addSwiftUIView()
                    strongSelf.setupNavButtons()
                    strongSelf.hideBars(size: UIScreen.main.bounds.size)
                }
            case .failure(_):
                return
            }
        }
    }
    
    private func setUpFavorite() {
        isFavorite = true
        DispatchQueue.main.async {
            self.addSwiftUIView()
            self.setupNavButtons()
            self.hideBars(size: UIScreen.main.bounds.size)
        }
    }
    
    private func findUrl (array: [String], mediaType: MediaType) -> String? {
        let targetSubstring = mediaType == MediaType.image ? "small.jpg" : "mobile.mp4"
        guard let index = array.firstIndex(where: {$0.contains(targetSubstring)}) else { return thumbnailUrl }
        return array[index].replacingOccurrences(of: "http:", with: "https:")
    }
    
    private func addSwiftUIView() {
        addChild(swiftView)
        view.addSubview(swiftView.view)
        swiftView.didMove(toParent: self)
        let constraints = [
            swiftView.view.topAnchor.constraint(equalTo: view.topAnchor),
            swiftView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            swiftView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            swiftView.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func makeSwiftUIView() -> UIHostingController<CellDetailView> {
        guard let nasaDescription = self.nasaDescription,
              let nasaTitle = self.nasaTitle,
              let mediaType = self.mediaType,
              let nasaDate = self.nasaDate,
              let assetUrl = self.assetUrl
        else { return UIHostingController(rootView: CellDetailView(assetUrl: "", nasaDateString: "", nasaTitle: "", nasaDescription: "", mediaType: .image)) }
        
        let swiftDetailView = CellDetailView(assetUrl: assetUrl, nasaDateString: nasaDate, nasaTitle: nasaTitle, nasaDescription: nasaDescription, mediaType: mediaType)
        let headerVC = UIHostingController(rootView: swiftDetailView)
        headerVC.view.translatesAutoresizingMaskIntoConstraints = false
        return headerVC
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        hideBars(size: size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mediaType = self.mediaType else { return }
        mediaType == .video ? RotationHelper.lockOrientation(.allButUpsideDown) : RotationHelper.lockOrientation(.portrait)
    }
    
    func convertDate(data: String?) -> String {
        guard let data = data else { return "" }
        let dateString: String = DateFormat.formatDate(dateString: data)
        return dateString
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showBars()
        RotationHelper.lockOrientation(.portrait)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    private func setupNavButtons() {
        self.navigationItem.title = self.detailType == DetailType.popularDetail ? nasaData?.nasaID : favoriteData?.nasaId
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        toggleFavoriteButton()
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: AlertConstants.favoritesAlertTitle, message: AlertConstants.favoritesAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func hideBars(size: CGSize){
        let verticalIpod = self.traitCollection.verticalSizeClass == .regular
        let horizontalIpod = self.traitCollection.horizontalSizeClass == .regular
        if !((verticalIpod && horizontalIpod) && self.mediaType == MediaType.image ) {
            let isLandscape = size.width > size.height
            navigationController?.hidesBarsWhenVerticallyCompact = false
            tabBarController?.tabBar.isHidden = isLandscape ? true : false
            extendedLayoutIncludesOpaqueBars = isLandscape ? true : false
            navigationController?.setNavigationBarHidden(isLandscape ? true : false, animated: true)
        }
    }
    
    private func showBars() {
        navigationController?.hidesBarsWhenVerticallyCompact = true
        tabBarController?.tabBar.isHidden = false
        extendedLayoutIncludesOpaqueBars = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func isFavoriteStatus() -> Bool {
        guard let data = nasaData else { return false }
        let user = UsersLoader().load()
        guard let favorites = getFavorites(forUser: user.username) else { return false }
        let valueExists = favorites.contains { $0.nasaId == data.nasaID }
        return valueExists ? true : false
    }

    private func toggleFavoriteButton() {
        guard let isFavorite = self.isFavorite else { return }
        let addFavButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: isFavorite ? CellDetailConstants.favHeartFill : CellDetailConstants.favHeartOutline), style: .done, target: self, action: #selector(self.favoriteToggle))
        self.navigationItem.rightBarButtonItem = addFavButton
        self.isFavorite = !isFavorite
    }
  
    @objc func favoriteToggle() {
        toggleFavoriteButton()
        let user = UsersLoader().load()
        switch self.detailType {
        case .popularDetail:
            guard let data = nasaData else { return }
            if let favorites = getFavorites(forUser: user.username) {
                let valueExists = favorites.contains { $0.nasaId == data.nasaID }
                if valueExists {
                    removeFavorite(favorites, forUser: user.username)
                }
                else {
                    addFavorite(forUser: user.username, withFavorites: favorites)
                }
            } else {
                guard let favorite = createFavoriteItem() else { return }
                addFavorite(forUser: user.username, withFavorites: [favorite])
            }

        case .favoriteDetail:
            guard let data = favoriteData else { return }
            guard let favorites = getFavorites(forUser: user.username) else { return }
            let valueExists = favorites.contains { $0.nasaId == data.nasaId }
            if valueExists {
                removeFavorite(favorites, forUser: user.username)
            }
            else {
                addFavorite(forUser: user.username, withFavorites: favorites)
            }
        case .none:
            return

        }
    }
    
    private func getFavorites(forUser user: String) -> [FavoriteModel]? {
        guard let data = UserDefaults.standard.data(forKey: "Favorites/\(user)") else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([FavoriteModel].self, from: data)
        }
        catch {
            return nil
        }
    }
    
    private func removeFavorite(_ favorites: [FavoriteModel], forUser user: String){
        switch self.detailType {
        case .popularDetail:
            guard let data = nasaData else { return }
            let filteredFavorites = favorites.filter { !($0.nasaId == data.nasaID) }
            rewriteFavorites(filteredFavorites, forUser: user)
        case .favoriteDetail:
            guard let data = favoriteData else { return }
            let filteredFavorites = favorites.filter { !($0.nasaId == data.nasaId) }
            rewriteFavorites(filteredFavorites, forUser: user)
        case .none:
            return
        }
    }

    private func addFavorite(forUser user: String, withFavorites favorites: [FavoriteModel]){
        switch self.detailType {
        case .popularDetail:
            guard let favorite = createFavoriteItem() else { return }
            var newFavorites = favorites
            newFavorites.insert(favorite, at: 0)
            rewriteFavorites(newFavorites, forUser: user)
        case .favoriteDetail:
            guard let favorite = self.favoriteData else { return }
            var newFavorites = favorites
            newFavorites.insert(favorite, at: 0)
            rewriteFavorites(newFavorites, forUser: user)
        case .none:
            return
        }
    }

    private func createFavoriteItem() -> FavoriteModel? {
        guard let data = nasaData,
              let url = assetUrl,
              let thumbUrl = thumbnailUrl else { return nil }
        let type = data.mediaType == MediaType.video ? FavoriteType.video : FavoriteType.image
        return FavoriteModel(nasaId: data.nasaID, assetLink: url, thumbnailLink: thumbUrl, mediaType: type, title: data.title, date: data.dateCreated, description: data.description)
    }

    private func rewriteFavorites( _ favorites: [FavoriteModel], forUser user: String){
        do {
            let encoder = JSONEncoder()
            let ecodedFavorite = try encoder.encode(favorites)
            UserDefaults.standard.set(ecodedFavorite, forKey: "Favorites/\(user)")
        }
        catch {
            showAlert()
        }
    }
}

extension UIViewController {
    func addSubSwiftUIView<Content>(_ swiftUIView: Content, to view: UIView) where Content : View {
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as a child of the current view controller.
        addChild(hostingController)
        
        // Add the SwiftUI view to the view controller view hierarchy.
        view.addSubview(hostingController.view)
        
        // Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        // Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)
    }
}
