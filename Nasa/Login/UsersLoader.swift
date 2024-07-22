//
//  UsersLoader.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 20/07/2024.
//

import Foundation

struct Users: Codable {
    let username: String
    let password: String
}

protocol UserFacade {
    func load() -> Users
    func copyUsersFromBundle()
    func verifyUserExists(user: Users, fileUser: Users) -> Bool
    func write(user: Users)
}

class UsersLoader: UserFacade {
    // setup the location where we will be trying to modify the plist
    var plistURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("Users.plist")
    }
    
    func load() -> Users {
        // obtain the Users stored in the plist
        let decoder = PropertyListDecoder()
        
        guard let data = try? Data.init(contentsOf: plistURL),
              let users = try? decoder.decode(Users.self, from: data)
        else { return Users(username: "", password: "") }
        return users
    }
}
extension UsersLoader {
    
    func copyUsersFromBundle() {
        // copy the contents of the plist within our bundle to an editable location
        if let path = Bundle.main.path(forResource: "Users", ofType: "plist"),
           let data = FileManager.default.contents(atPath: path),
           FileManager.default.fileExists(atPath: plistURL.path) == false {
            FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
        }
    }
}
extension UsersLoader {
    // check data received against the plist file to very user existance
     func verifyUserExists(user: Users, fileUser: Users) -> Bool {
        if user.username == fileUser.username {
            return false
        }
        return true
    }
    
    func write(user: Users) {
        let fileUser = load()
        ///check for user existance
        guard verifyUserExists(user: user, fileUser: fileUser) else { return }
        /// setup the encoder
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(user) {
            if FileManager.default.fileExists(atPath: plistURL.path) {
                // Update an existing plist
                try? data.write(to: plistURL)
            } else {
                // Create a new plist
                FileManager.default.createFile(atPath: plistURL.path, contents: data, attributes: nil)
            }
        }
    }
}
