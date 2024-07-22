//
//  ApodModel.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 21/07/2024.
//

import Foundation

struct APODElement: Codable {
    let date, explanation: String
    let hdurl: String?
    let mediaType: ApodMediaType
    let title: String
    let url: String
    let copyright: String?
    let thumbnailUrl: String?

    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl, title, url, copyright
        case mediaType = "media_type"
        case thumbnailUrl = "thumbnail_url"
    }
}

enum ApodMediaType: String, Codable {
    case image = "image"
    case video = "video"
}


typealias Apod = [APODElement]
