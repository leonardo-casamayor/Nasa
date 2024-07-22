//
//  NetworkManager.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 21/07/2024.
//

import Foundation

enum NetworkError: Error {
    case NoDataAvailable
    case BadURL
    case BadRequest
    case InvalidApiKey
    case ResourceNotFound
    case ServerError
    case ParsingError
    case UnexpectedNetworkError
}
protocol ApodClient {
    func retrieveApodData(completion: @escaping (Result<APODElement, Error>) -> Void)
}

protocol AssetRetriever {
    func retrieveAssets(assetsUrl: String, completion: @escaping (Result<[String], Error>) -> Void)
}

class NetworkManager {
    static func encodeURL(urlString: String) -> String? {
        urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    static func handle(data: Data) -> APODElement? {
        try? JSONDecoder().decode(APODElement.self, from: data)
    }
}

extension NetworkManager: ApodClient {
    func retrieveApodData(completion: @escaping (Result<APODElement, Error>) -> Void) {
        guard let queryString = NetworkManager.encodeURL(urlString: NetworkManagerConstants.apodAPIURL) else {
            print("Bad URL")
            completion(.failure(NetworkError.BadURL))
            return
        }
        guard let url = URL(string: queryString) else {
            print("Bad URL")
            completion(.failure(NetworkError.BadURL))
            return
        }
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request){ (data, response, error) in
            
            guard let dataUnwrap = data else {
                completion(.failure(NetworkError.NoDataAvailable))
                return }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                let stausCode = httpResponse.statusCode
                switch stausCode {
                case 400:
                    print("Bad request")
                    completion(.failure(NetworkError.BadRequest))
                case 403:
                    print("Invalid api key")
                    completion(.failure(NetworkError.InvalidApiKey))
                case 404:
                    print("Resource Not Found")
                    completion(.failure(NetworkError.ResourceNotFound))
                case 200..<300:
                    if let json = NetworkManager.handle(data: dataUnwrap){
                        completion(.success(json))
                    }
                case 500..<600:
                    print("Server error")
                    completion(.failure(NetworkError.ServerError))
                default:
                    print("Unexpected Error")
                    completion(.failure(NetworkError.UnexpectedNetworkError))
                }
            }
        }
        task.resume()
    }
}

extension NetworkManager: AssetRetriever {
    func retrieveAssets(assetsUrl: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let encodedURL = NetworkManager.encodeURL(urlString: assetsUrl) else { return }
        guard let url = URL(string: encodedURL) else {
            completion(.failure(NetworkError.BadURL))
            return
        }
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request){ (data, response, error) in
            
            guard let dataUnwrap = data,
                  error == nil else {
                completion(.failure(NetworkError.ResourceNotFound))
                return }
            do {
                let assets = try JSONDecoder().decode([String].self, from: dataUnwrap)
                completion(.success(assets))
            } catch {
                completion(.failure(NetworkError.ParsingError))
            }
        }
        task.resume()
    }
}
