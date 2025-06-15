//
//  APIConstant.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 1/23/25.
//

struct APIConstant {
    // MARK: - Base URL
    static let baseURL = "https://popcorm.store"

    // MARK: - Auth & Token
    static let authPath = "/auth"
    static let reissueTokenPath = "/reissue"

    // MARK: - Login
    static let loginPath = "/login"

    // MARK: - Sign Up
    static let checkUsernamePath = "/auth/chkUser"
    static let checkDuplicationEmailPath = "/auth/validEmail"
    static let sendAuthNumPath = "/mailsend"
    static let validateAuthNumPath = "/mailauthChk"
    static let signUpPath = "/auth/signup"
    static let isKakaoUserPath = "/api/v1/auth/oauth/kakao"
    static let kakaoSignUpPath = "/api/v1/auth/oauth/kakao/signup"
    static let isAppleUserPath = "/api/v1/auth/oauth/apple"
    static let appleSignUpPath = "/api/v1/auth/oauth/apple/signup"

    // MARK: - Main Scene
    static let mainScenePath = "/popups/home"
    static let userPickOverviewPath = "/popups/likes"
    static func interestOverviewPath(category: String) -> String {
        return "/popups/interests/\(category)"
    }

    // MARK: - Main Detail Scene
    static let writePopupReview = "/popups/reviews"
    static let updatePopupReview = "/popups/reviews"

    static func popupDetailPath(popupId: String) -> String {
        return "/popups/\(popupId)"
    }

    static func popupTogglePick(popupId: String) -> String {
        return "/popups/\(popupId)/toggle-like"
    }

    static func popupRatingPath(popupId: String) -> String {
        return "/api/popups/reviewrating/\(popupId)"
    }

    static func popupReviewPath(popupId: String) -> String {
        return "/api/reviews/popups/\(popupId)"
    }

    static func popupReviewToggleLike(popupId: String) -> String {
        return "popups/\(popupId)/toggle-reviewlike"
    }

    static func deletePopupReview(popupId: String) -> String {
        return "popups/reviews/\(popupId)"
    }
}
