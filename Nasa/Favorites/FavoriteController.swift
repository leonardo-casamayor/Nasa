//
//  FavoriteController.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import Foundation

enum UserDefaultsError: Error {
    case NoFavoritesSaved
    case ParsingError
    case NoUserFound
}

protocol FavoriteFacade {
    var favorites: [FavoriteModel]? { get set }
    func obtainUserKey() -> String
    func retrieveFavorites(completion: @escaping(Result<[FavoriteModel], Error>) -> Void)
}

class FavoriteController: FavoriteFacade {
    var favorites: [FavoriteModel]?
    
    internal func obtainUserKey() -> String {
        let logedUser: Users = UsersLoader().load()
        return logedUser.username
    }
    
    func retrieveFavorites(completion: @escaping(Result<[FavoriteModel], Error>) -> Void) {
        let userKey = self.obtainUserKey()
        let userDefaults = UserDefaults.standard
        DispatchQueue.global(qos: .userInteractive).async {
            guard let data = userDefaults.data(forKey: "Favorites/\(userKey)") else {
                completion(.failure(UserDefaultsError.NoUserFound))
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedFavorite = try decoder.decode([FavoriteModel].self, from: data)
                if decodedFavorite.count > 0 {
                    self.favorites = decodedFavorite
                    completion(.success(decodedFavorite))
                } else {
                    completion(.failure(UserDefaultsError.NoFavoritesSaved))
                }
                
            } catch {
                completion(.failure(UserDefaultsError.ParsingError))
            }
        }
    }
}
