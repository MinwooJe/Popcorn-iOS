//
//  PopupDetailUseCase.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/20/25.
//

import Foundation

final class PopupDetailUseCase: PopupDetailUseCaseProtocol {
    private let repository: PopupDetailRepositoryProtocol
    
    init(repository: PopupDetailRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchPopupAllData(
        for popupId: Int
    ) async throws -> (PopupInformation, PopupRatingDistribution, PopupReviewList) {
        var (information, ratingDistribution, reviewList) = try await repository.fetchPopupAllData(for: popupId)
        information.hashTags = extractHashTag(from: information)
        return (information, ratingDistribution, reviewList)
    }
    
    func fetchPopupReviews(
        popupId: Int,
        page: Int
    ) async throws -> PopupReviewList {
        return try await repository.fetchReviewList(popupId: popupId, page: page)
    }
    
    func togglePopupPick(popupId: Int) async throws -> Bool {
        return try await repository.togglePopupPick(popupId: popupId)
    }
}

extension PopupDetailUseCase {
    func extractHashTag(from popupInformation: PopupInformation) -> [String] {
        let address = popupInformation.address
        let dDay = PopupDateFormatter.calculateDDay(from: popupInformation.endDate)
        return [address, dDay]
    }
}
