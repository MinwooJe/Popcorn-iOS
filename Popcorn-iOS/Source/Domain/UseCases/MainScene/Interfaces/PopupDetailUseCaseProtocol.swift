//
//  PopupDetailUseCaseProtocol.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/20/25.
//

protocol PopupDetailUseCaseProtocol {
    func fetchPopupAllData(
        for popupId: Int
    ) async throws -> (PopupInformation, PopupRatingDistribution, PopupReviewList)

    func fetchPopupReviews(popupId: Int, page: Int) async throws -> PopupReviewList

    func togglePopupPick(popupId: Int) async throws -> Bool

    func extractHashTag(from popupInformation: PopupInformation) -> [String]
}
