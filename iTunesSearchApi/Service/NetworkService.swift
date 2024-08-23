//
//  NetworkService.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation

enum NetworkError: Error {
    case paramsEncodeError
    case pathEncodeError
    case badResponse
    case timeout
    case unknownError
}
extension NetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .paramsEncodeError:
            return "Params encode error."
        case .pathEncodeError:
            return "Path encode error."
        case .badResponse:
            return "There is a problem with the server. Please try again."
        case .timeout:
            return "Request timed out."
        case .unknownError:
            return "Something went wrong. Please try again."
        }
    }
}

enum APIEndpoint<Response: Codable> {
    
    case search(term: String, media: SearchMediaType, limit: Int)
    case lookupArtistInfo(id: Int)
    case lookupArtistWorks(id: Int, amgId: Int?, entity: String, limit: Int)
    
    var method: String {
        return "GET"
    }
    var path: String {
        switch self {
        case .search(let term, let media, let limit):
            return "https://itunes.apple.com/search?term=\(term)&media=\(media.rawValue)&limit=\(limit)"
        case .lookupArtistInfo(let id):
            return "https://itunes.apple.com/lookup?id=\(id)"
        case .lookupArtistWorks(let id, let amgId, let entity, let limit):
            if let amgId {
                return "https://itunes.apple.com/lookup?amgArtistId=\(amgId)&entity=\(entity)&limit=\(limit)&sort=recent"
            }
            return "https://itunes.apple.com/lookup?id=\(id)&entity=\(entity)&limit=\(limit)&sort=recent"
        }
    }
    var parameters: [String: Any]? {
        return nil
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let encodedPath = self.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedPath) else {
            throw NetworkError.pathEncodeError
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.method
        if let parameters = self.parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw NetworkError.paramsEncodeError
            }
        }
        return urlRequest
    }
}

class NetworkService {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<Response: Codable>(endpoint: APIEndpoint<Response>, completion: @escaping (Result<Response, Error>) -> Void) {
        do {
            //print("request to: \(try endpoint.asURLRequest().url?.absoluteString)")
            var urlRequest = try endpoint.asURLRequest()
            urlRequest.timeoutInterval = 14
            self.session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    if (error as NSError).code == NSURLErrorTimedOut {
                        return completion(.failure(NetworkError.timeout))
                    }
                    return completion(.failure(error))
                }
                guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                    return completion(.failure(NetworkError.badResponse))
                }
                guard let data = data else {
                    return completion(.failure(NetworkError.badResponse))
                }
                //print("response: \(String.init(data: data, encoding: .utf8))")
                do {
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(decoded))
                } catch {
                    debugPrint(error)
                    completion(.failure(error))
                }
            }
            .resume()
        } catch {
            completion(.failure(error))
        }
    }
}
