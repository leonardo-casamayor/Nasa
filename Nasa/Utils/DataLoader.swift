//
//  DataLoader.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import Foundation

enum MediaNetworkError: Error {
    case urlError
    case redirectionError
    case clientError
    case serverError
    case parsingError
    case unknown
}

enum ApplicationError: Error {
    case connectionLost
    case applicationForceQuit
    case other
}

protocol NetworkingFacade {
    typealias result<T> = (Result<T, Error>) -> Void
    func request<T: Decodable>(of type: T.Type, endpoint: URL?, completion: @escaping result<T>)
}

class DataLoader: NetworkingFacade {
    /// Request data from endpoint
    /// - Parameters:
    ///   - type: Select the model that will be used
    ///   - endpoint: URL defining the endpoint to access
    ///   - completion: On success: return the Data in 'type' format. On failure: return an error describing what went wrong
    func request<T>(of type: T.Type, endpoint: URL?, completion: @escaping result<T>) where T : Decodable {
        guard let url = endpoint else {
            // Triggers if url was faulty
            completion(.failure(MediaNetworkError.urlError))
            return
        }
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                switch (error as NSError).code {
                // Possible aplication errors
                case NSURLErrorNetworkConnectionLost:
                    completion(.failure(ApplicationError.connectionLost))
                    return
                case NSURLErrorCancelledReasonUserForceQuitApplication:
                    completion(.failure(ApplicationError.applicationForceQuit))
                    return
                default:
                    completion(.failure(ApplicationError.other))
                    return
                }
            }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200...299:
                    print("Success contacting API")
                //Possible conection errors
                case 300...399:
                    completion(.failure(MediaNetworkError.redirectionError))
                case 400...499:
                    completion(.failure(MediaNetworkError.clientError))
                case 500...599:
                    completion(.failure(MediaNetworkError.serverError))
                default:
                    completion(.failure(MediaNetworkError.unknown))
                }
            }
            if let myData = data {
                do {
                    // Decode data if possible else, return a ParsingError
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decodedObject = try decoder.decode(T.self, from: myData)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(MediaNetworkError.parsingError))
                }
            }
        }
        task.resume()
    }
}
