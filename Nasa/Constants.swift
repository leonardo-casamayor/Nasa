//
//  Constants.swift
//  Nasa
//
//  Created by user on 20/07/2024.
//

import UIKit

struct GeneralConstants {
    static let nasaBlue = UIColor(red:0.02, green:0.24, blue:0.58, alpha:1)
}

struct LoginConstants {
    static let buttonColor = UIColor.white
    static let buttonBorderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1)
    static let segueIdentifier = "loginIdentifier"
    static let userDefaultKey = "isLogin"
    static let errorLoginEmptyField = "Please input your login data"
    static let errorLoginNoUserFound = "Login information does not match"
    static let errorRegisterEmptyField = "Input a username and password to register"
    static let errorRegisterUserExists = "User is already registered"
}
