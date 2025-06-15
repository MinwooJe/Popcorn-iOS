//
//  PopupDetailRepositoryProtocol.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/20/25.
//

import Foundation

protocol PopupDetailRepositoryProtocol {
    func fetchPopupAllData(
        for popupId: Int
    ) async throws -> (PopupInformation, PopupRatingDistribution, PopupReviewList)

    func fetchReviewList(popupId: Int, page: Int) async throws -> PopupReviewList

    func togglePopupPick(popupId: Int) async throws -> Bool
    //  리뷰 좋아요 토글, 리뷰 작성 추가
}
