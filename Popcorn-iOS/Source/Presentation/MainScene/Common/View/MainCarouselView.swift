//
//  MainCellPagingImageView.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 11/16/24.
//

import UIKit

final class MainCarouselView: UIView {
    private var viewModel: MainCarouselViewModelProtocol?

    weak var delegate: MainCarouselViewDelegate?

    private let carouselCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true

        return collectionView
    }()

    private let imagePageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .popcornOrange)
        pageControl.pageIndicatorTintColor = .white

        return pageControl
    }()

    init(viewModel: MainCarouselViewModelProtocol?) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureInitialSetting()
        configureSubviews()
        configureLayout()

        if let viewModel {
            bind(to: viewModel)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(to viewModel: MainCarouselViewModelProtocol) {
        viewModel.carouselImagePublisher = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.imagePageControl.numberOfPages = viewModel.numbersOfCarouselImage()
                self.carouselCollectionView.reloadData()
            }
        }
    }

    func updateViewModel(viewModel: MainCarouselViewModelProtocol) {
        self.viewModel = viewModel
        bind(to: viewModel)
        viewModel.carouselImagePublisher?()
    }
}

// MARK: - Configure Initial Setting
extension MainCarouselView {
    private func configureInitialSetting() {
        carouselCollectionView.dataSource = self
        carouselCollectionView.delegate = self

        carouselCollectionView.register(
            MainCarouselCollectionViewCell.self,
            forCellWithReuseIdentifier: MainCarouselCollectionViewCell.reuseIdentifier
        )
    }
}

// MARK: - Configure CollectionView DataSource
extension MainCarouselView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.numbersOfCarouselImage() ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainCarouselCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? MainCarouselCollectionViewCell else {
            return UICollectionViewCell()
        }

        if let carouselImagesUrl = viewModel?.provideCarouselImageUrl(at: indexPath) {
            viewModel?.fetchImage(url: carouselImagesUrl) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let imageData):
                        if let image = UIImage(data: imageData) {
                            cell.configureContents(image: image)
                        }
                    case .failure:
                        cell.configureContents(image: UIImage(resource: .popupPreviewPlaceHolder))
                    }
                }
            }
        }
        return cell
    }
}

// MARK: - Configure UICollectionView Delegate
extension MainCarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapCarouselImage(selectedIndex: indexPath.item)
    }
}

// MARK: - Configure UICollectionViewDelegateFlowLayout
extension MainCarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = collectionView.bounds.height

        return CGSize(width: width, height: height)
    }
}

// MARK: - Configure ScrollView Delegate
extension MainCarouselView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width

        if width != 0 {
            let currentPage = Int(scrollView.contentOffset.x / width)
            imagePageControl.currentPage = currentPage
        }
    }
}

// MARK: - Configure UI
extension MainCarouselView {
    private func configureSubviews() {
        [carouselCollectionView, imagePageControl].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            carouselCollectionView.topAnchor.constraint(equalTo: topAnchor),
            carouselCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            carouselCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            carouselCollectionView.centerYAnchor.constraint(equalTo: centerYAnchor),

            imagePageControl.bottomAnchor.constraint(equalTo: carouselCollectionView.bottomAnchor),
            imagePageControl.centerXAnchor.constraint(equalTo: carouselCollectionView.centerXAnchor)
        ])
    }
}
