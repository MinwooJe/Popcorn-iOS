//
//  DummyPopupDetailRepository.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/24/25.
//

@testable import Popcorn_iOS

final class DummyPopupDetailRepository: PopupDetailRepositoryProtocol {
    func fetchPopupAllData(for popupId: Int) async throws -> (
        PopupInformation,
        PopupRatingDistribution,
        PopupReviewList
    ) {
        throw NetworkError.emptyData
    }
    
    func fetchReviewList(popupId: Int, page: Int) async throws -> Popcorn_iOS.PopupReviewList {
        throw NetworkError.emptyData

    }
    
    func togglePopupPick(popupId: Int) async throws -> Bool {
        throw NetworkError.emptyData
    }
    
}
