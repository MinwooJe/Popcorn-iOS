//
//  PopupDetailViewModel.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 1/5/25.
//

import Foundation

final class PopupDetailViewModel: MainCarouselViewModelProtocol {
    private let imageFetchUseCase: ImageFetchUseCaseProtocol
    private let popupDetailUseCase: PopupDetailUseCaseProtocol
    private let popupDetailDataSource: PopupDetailDataSource
    private var reviewPage = 1

    // MARK: - Output
    var carouselImagePublisher: (() -> Void)?
    /// 상세화면 첫 진입시 캐러셀 이미지 헤더, 정보 탭, 후기 탭을 받아오고, 이를 뷰에 알리는 클로저
    var popupInformationPublisher: (() -> Void)?
    var popupReviewPublisher: (() -> Void)?
    var popupPickPublisher: ((Bool) -> Void)?

    init(imageFetchUseCase: ImageFetchUseCaseProtocol,
         popupDetailUseCase: PopupDetailUseCaseProtocol,
         popupDetailDataSource: PopupDetailDataSource = PopupDetailDataSource()
    ) {
        self.imageFetchUseCase = imageFetchUseCase
        self.popupDetailUseCase = popupDetailUseCase
        self.popupDetailDataSource = popupDetailDataSource
    }

    func getDataSource() -> PopupDetailDataSource {
        return popupDetailDataSource
    }

    func isFinished() -> Bool {
        return popupDetailDataSource.detailInformationItem().isFinished
    }

    func isWriteReviewEnabled() -> Bool {
        return popupDetailDataSource.detailInformationItem().isWriteReviewEnabled
    }
}

// MARK: - Input
extension PopupDetailViewModel {
    func didTapPickButton(for popupId: Int) {
        popupDetailUseCase.togglePopupPick(popupId: popupId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let isPick):
                self.popupDetailDataSource.updatePickStatus(isPick)
                popupPickPublisher?(isPick)
            case .failure(let error):
                // TODO: 에러 UI 처리
                print("찜하기 실패: \(error)")
            }
        }
    }

    func didTapReviewLikeButton() {
        // 각 리뷰의 식별자를 파라미터로 받기
        // 유즈케이스를 통해 서버에 토글 요청
    }
}

// MARK: - Networking
extension PopupDetailViewModel {
    func fetchImage(url: String, completion: @escaping (Result<Data, ImageFetchError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        imageFetchUseCase.fetchImage(url: url, completion: completion)
    }

    func fetchPopupDetail(for popupId: Int) {
        Task {
            do {
                let (information, ratingDistribution, reviewList) = try await popupDetailUseCase.fetchPopupAllData(for: popupId)
                popupDetailDataSource.updateInformationData(information)
                popupDetailDataSource.updateRatingData(ratingDistribution)
                popupDetailDataSource.updateReviewData(reviewList)
            } catch {
                popupDetailDataSource.showPlaceholderData()

                if let error = error as? NetworkError {
                    print(#function, error.description)
                } else {
                    print(#function, error)
                }
            }

            carouselImagePublisher?()
            popupInformationPublisher?()
            popupReviewPublisher?()
        }
    }

    func fetchPopupReview() {
        let popupId = popupDetailDataSource.getPopupId()
        popupDetailUseCase.fetchPopupReviews(popupId: popupId, page: reviewPage) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let popupReviewList):
                self.popupDetailDataSource.updateReviewData(popupReviewList)
            case .failure:
                popupDetailDataSource.showPlaceholderReviewData()
            }
        }
        popupReviewPublisher?()
    }

    func generateMockData() {
        getDataSource().generateMockData()
    }
}

// MARK: - Implement MainCarouselViewModelProtocol
extension PopupDetailViewModel {
    func numbersOfCarouselImage() -> Int {
        return popupDetailDataSource.numberOfCarouseImage()
    }

    func provideCarouselImageUrl(at indexPath: IndexPath) -> String {
        return popupDetailDataSource.popupImageItem(at: indexPath)
    }
}

