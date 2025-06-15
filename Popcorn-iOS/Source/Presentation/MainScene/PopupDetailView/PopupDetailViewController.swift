//
//  PopupDetailViewController.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 11/25/24.
//

import UIKit

final class PopupDetailViewController: UIViewController {
    private let viewModel: PopupDetailViewModel
    private let popupId: Int

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateCollectionViewLayout()
    )

    private var segmentIndex: Int = 0

    init(viewModel: PopupDetailViewModel, popupId: Int) {
        self.viewModel = viewModel
        self.popupId = popupId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialSetting()
        configureSubviews()
        configureLayout()
        bind(to: viewModel)
        viewModel.fetchPopupDetail(for: popupId)
    }

    private func bind(to viewModel: PopupDetailViewModel) {
        viewModel.popupInformationPublisher = { [weak self] in
            guard let self else { return }
            if segmentIndex == 0 {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }

        viewModel.popupReviewPublisher = { [weak self] in
            guard let self else { return }
            if segmentIndex == 1 {
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(2...2))
                }
            }
        }

        viewModel.popupPickPublisher = { [weak self] isPick in
            guard let self else { return }

            DispatchQueue.main.async {
                // 찜 버튼이 있는 PopupTitleCollectionViewCellSection의 IndexPath
                let indexPath = IndexPath(item: 0, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? PopupTitleCollectionViewCell {
                    cell.updatePickButtonStatus(isPick: isPick)
                }
            }
        }
    }
}

// MARK: - Configure Initial Setting
extension PopupDetailViewController {
    private func configureInitialSetting() {
        view.backgroundColor = .white
        configureCollectionView()
        configureNavigationBar()
    }

    private func configureCollectionView() {
        collectionView.dataSource = self

        collectionView.register(
            PopupTitleCollectionViewCell.self,
            forCellWithReuseIdentifier: PopupTitleCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            PopupDetailInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: PopupDetailInfoCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            PopupRatingCollectionViewCell.self,
            forCellWithReuseIdentifier: PopupRatingCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            ReviewCollectionViewCell.self,
            forCellWithReuseIdentifier: ReviewCollectionViewCell.reuseIdentifier
        )

        collectionView.register(
            CarouselHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CarouselHeaderView.reuseIdentifier
        )
        collectionView.register(
            PopupInfoReviewSegmentHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PopupInfoReviewSegmentHeaderView.reuseIdentifier
        )
        collectionView.register(
            ReviewSortButtonHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ReviewSortButtonHeaderView.reuseIdentifier
        )
    }
}

// MARK: - Configure Navigation Bar
extension PopupDetailViewController {
    private func configureNavigationBar() {
        navigationItem.title = "상세정보"

        navigationItem.hidesBackButton = true

        let backButton = UIBarButtonItem(
            image: UIImage(resource: .naviBackButton),
            style: .plain,
            target: self,
            action: #selector(popViewController)
        )

        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    @objc private func popViewController() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Implement CollectionView DataSource
extension PopupDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return segmentIndex == 0 ? 2 : 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (section, segmentIndex) {
        case (0, _):
            return 1
        case (1, _):
            return 1
        case (2, 1):
            return viewModel.getDataSource().numberOfReviews()
        default:
            return 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch (indexPath.section, segmentIndex) {
        case (0, _):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopupTitleCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? PopupTitleCollectionViewCell else {
                return UICollectionViewCell()
            }

            let data = viewModel.getDataSource().mainInformationItem()
            cell.configureContents(data)
            cell.delegate = self

            return cell
        case (1, 0):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopupDetailInfoCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? PopupDetailInfoCollectionViewCell else {
                return UICollectionViewCell()
            }

            let data = viewModel.getDataSource().detailInformationItem()
            cell.configureContents(data)

            cell.delegate = self

            cell.delegate = self

            return cell
        case (1, 1):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopupRatingCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? PopupRatingCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.delegate = self
            let (data, maximumIndex) = viewModel.getDataSource().ratingItem()
            let isWriteReviewEnabled = viewModel.isWriteReviewEnabled()

            cell.configureContents(data: data, maximumIndex: maximumIndex, isWriteReviewEnabled: isWriteReviewEnabled)

            return cell
        case (2, 1):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ReviewCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ReviewCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.delegate = self

            let data = viewModel.getDataSource().reviewItem(at: indexPath.item)
            var profileImage = UIImage(resource: .grayCircle)
            var reviewImages = [UIImage]()

            let dispatchGroup = DispatchGroup()

            if let profileImageUrl = data.profileImageUrl {
                dispatchGroup.enter()
                viewModel.fetchImage(url: profileImageUrl) { result in
                    if case .success(let imageData) = result,
                       let image = UIImage(data: imageData) {
                        profileImage = image
                    }
                    dispatchGroup.leave()
                }
            }

            if let reviewImagesUrls = data.reviewImagesUrl {
                reviewImagesUrls.forEach { url in
                    dispatchGroup.enter()
                    viewModel.fetchImage(url: url) { result in
                        if case .success(let imageData) = result,
                           let image = UIImage(data: imageData) {
                            reviewImages.append(image)
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                cell.configureContents(
                    profileImage: profileImage,
                    reviewImages: reviewImages,
                    reviewData: data
                )
            }

            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch (indexPath.section, segmentIndex) {
        case (0, _):
            guard let carouselHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: CarouselHeaderView.reuseIdentifier,
                for: indexPath
            ) as? CarouselHeaderView else {
                return UICollectionReusableView()
            }

            carouselHeader.assignDelegate(self)
            carouselHeader.configureContents(viewModel: viewModel)
            return carouselHeader
        case (1, _):
            guard let segmentHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: PopupInfoReviewSegmentHeaderView.reuseIdentifier,
                for: indexPath
            ) as? PopupInfoReviewSegmentHeaderView else {
                return UICollectionReusableView()
            }

            segmentHeader.delegate = self

            return segmentHeader
        case (2, 1):
            guard let reviewSortHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ReviewSortButtonHeaderView.reuseIdentifier,
                for: indexPath
            ) as? ReviewSortButtonHeaderView else {
                return UICollectionReusableView()
            }

            return reviewSortHeader
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - Configure CollectionView Compositional Layout
extension PopupDetailViewController {
    private func generateCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { return nil }

            switch (sectionIndex, segmentIndex) {
            case (0, _):
                return generateMainInfoLayout()
            case (1, 0):
                return generateDetailInfoLayout()
            case (1, 1):
                return generateRatingLayout()
            case (2, 1):
                return generateReviewLayout()
            default:
                return generateDetailInfoLayout()
            }
        }
    }

    private func generateMainInfoLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let headersize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(359/394)
        )
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headersize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [headerSupplementary]
        section.supplementaryContentInsetsReference = .none

        return section
    }

    private func generateDetailInfoLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(250))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(250))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(37/394)
        )
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [headerSupplementary]
        section.supplementaryContentInsetsReference = .none

        return section
    }

    private func generateRatingLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(347)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(347)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(37/394)
        )
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [headerSupplementary]
        section.supplementaryContentInsetsReference = .none

        return section
    }

    private func generateReviewLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(60/394)
        )
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)

        section.boundarySupplementaryItems = [headerSupplementary]
        section.supplementaryContentInsetsReference = .none

        return section
    }
}

