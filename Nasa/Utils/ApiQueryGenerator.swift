//
//  ApiQueryGenerator.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import Foundation

enum APIadress: String {
    case mediaLibrary
}

///setup diferent API here, add cases with the constat/string it will return
extension APIadress{
    var apiString: String {
        switch self{
        case .mediaLibrary:
            return MediaApiConstants.mediaAPI
        }
    }
}

/// definition of Apiquery structure
struct ApiQuery {
    let queryType : QueryType
    let api: APIadress
    let path: EndpointAdress
    let queryItems: [URLQueryItem]?
    let query : String?
}

extension ApiQuery {
    /// setup the url you will use to call the networkmanage
    /// - Parameters:
    ///   - api: 'APIAdress' containing the body of the api's url
    ///   - endpoint: 'EndpointAdress' containing the endpoint location
    ///   - query: 'QueryType' to define the complexity of the query
    ///   - queryDictionary: a dictionary [String:String] representing the key-values to add in the search add if Query is type complex
    ///   - queryString: a 'String' containing the nasa id or album to search add if Query is type simple
    /// - Returns: ApiQuery: contains the data to form the url by the network manager
    static func generateURL(api: APIadress,
                            endpoint: EndpointAdress,
                            queryType: QueryType,
                            queryDictionary: [String:String]? = nil,
                            queryString: String? = nil) -> ApiQuery {
        /// here setup the usage for a simple query
        switch queryType {
        case .simpleQuery:
            return ApiQuery (
                queryType: queryType,
                api: api,
                path: endpoint,
                queryItems: nil,
                query: EndpointAdress.setupSimpleQuery(from: queryString ?? "")
            )
        /// here setup the usage for a complex query with multiple parameters
        case .complexQuery:
            return ApiQuery (
                queryType: queryType,
                api: api,
                path: endpoint,
                queryItems: EndpointAdress.setupComplexQuery(from: queryDictionary ?? ["":""]),
                query: nil)
        }
    }
}

extension ApiQuery {
    ///setup the components the service will need for the url.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = api.apiString
        components.path = path.endpointString
        let queryType: QueryType = queryType
        switch queryType {
        case .simpleQuery:
            ///since it's a simple query and we dont want aditional simbols we just inject it into the path
            components.path = path.endpointString.appending("\(query ?? "")")
        case .complexQuery:
            ///we need to process the query into a list of queryitems, the components will order it.
            components.queryItems = queryItems
        }
        ///when the components are setup we return to the url the sum of the components
        return components.url
    }
}

///define the structure for diferent endpoints
enum EndpointAdress: String {
    case search
    case assets
    case metadata
    case captions
    case album
}

///define the endpoit's path as a string to be used later.
extension EndpointAdress {
    var endpointString: String {
        switch self {
        case .search:
            return MediaApiConstants.searchEndpoint
        case .assets:
            return MediaApiConstants.assetEndpoint
        case .metadata:
            return MediaApiConstants.metadataEndpoint
        case .captions:
            return MediaApiConstants.captionEndpoint
        case .album:
            return MediaApiConstants.albumEndpoint
        }
    }
}

///setup and process the received data to be implemented into the components.
extension EndpointAdress {
    /// process a dictionary and return it as a list of urlqueries
    /// - Parameter queryDict: a dictionary where the key and value will remain as are when set into the components, reffer to API documentation
    /// - Returns: a list with the necessary queries to add to the url components
    static func setupComplexQuery(from queryDict: [String: String]) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for (key, value) in queryDict{
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        return queryItems
    }
    static func setupSimpleQuery(from valueString: String) -> String {
        return valueString
    }
}

/// define the types of queries
enum QueryType{
    ///example albums/nasa_id
    case simpleQuery
    ///multiple parameters /search?q=q&mediatype=video
    case complexQuery
}
