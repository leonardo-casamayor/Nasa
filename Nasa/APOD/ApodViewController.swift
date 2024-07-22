//
//  ApodViewController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 21/07/2024.
//

import UIKit
import SDWebImage

class ApodViewController: UIViewController {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var spinner = UIActivityIndicatorView()
    var loadingView: UIView = UIView()
    var loadingBackground: UIImageView = UIImageView()
    private var gradientLayer: CAGradientLayer?
    let nasaBlue = UIColor(red:0.02, green:0.24, blue:0.58, alpha:1)
    var networkManager = NetworkManager()
    var animate = true
    var apod: APODElement? {
        didSet {
            guard let apodData = apod else { return }
            loadData(data: apodData)
            prepareImage(data: apodData)
        }
    }
    var apodImageString: String? {
        didSet {
            DispatchQueue.main.async {
                guard let imageUrl = self.apodImageString else { return }
                self.image.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                self.image.sd_setImage(with: URL(string: imageUrl),
                                       placeholderImage: nil,
                                       options: .highPriority)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            self.networkManager.retrieveApodData { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let data):
                    strongSelf.apod = data
                    strongSelf.hideActivityIndicator()

                case .failure(_):
                    strongSelf.loadData(data: ApodConstants.apodMock, isMockData: true)
                    strongSelf.hideActivityIndicator()

                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if animate{
            animations()
            animate = false
        }
    }
    
    private func animations() {
        titleLabel.fadeIn(1, delay: 0)
        subtitleLabel.fadeIn(1, delay: 0.5)
        explanationLabel.fadeIn(1, delay: 1)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.gradientLayer?.frame = self.gradientView.bounds
        }
    }
    
    private func setupViewController() {
        view.backgroundColor = nasaBlue
        explanationLabel.backgroundColor = nasaBlue
        scrollView.contentInsetAdjustmentBehavior = .never
        makeGradient(gradientView)
    }
    
    private func makeGradient(_ view: UIView) {
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [UIColor.clear.cgColor, nasaBlue.cgColor]
        view.backgroundColor = UIColor.clear
        guard let layer = gradientLayer else { return }
        view.layer.addSublayer(layer)
    }
    
}

extension ApodViewController {
    private func loadData(data: APODElement, isMockData: Bool = false) {
        let copyright = data.copyright ?? ""
        let date = data.date.replacingOccurrences(of: "/", with: "-")
        let subtitle = copyright != "" ? "\(copyright.trunc(length: 25))  / \(date)" : date
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.titleLabel.text = data.title
            strongSelf.subtitleLabel.text = subtitle
            strongSelf.explanationLabel.text = data.explanation
            /// use a generic image if it's mockdata
            if isMockData {
                strongSelf.image.image = #imageLiteral(resourceName: "apod-example")
            }
        }
    }
    
    private func prepareImage(data: APODElement) {
        let url = data.mediaType == ApodMediaType.image ? data.url : data.thumbnailUrl
        guard let imageUrl = url else { return}
        self.apodImageString = imageUrl
    }
}
extension ApodViewController {
    func showActivityIndicator() {
        DispatchQueue.main.async { [self] in
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.loadingView.backgroundColor = UIColor.black
            self.loadingView.alpha = 1
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            self.loadingBackground = UIImageView()
            self.loadingBackground.image = #imageLiteral(resourceName: "apod-example")
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
            
            nasaLogo.translatesAutoresizingMaskIntoConstraints = false
            nasaLogo.topAnchor.constraint(equalTo: self.loadingView.topAnchor, constant: 50.0).isActive = true
            nasaLogo.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor).isActive = true
            if traitCollection.verticalSizeClass == .regular {
                nasaLogo.widthAnchor.constraint(equalTo: self.loadingView.widthAnchor, multiplier: 0.3).isActive = true
            } else {
                nasaLogo.widthAnchor.constraint(equalTo: self.loadingView.widthAnchor, multiplier: 0.5).isActive = true
            }
            nasaLogo.heightAnchor.constraint(equalTo: nasaLogo.widthAnchor, multiplier: 0.8).isActive = true
            self.view.addSubview(self.loadingView)
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
extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        })
    }
}
