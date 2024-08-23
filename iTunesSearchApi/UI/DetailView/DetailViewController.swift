//
//  DetailViewController.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation
import UIKit

final class DetailViewController: UIViewController {
    
    let viewModel: DetailViewModel
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    let scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .onDrag
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .white
        return view
    }()
    let rootView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
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
        view.isHidden = true
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
        view.isHidden = true
        return view
    }()
    let stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 10
        return view
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.loadingIndicator)
        self.scrollView.addSubview(self.rootView)
        self.rootView.addSubview(self.imageView)
        self.rootView.addSubview(self.typeLabel)
        self.rootView.addSubview(self.priceLabel)
        self.rootView.addSubview(self.stackView)
        let rootHeight = self.rootView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        rootHeight.priority = UILayoutPriority(rawValue: 250)
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.color = .systemGreen
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.rootView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
            self.rootView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.rootView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
            self.rootView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.rootView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            rootHeight,
            self.typeLabel.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 12),
            self.typeLabel.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 12),
            self.priceLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -12),
            self.priceLabel.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: -12),
            self.imageView.leftAnchor.constraint(equalTo: self.rootView.leftAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.rootView.topAnchor),
            self.imageView.rightAnchor.constraint(equalTo: self.rootView.rightAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.8),
            self.stackView.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 20),
            self.stackView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20),
            self.stackView.rightAnchor.constraint(equalTo: self.rootView.rightAnchor, constant: -20),
            self.stackView.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor)
        ])
        self.viewModel.stateChanged = { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch state {
                case .empty:break
                case .loading:
                    self.loadingIndicator.startAnimating()
                case .success:
                    self.loadingIndicator.stopAnimating()
                    self.initData(data: self.viewModel.entity)
                case .error(_):
                    self.loadingIndicator.stopAnimating()
                    self.initData(data: self.viewModel.entity)
                }
            }
        }
        if let id = self.viewModel.entity.artistId ?? self.viewModel.entity.amgArtistId ?? self.viewModel.entity.collectionArtistId {
            self.viewModel.performLookup(id: id, entity: self.viewModel.entity.kind?.rawValue ?? "all")
        } else {
            self.initData(data: self.viewModel.entity)
        }
    }
    
    @objc func openEntity(_ sender: EntityItemView) {
        self.navigationController?.pushViewController(DetailViewController(viewModel: .init(networkService: self.viewModel.networkService, entity: sender.data)), animated: true)
    }
    
    @objc func openPage() {
        guard let link = self.viewModel.entity.trackViewUrl, let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    @objc func openArtistPage() {
        guard let link = self.viewModel.entity.artistViewUrl, let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    func getLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        return label
    }
    
    func getButton() -> UIButton {
        let button = UIButton(type: .roundedRect)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        return button
    }
    
    func initData(data: SearchEntity) {
        if let imageUrl = data.artworkUrl100 ?? data.artworkUrl60, let url = URL(string: imageUrl) {
            ImageService.instance.downloadImage(from: url) { [weak self] image in
                guard let self = self else {
                    return
                }
                self.imageView.image = image ?? UIImage(named: "no_image")
            }
        } else {
            self.imageView.image = UIImage(named: "no_image")
        }
        self.typeLabel.text = data.kind?.rawValue.capitalized ?? "Unknown"
        if let price = data.trackPrice ?? data.collectionPrice, price > 0 {
            self.priceLabel.text = "\(price) \(data.currency ?? "USD")"
        } else {
            self.priceLabel.text = "Free"
        }
        self.priceLabel.isHidden = false
        self.typeLabel.isHidden = false
        if let name = data.trackName ?? data.collectionName {
            let label = self.getLabel()
            label.text = name
            label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            self.stackView.addArrangedSubview(label)
        }
        if let dur = data.trackTimeMillis, dur > 0 {
            let label = self.getLabel()
            label.text = "Duration: \(formatTimeMillis(dur))"
            label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            self.stackView.addArrangedSubview(label)
        }
        if let genre = data.primaryGenreName {
            let label = self.getLabel()
            label.text = "Genre: \(genre)"
            label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            self.stackView.addArrangedSubview(label)
        }
        if let dest = data.shortDescription {
            let label = self.getLabel()
            label.text = "Short description: \(dest)"
            label.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            self.stackView.addArrangedSubview(label)
        }
        if let _ = data.trackViewUrl {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "link.circle"), style: .plain, target: self, action: #selector(openPage))
        }
        if let author = self.viewModel.artistInfo?.artistName ?? data.artistName {
            let label = self.getButton()
            label.titleLabel?.textAlignment = .left
            label.setTitle("Author: \(author)", for: .normal)
            label.titleLabel?.numberOfLines = 0
            label.titleLabel?.lineBreakMode = .byWordWrapping
            label.addTarget(self, action: #selector(self.openArtistPage), for: .touchUpInside)
            self.stackView.addArrangedSubview(label)
        }
        if let dur = self.viewModel.artistInfo?.primaryGenreName {
            let label = self.getLabel()
            label.text = "Author Primary Genre: \(dur)"
            label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            self.stackView.addArrangedSubview(label)
        }
        if !self.viewModel.artistReleted.isEmpty {
            let labelInfo = self.getLabel()
            labelInfo.text = "Authors Most Recent:"
            labelInfo.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            self.stackView.addArrangedSubview(labelInfo)
            for item in self.viewModel.artistReleted {
                let entView = EntityItemView(data: item)
                entView.configure()
                entView.addTarget(self, action: #selector(self.openEntity(_:)), for: .touchUpInside)
                self.stackView.addArrangedSubview(entView)
            }
        }
    }
}

func formatTimeMillis(_ millis: Int64) -> String {
    let seconds = millis / 1000
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    } else {
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

class EntityItemView: UIControl {
    
    let imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()
    let nameView: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        view.textColor = .black
        return view
    }()
    let data: SearchEntity
    
    init(data: SearchEntity) {
        self.data = data
        super.init(frame: .zero)
        self.addSubview(self.imageView)
        self.addSubview(self.nameView)
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 48),
            self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: 1),
            self.nameView.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10),
            self.nameView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            self.nameView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        if let imageUrl = data.artworkUrl100 ?? data.artworkUrl60, let url = URL(string: imageUrl) {
            ImageService.instance.downloadImage(from: url) { [weak self] image in
                guard let self = self else {
                    return
                }
                self.imageView.image = image ?? UIImage(named: "no_image")
            }
        } else {
            self.imageView.image = UIImage(named: "no_image")
        }
        let name = data.trackName ?? data.collectionName ?? "No name"
        self.nameView.text = name
    }
}
