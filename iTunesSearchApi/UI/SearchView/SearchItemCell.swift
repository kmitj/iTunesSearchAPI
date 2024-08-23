//
//  SearchItemCell.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation
import UIKit

class PaddingLabel: UILabel {

    var topInset: CGFloat = 5.0
    var bottomInset: CGFloat = 5.0
    var leftInset: CGFloat = 7.0
    var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

final class SearchItemCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    let coverView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    let typeLabel: PaddingLabel = {
        let view = PaddingLabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        view.textColor = .white
        view.backgroundColor = .systemPurple
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    let priceLabel: PaddingLabel = {
        let view = PaddingLabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.textColor = .white
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    let nameLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.textColor = .darkText
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    private var currentImageUrl: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 10
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.coverView)
        self.contentView.addSubview(self.typeLabel)
        self.coverView.addSubview(self.priceLabel)
        self.coverView.addSubview(self.nameLabel)
        NSLayoutConstraint.activate([
            self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.8),
            self.coverView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10),
            self.coverView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8),
            self.coverView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8),
            self.coverView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
            self.typeLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8),
            self.typeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.nameLabel.leftAnchor.constraint(equalTo: self.coverView.leftAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: self.coverView.topAnchor),
            self.nameLabel.rightAnchor.constraint(equalTo: self.coverView.rightAnchor),
            self.priceLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor),
            self.priceLabel.rightAnchor.constraint(equalTo: self.coverView.rightAnchor),
            self.priceLabel.bottomAnchor.constraint(equalTo: self.coverView.bottomAnchor),
            self.priceLabel.heightAnchor.constraint(equalToConstant: 26),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.currentImageUrl = nil
        self.imageView.image = nil
    }
    
    func configure(data: SearchEntity) {
        self.typeLabel.text = data.kind?.rawValue.capitalized ?? "Unknown"
        if let imageUrl = data.artworkUrl100 ?? data.artworkUrl60, let url = URL(string: imageUrl) {
            self.currentImageUrl = imageUrl
            ImageService.instance.downloadImage(from: url) { [weak self] image in
                guard let self = self, self.currentImageUrl == imageUrl else {
                    return
                }
                self.imageView.image = image ?? UIImage(named: "no_image")
            }
        } else {
            self.currentImageUrl = nil
            self.imageView.image = UIImage(named: "no_image")
        }
        if let name = data.trackName ?? data.collectionName {
            if let artist = data.artistName {
                self.nameLabel.text = "\(name)\n\(artist)"
            } else {
                self.nameLabel.text = name
            }
        } else {
            self.nameLabel.text = data.artistName ?? "Noname"
        }
        if let price = data.trackPrice ?? data.collectionPrice, price > 0 {
            self.priceLabel.text = "\(price) \(data.currency ?? "USD")"
        } else {
            self.priceLabel.text = "Free"
        }
    }
}
