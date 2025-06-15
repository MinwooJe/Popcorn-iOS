//
//  PopupInformationResponseDTO.swift
//  Popcorn-iOS
//
//  Created by 제민우 on 2/17/25.
//

import Foundation

struct PopupInformationResponseDTO: Decodable {
    let id: Int
    let imageUrls: [String]
    let title: String
    let startDate: String
    let endDate: String
    let isPick: Bool
    let hashtag: String

    let address: String
    let officialLink: String
    let businesesHours: String
    let introduce: String
    let reservationUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "popupId"
        case imageUrls = "popupImage"
        case title
        case startDate = "startedAt"
        case endDate = "endedAt"
        case isPick = "isLiked"
        case hashtag = "interest"

        case address = "location"
        case officialLink = "organizerUrl"
        case businesesHours = "business_hours"
        case introduce = "content"
        case reservationUrl = "reservationUrl"
    }
}

extension PopupInformationResponseDTO {
    func toEntity() -> PopupInformation {
        let errorDate = DateFormatter.apiDateFormatter.date(from: "1900-01-01 00:00:00")!
        let startDate = DateFormatter.apiDateFormatter.date(from: startDate) ?? errorDate
        let endDate = DateFormatter.apiDateFormatter.date(from: endDate) ?? errorDate

        return PopupInformation(
            id: id,
            imageUrls: imageUrls,
            title: title,
            startDate: startDate,
            endDate: endDate,
            isPick: isPick,
            hashTags: [hashtag],
            address: address,
            organizationUrl: officialLink,
            businesesHours: businesesHours,
            introduce: introduce,
            reservationUrl: reservationUrl
        )
    }
}
