//
//  LoginController.swift
//  Nasa
//
//  Created by user on 20/07/2024.
//

import Foundation

protocol LoginProtocol {
    func login() -> Bool
    func register() -> Bool
}

struct LoginController: LoginProtocol {
    var username: String?
    var password: String?
    let userLoader : UserFacade
    
    init(username: String,
         password: String,
         userLoader: UserFacade = UsersLoader() ) {
        self.username = username
        self.password = password
        self.userLoader = userLoader
        userLoader.copyUsersFromBundle()
    }
}

extension LoginController {
    func login() -> Bool {
        guard let user = self.username, let password = self.password else { return false }
        let databaseUser = userLoader.load()
        if databaseUser.username == user && databaseUser.password == password {
            return true
        } else {
            return false
        }
    }
}

extension LoginController {
    func register() -> Bool {
        guard let user = self.username, let password = self.password else { return false }
        let databaseUser = userLoader.load()
        if databaseUser.username != user {
            userLoader.write(user: Users(username: user, password: password))
            return true
        } else {
            return false
        }
    }
}

extension LoginController {
    static func verifyUserAuthenticated() -> Bool {
        let isLogin: Bool = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            return true
        }
        return false
    }
}
