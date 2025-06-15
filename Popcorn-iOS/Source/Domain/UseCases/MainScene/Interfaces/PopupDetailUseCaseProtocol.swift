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

    func fetchPopupReviews(popupId: Int, page: Int, completion: @escaping (Result<PopupReviewList, Error>) -> Void)

    func togglePopupPick(popupId: Int, completion: @escaping (Result<Bool, Error>) -> Void)

    func extractHashTag(from popupInformation: PopupInformation) -> [String]
}
