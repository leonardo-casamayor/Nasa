//
//  SearchingController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 03/08/2024.
//

import Foundation

protocol SearchingFacade {
    typealias result<NasaImageVideoLibrary> = (Result<NasaImageVideoLibrary, Error>) -> Void
    var media: NasaImageVideoLibrary? { get set }
    func retrieveMedia(queryDictionary: [String:String],
                       completion: @escaping result<NasaImageVideoLibrary>)
}

class SearchingController: SearchingFacade {
    typealias result<NasaImageVideoLibrary> = (Result<NasaImageVideoLibrary, Error>) -> Void
    
    var media: NasaImageVideoLibrary?
    var error: Error?
    
    /// Retrieve Media
    /// - Parameters:
    ///   - queryDictionary: [String:String] dictionary to generate the query
    ///   - completion: on Success will retrieve and allow usage of media, on failure can return an error
    func retrieveMedia(queryDictionary: [String:String],
                       completion: @escaping result<NasaImageVideoLibrary>) {
        let dataManager = DataLoader()
        dataManager.request(of: NasaImageVideoLibrary.self,
                            endpoint: ApiQuery.generateURL(api: APIadress.mediaLibrary,
                                                           endpoint: EndpointAdress.search,
                                                           queryType: QueryType.complexQuery,
                                                           queryDictionary: queryDictionary).url) {
            [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                switch result {
                case.success(let media):
                    strongSelf.media = media
                    completion(result)
                case .failure(let error):
                    strongSelf.error = error
                    completion(result)
                }
            }
        }
    }
}
