//
//  PopupDetailDataSource.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/13/25.
//

import Foundation

final class PopupDetailDataSource {
    private var popupMainInformation: PopupMainInformationViewData?
    private var popupDetailInformation: PopupDetailInformationViewData?
    private var popupRating: PopupRatingViewData?
    private var popupReviews = [PopupReviewViewData]()
}

// MARK: - Input
extension PopupDetailDataSource {
    func updateInformationData(_ data: PopupInformation) {
        popupMainInformation = PopupMainInformationViewData(from: data)
        popupDetailInformation = PopupDetailInformationViewData(from: data)
    }

    func updateRatingData(_ data: PopupRatingDistribution) {
        popupRating = PopupRatingViewData(from: data)
    }

    func updateReviewData(_ data: PopupReviewList) {
        popupReviews += data.reviews.map { PopupReviewViewData(from: $0) }
    }

    func updatePickStatus(_ isPick: Bool) {
        popupMainInformation?.isPick = isPick
    }
}

// MARK: - Output
extension PopupDetailDataSource {
    func numberOfReviews() -> Int {
        return popupReviews.count
    }

    func numberOfCarouseImage() -> Int {
        guard let popupMainInformation else { return 1 }
        return popupMainInformation.popupImagesUrl.count
    }

    func popupImageItem(at indexPath: IndexPath) -> String {
        guard let popupMainInformation,
              indexPath.row < popupMainInformation.popupImagesUrl.count
        else { return "" }
        
        return popupMainInformation.popupImagesUrl[indexPath.row]
    }

    func mainInformationItem() -> PopupMainInformationViewData {
        guard let popupMainInformation else { return PopupMainInformationViewData.placeholder }
        return popupMainInformation
    }

    func detailInformationItem() -> PopupDetailInformationViewData {
        guard let popupDetailInformation else { return PopupDetailInformationViewData.placeholder }
        return popupDetailInformation
    }

    /// 평점의 개수가 가장 높은 평점의 인덱스를 반환. 단, 평점의 개수가 동률일 경우 평점의 인덱스가 높은 평점을 반환.
    func ratingItem() -> (PopupRatingViewData, Int) {
        guard let popupRating else { return (PopupRatingViewData.placeholder, 0) }

        let maximumIndex = popupRating.ratingDistribution.sorted {
            if $0.value == $1.value {
                return $0.key.ratingIndex > $0.key.ratingIndex
            } else {
                return $0.value > $1.value
            }
        }.first?.key.ratingIndex ?? 4

        return (popupRating, maximumIndex)
    }

    func reviewItem(at index: Int) -> PopupReviewViewData {
        return popupReviews[index]
    }

    func getPopupId() -> Int {
        guard let popupMainInformation else { return 0 }
        return popupMainInformation.popupId
    }

    func showPlaceholderData() {
        popupMainInformation = PopupMainInformationViewData.placeholder
        popupMainInformation = PopupMainInformationViewData.placeholder
        popupDetailInformation = PopupDetailInformationViewData.placeholder
        popupRating = PopupRatingViewData.placeholder
        showPlaceholderReviewData()
    }

    func showPlaceholderReviewData() {
        popupReviews = [PopupReviewViewData.placeholder]
    }
}

// MARK: - Mocking
extension PopupDetailDataSource {
    func generateMockData() {
        let (info, rating, reviews) = MainSceneMockDataConstant.generateDetailData()

        popupMainInformation = PopupMainInformationViewData(from: info)
        popupDetailInformation = PopupDetailInformationViewData(from: info)
        popupRating = PopupRatingViewData(from: rating)
        popupReviews = reviews.map { PopupReviewViewData(from: $0) }
    }
}
