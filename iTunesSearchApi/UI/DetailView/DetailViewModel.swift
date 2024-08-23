//
//  DetailViewModel.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation

struct LookupResult: Codable {
    let resultCount: Int
    let results: [SearchEntity]
}

class DetailViewModel {
    
    private(set) var state: ViewState = .empty {
        didSet {
            stateChanged?(state)
        }
    }
    var stateChanged: ((ViewState) -> Void)?
    let entity: SearchEntity
    var artistInfo: SearchEntity? = nil
    var artistReleted: [SearchEntity] = []
    let networkService: NetworkService
    
    init(networkService: NetworkService, entity: SearchEntity) {
        self.entity = entity
        self.networkService = networkService
    }
    
    func performLookup(id: Int, entity: String) {
        self.state = .loading
        let searchEnd = APIEndpoint<LookupResult>.lookupArtistInfo(id: id)
        self.networkService.request(endpoint: searchEnd) { response in
            switch response {
            case .success(let success):
                guard let artistInfo = success.results.first else {
                    self.performLookupReleted(id: id, amgId: nil, entity: entity)
                    return
                }
                self.artistInfo = artistInfo
                self.performLookupReleted(id: id, amgId: artistInfo.amgArtistId, entity: entity)
            case .failure(let failure):
                self.state = .error(failure.localizedDescription)
            }
        }
    }
    
    private func performLookupReleted(id: Int, amgId: Int?, entity: String) {
        let searchEnd = APIEndpoint<LookupResult>.lookupArtistWorks(id: id, amgId: amgId, entity: entity, limit: 5)
        self.networkService.request(endpoint: searchEnd) { response in
            switch response {
            case .success(let success):
                //somtimes getting more item then limit.
                if success.results.count > 5 {
                    self.artistReleted = Array(success.results.prefix(5))
                } else {
                    self.artistReleted = success.results
                }
                self.state = .success
            case .failure(let failure):
                self.state = .error(failure.localizedDescription)
            }
        }
    }
}
