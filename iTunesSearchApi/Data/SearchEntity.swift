//
//  SearchEntity.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation

struct SearchEntity: Codable, Hashable {
    
    enum WrapperType: String, Codable {
        case track
        case collection
        case artist
        case audiobook
    }
    enum Kind: String, Codable {
        case book
        case album
        case pdf
        case podcast
        case song
        case artist
        case tvEpisode = "tv-episode"
        case softwarePackage = "software-package"
        case podcastEpisode = "podcast-episode"
        case musicVideo = "music-video"
        case interactiveBooklet = "interactive-booklet"
        case featureMovie = "feature-movie"
        case coachedAudio = "coached-audio"
    }
    
    
    let wrapperType: WrapperType
    let kind: Kind?
    let artistId: Int?
    let amgArtistId: Int?
    let collectionId: Int?
    let collectionArtistId: Int?
    let trackId: Int?
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let artistViewUrl: String?
    let collectionViewUrl: String?
    let trackViewUrl: String?
    let previewUrl: String?
    let artworkUrl60: String?
    let artworkUrl100: String?
    let collectionPrice: Double?
    let trackPrice: Double?
    let trackTimeMillis: Int64?
    let country: String?
    let currency: String?
    let primaryGenreName: String?
    let shortDescription: String?
}