// MARK: - View Model
struct PopupMainInformationViewData {
    let popupId: Int
    let popupImagesUrl: [String]
    let popupTitle: String
    let popupPeriod: String
    var isPick: Bool
    let hashTags: [String]

    static let placeholder = PopupMainInformationViewData(
        from: PopupInformation(
            id: -1,
            imageUrls: [],
            title: "팝콘 팝업스토어",
            startDate: DateFormatter.apiDateFormatter.date(from: "1900-01-01 00:00:00")!,
            endDate: DateFormatter.apiDateFormatter.date(from: "1900-01-01 00:00:00")!,
            isPick: false,
            hashTags: [],
            address: "",
            organizationUrl: "",
            businesesHours: "",
            introduce: "",
            reservationUrl: ""
        )
    )

    init(from entity: PopupInformation) {
        let startDateString = PopupDateFormatter.formattedPopupStoreDate(from: entity.startDate)
        let endDateString = PopupDateFormatter.formattedPopupStoreDate(from: entity.endDate)

        self.popupId = entity.id
        self.popupImagesUrl = entity.imageUrls
        self.popupTitle = entity.title
        self.popupPeriod = "\(startDateString)~\(endDateString)"
        self.isPick = entity.isPick
        self.hashTags = entity.hashTags
    }
}

struct PopupDetailInformationViewData {
    let address: String
    let organizationUrl: String
    let businesesHours: String
    let introduce: String
    let reservationUrl: String
    let isFinished: Bool
    let isWriteReviewEnabled: Bool

    static let placeholder = PopupDetailInformationViewData(
        from: PopupInformation(
            id: -1,
            imageUrls: [],
            title: "팝콘 팝업스토어",
            startDate: DateFormatter.apiDateFormatter.date(from: "1900-01-01 00:00:00")!,
            endDate: DateFormatter.apiDateFormatter.date(from: "1900-01-01 00:00:00")!,
            isPick: false,
            hashTags: [],
            address: "",
            organizationUrl: "",
            businesesHours: "",
            introduce: "",
            reservationUrl: ""
            )
        )

    init(from entity: PopupInformation) {
        self.address = entity.address
        self.organizationUrl = entity.organizationUrl
        self.businesesHours = entity.businesesHours
        self.introduce = entity.introduce
        self.reservationUrl = entity.reservationUrl
        self.isFinished = entity.isFinished
        self.isWriteReviewEnabled = entity.isWriteReviewEnabled
    }
}

struct PopupRatingViewData {
    let totalRatingCount: Int
    let averageRating: Float
    let ratingDistribution: [RatingDistribution: Int]

    static let placeholder = PopupRatingViewData(
        from: PopupRatingDistribution(
            averageRating: 0,
            ratingDistribution: [.oneStar: 0, .twoStars: 0, .threeStars: 0, .fourStars: 0, .fiveStars: 0]
        )
    )

    init(from entity: PopupRatingDistribution) {
        self.totalRatingCount = entity.ratingDistribution.values.reduce(0, +)
        self.averageRating = entity.averageRating
        self.ratingDistribution = entity.ratingDistribution
    }
}

struct PopupReviewViewData {
    let profileImageUrl: String?
    let nickname: String
    let reviewRating: Float
    let reviewDate: String
    let reviewImagesUrl: [String]?
    let reviewText: String
    let likeCount: String
    let isLiked: Bool

    static let placeholder = PopupReviewViewData(
        from: PopupReview(
            profileImageUrl: nil,
            nickName: "팝콘이",
            rating: 0,
            createdAt: DateFormatter.apiDateFormatter.date(from: "1900-01-01 00:00:00")!,
            reviewImageUrls: nil,
            content: "",
            likeCount: 0,
            isLiked: false
        )
    )

    init(from entity: PopupReview) {
        self.profileImageUrl = entity.profileImageUrl
        self.nickname = entity.nickName
        self.reviewRating = entity.rating
        self.reviewDate = PopupDateFormatter.formattedReviewDate(from: entity.createdAt)
        self.reviewImagesUrl = entity.reviewImageUrls
        self.reviewText = entity.content
        self.likeCount = String(entity.likeCount)
        self.isLiked = entity.isLiked
    }
}
