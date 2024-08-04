//
//  CollectionCell.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import UIKit
import SDWebImage

class CollectionCell: UICollectionViewCell {
    static let PopularIdentifier = "PopularCell"
    static let Favoriteidentifier = "FavoriteCell"
    private var views:[UIView] = []
    
    //MARK: Views
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let transparentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:0.5)
        return view
    }()
    
    var imageView: MyImageView = {
        let imageView = MyImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "popular-example")
        return imageView
    }()
    private var playView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "PlayButton")
        imageView.isHidden = true
        return imageView
    }()
    
    //MARK: Initialization and setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.dateLabel.text = ""
        self.imageView.image = nil
    }
    
    private func setupCell() {
        views = [imageView, transparentView, titleLabel, dateLabel, playView]
        views.forEach { contentView.addSubview($0) }
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 15
        setupConstraints()
    }
    private func setupSubviews() {
        views.forEach { setViewFrameToBounds(view: $0) }
    }
    
    private func setViewFrameToBounds(view: UIView) {
        view.frame = contentView.bounds
    }
    func configureCellWith(title: String, date: String, url: String, mediaType: String) {
        guard let encodedUrl = NetworkManager.encodeURL(urlString: url) else { return }
        if mediaType == "video" {
            self.playView.isHidden = false
        } else if mediaType == "image" {
            self.playView.isHidden = true
        }
        self.dateLabel.text = date
        self.titleLabel.text = title.lowercased().trunc(length: 100).capitalized
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
        
        self.imageView.sd_setImage(with: URL(string: encodedUrl),
                                   placeholderImage: nil,
                                   options: .highPriority)
    }
}

//MARK: Constraints
extension CollectionCell {
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        transparentViewConstraints()
        titleLabelConstraints()
        dateLabelConstraints()
        playViewConstraints()
    }
    
    private func titleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: transparentView.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: transparentView.rightAnchor,constant: -10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: transparentView.topAnchor,constant: 8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -2).isActive = true
    }
    
    private func dateLabelConstraints() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.leftAnchor.constraint(equalTo: transparentView.leftAnchor, constant: 10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: transparentView.centerYAnchor, constant: 10).isActive = true
    }
    private func playViewConstraints() {
        playView.translatesAutoresizingMaskIntoConstraints = false
        playView.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.3).isActive = true
        playView.heightAnchor.constraint(equalTo: playView.heightAnchor).isActive = true
        playView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true

    }
    
    private func transparentViewConstraints() {
        transparentView.translatesAutoresizingMaskIntoConstraints = false
        transparentView.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 0).isActive = true
        transparentView.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: 0).isActive = true
        transparentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0).isActive = true
        transparentView.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.3).isActive = true
    }
}
