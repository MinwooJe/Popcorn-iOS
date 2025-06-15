//
//  PopupDetailRepository.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/20/25.
//

import Foundation

final class PopupDetailRepository: PopupDetailRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let tokenRepository: TokenRepositoryProtocol

    init(networkManager: NetworkManagerProtocol, tokenRepository: TokenRepositoryProtocol) {
        self.networkManager = networkManager
        self.tokenRepository = tokenRepository
    }

    func fetchPopupAllData(
        for popupId: Int
    ) async throws -> (PopupInformation, PopupRatingDistribution, PopupReviewList) {
        // TODO: TokenRepository에서 access token 만료 시 자동으로 reissue 하는 로직 구현 후 리팩토링
        guard let token = tokenRepository.fetchAccessToken() else {
            throw NSError(
                domain: "PopupDetailRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "액세스 토큰 만료"]
            )
        }

        async let information = fetchInformation(popupId: popupId, token: token)
        async let ratingDistribution = fetchRatingDistribution(popupId: popupId, token: token)
        async let reviewList = fetchReviewList(popupId: popupId, token: token)

        return try await (information, ratingDistribution, reviewList)
    }

    func fetchPopupReviews(
        popupId: Int,
        page: Int,
        completion: @escaping (Result<PopupReviewList, any Error>
        ) -> Void) {
        // TODO: TokenRepository에서 access token 만료 시 자동으로 reissue 하는 로직 구현 후 리팩토링
        guard let token = tokenRepository.fetchAccessToken() else {
            completion(.failure(NSError(
                domain: "PopupDetailRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "액세스 토큰 만료"]
            )))
            return
        }

        let endpoint = Endpoint<PopupReviewListResponseDTO>(
            httpMethod: .get,
            path: APIConstant.popupReviewPath(popupId: String(popupId)),
            queryItems: [URLQueryItem(name: "page", value: String(page))],
            headers: ["Authorization": "Bearer \(token)"]
        )

        networkManager.request(endpoint: endpoint) { result in
            switch result {
            case .success(let response):
                let reviewList = response.reviews.map { $0.toEntity() }
                completion(.success(PopupReviewList(reviews: reviewList)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func togglePopupPick(popupId: Int, completion: @escaping (Result<Bool, any Error>) -> Void) {
        // TODO: TokenRepository에서 access token 만료 시 자동으로 reissue 하는 로직 구현 후 리팩토링
        guard let token = tokenRepository.fetchAccessToken() else {
            completion(.failure(NSError(
                domain: "PopupDetailRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "액세스 토큰 만료"]
            )))
            return
        }

        let endpoint = Endpoint<DefaultResponseDTO<Bool>>(
            httpMethod: .post,
            path: APIConstant.popupTogglePick(popupId: String(popupId)),
            headers: ["Authorization": "Bearer \(token)"]
        )

        networkManager.request(endpoint: endpoint) { result in
            switch result {
            case .success(let response):
                let isPick = response.data
                completion(.success(isPick))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension PopupDetailRepository {
    func fetchInformation(popupId: Int, token: String) async throws -> PopupInformation {
        print(popupId)
        let endpoint = Endpoint<PopupInformationResponseDTO>(
            httpMethod: .get,
            path: APIConstant.popupDetailPath(popupId: String(1)),      // TODO: - 서버 데이터 변경 후 1을 popupId로 변경
            headers: ["Authorization": "Bearer \(token)"]
        )

        do {
            return try await networkManager.request(endpoint: endpoint).toEntity()
        } catch {
            print(#function, error)
            throw error
        }
    }

    func fetchRatingDistribution(popupId: Int, token: String) async throws -> PopupRatingDistribution {
        let endpoint = Endpoint<DefaultResponseDTO<PopupRatingDistributionResponseDTO>>(
            httpMethod: .get,
            path: APIConstant.popupRatingPath(popupId: String(popupId))
        )

        do {
            return try await networkManager.request(endpoint: endpoint).data.toEntity()
        } catch {
            print(#function, error)
            throw error
        }
    }

    func fetchReviewList(popupId: Int, token: String) async throws -> PopupReviewList {
        let endpoint = Endpoint<DefaultResponseDTO<PopupReviewListResponseDTO>>(
            httpMethod: .get,
            path: APIConstant.popupReviewPath(popupId: String(popupId)),
            queryItems: [URLQueryItem(name: "page", value: "1")],
            headers: ["Authorization": "Bearer \(token)"]
        )

        do {
            let dto = try await networkManager.request(endpoint: endpoint).data
            return PopupReviewList(reviews: dto.reviews.map { $0.toEntity() })
        } catch {
            print(#function, error)
            throw error
        }
    }
}