// MARK: - Implement MainCarouselView Delegate
extension PopupDetailViewController: MainCarouselViewDelegate {
    func didTapCarouselImage(selectedIndex: Int) {
        var images = [UIImage]()
        let dispatchGroup = DispatchGroup()

        viewModel.getDataSource().mainInformationItem().popupImagesUrl.forEach {
            dispatchGroup.enter()
            viewModel.fetchImage(url: $0) { result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        images.append(image)
                    }
                case .failure(let error):
                    print(error)
                    images.append(UIImage(resource: .imagePlaceHolder))
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            let fullScreenImageViewController = FullScreenImageViewController(
                images: images,
                selectedIndex: selectedIndex
            )
            fullScreenImageViewController.modalPresentationStyle = .fullScreen
            self.present(fullScreenImageViewController, animated: true)
        }
    }
}

// MARK: - Implement PopupPickButton Delegate
extension PopupDetailViewController: PopupTitleCollectionViewCellDelegate {
    func didTapPickButton() {
        let popupId = viewModel.getDataSource().getPopupId()
        viewModel.didTapPickButton(for: popupId)
    }

    func didTapShareButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let popupUrlString = viewModel.getDataSource().detailInformationItem().organizationUrl
            let shareText = "팝업스토어 정보를 확인해보세요! 👉 \(popupUrlString)"

            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.airDrop, .print, .sharePlay]
            self.present(activityVC, animated: true)
        }
    }
}

// MARK: - Implement PopupDetailInfoCollectionViewCell Delegate
extension PopupDetailViewController: PopupDetailCollectionViewCellDelegate {
    func didTapReservationButton() {
        let reservationUrlString = viewModel.getDataSource().detailInformationItem().reservationUrl
        UIApplication.shared.open(URL(string: reservationUrlString)!, options: [:], completionHandler: nil)
    }
}

// MARK: - Implement WriteReviewButton Delegate
extension PopupDetailViewController: WriteReviewButtonDelegate {
    func didTapWriteReviewButtonDelegate() {
        let imageUrl = viewModel.provideCarouselImageUrl(at: IndexPath(row: 0, section: 0))
        let data = viewModel.getDataSource().mainInformationItem()

        viewModel.fetchImage(url: imageUrl) { result in
            var mainImage = UIImage(resource: .popupPreviewPlaceHolder)

            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    mainImage = image
                }
            case .failure(let error):
                print(error)
            }

            DispatchQueue.main.async {
                let writeReviewViewController = WriteReviewViewController(
                    image: mainImage,
                    title: data.popupTitle,
                    period: data.popupPeriod
                )
                self.navigationController?.pushViewController(writeReviewViewController, animated: true)
            }
        }
    }
}

// MARK: - Implement ReviewCollectionViewCell Delegate
extension PopupDetailViewController: ReviewCollectionViewCellDelegate {
    func didTapReviewImages(images: [UIImage], selecetedIndex: Int) {
        let fullScreenImageViewController = FullScreenImageViewController(
            images: images,
            selectedIndex: selecetedIndex
        )
        fullScreenImageViewController.modalPresentationStyle = .fullScreen
        present(fullScreenImageViewController, animated: true)
    }

    func didTapReviewLikeButton() {
        // 해당 리뷰의 식별자를 뷰 모델에 전달
        viewModel.didTapReviewLikeButton()
    }
}

// MARK: - Implement PopupInfoReviewSegmentHeaderView Delegate
extension PopupDetailViewController: PopupInfoReviewSegmentHeaderViewDelegate {
    func didChangedSegment(to index: Int) {
        segmentIndex = index
        collectionView.reloadData()
    }
}

// MARK: - Configure UI
extension PopupDetailViewController {
    private func configureSubviews() {
        [collectionView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
}

// MARK: - Mocking
extension PopupDetailViewController {
    private func mockingData() {
        viewModel.generateMockData()
    }
}
