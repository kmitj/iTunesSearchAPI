//
//  SearchViewModel.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation

enum SearchMediaType: String, CaseIterable {
    case movie, podcast, music, musicVideo, audiobook, shortFilm, tvShow, software, ebook, all
}

struct SearchResult: Codable {
    let resultCount: Int
    let results: [SearchEntity]
}
enum ViewState {
    case empty
    case loading
    case success
    case error(String)
}

class SearchViewModel {
    
    
    private(set) var state: ViewState = .empty {
        didSet {
            stateChanged?(state)
        }
    }
    var limit: Int = 20 {
        didSet {
            if let lastQuery {
                self.performSearch(query: lastQuery)
            }
        }
    }
    var kind: SearchMediaType = .all {
        didSet {
            if let lastQuery {
                self.performSearch(query: lastQuery)
            }
        }
    }
    var searchHistory: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "searchHistoryKey") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "searchHistoryKey")
        }
    }
    var lastQuery: String? = nil
    var filteredHistory: [String] = []
    var searchItems: [SearchEntity] = []
    let networkService: NetworkService
    var stateChanged: ((ViewState) -> Void)?
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func updateSearchHistory(query: String) {
        var searchHistoryCopy = self.searchHistory
        if !searchHistoryCopy.contains(query) {
            searchHistoryCopy.insert(query, at: 0)
            if searchHistoryCopy.count > 5 {
                searchHistoryCopy.removeLast()
            }
            self.searchHistory = searchHistoryCopy
        }
    }
    
    func performSearch(query: String) {
        self.lastQuery = query
        self.state = .loading
        let searchEnd = APIEndpoint<SearchResult>.search(term: query, media: self.kind, limit: self.limit)
        self.networkService.request(endpoint: searchEnd) { response in
            switch response {
            case .success(let success):
                self.searchItems = success.results
                self.state = .success
            case .failure(let failure):
                if let e = failure as? NetworkError {
                    self.state = .error(e.description)
                } else {
                    self.state = .error(failure.localizedDescription)
                }
            }
        }
    }
}
