//
//  LoginViewController.swift
//  Nasa
//
//  Created by user on 20/07/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

enum AuthenticationError: Error {
  case tokenError(message: String)
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var registerButton: CustomButton!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllerSetUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verifyUserAuthenticated()
        
    }
    
    // Login button
    @IBAction func loginAction(_ sender: UIButton) {
        Task {
            let loginSuccessful = await signInWithGoogle()
            if loginSuccessful {
                let loginController = LoginController(username: user?.email ?? "", password: user?.refreshToken ?? "")
                loginController.register()
                performSegue(withIdentifier: LoginConstants.segueIdentifier, sender: nil)
                UserDefaults.standard.set(true, forKey: LoginConstants.userDefaultKey)
            }
        }
    }
    
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller!")
            return false
        }
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            self.user = firebaseUser
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }
    // Register button
    @IBAction func registerAction(_ sender: UIButton) {
        guard let username = userField.text, let password = passwordField.text else { return }
        let informationComplete: Bool = userField.text != "" && passwordField.text != ""
        if informationComplete {
         let loginController = LoginController(username: username, password: password)
            if loginController.register() {
                userField.text = ""
                passwordField.text = ""
                performSegue(withIdentifier: LoginConstants.segueIdentifier, sender: nil)
                UserDefaults.standard.set(true, forKey: LoginConstants.userDefaultKey)
            } else {
                displayLoginError(error: LoginConstants.errorRegisterUserExists)
            }
        } else {
            displayLoginError(error: LoginConstants.errorRegisterEmptyField)
        }
    }
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    private func verifyUserAuthenticated() {
        if LoginController.verifyUserAuthenticated() {
            performSegue(withIdentifier: LoginConstants.segueIdentifier, sender: nil)
        }
    }
    //MARK: Formatting
    private func viewControllerSetUp() {
        //gesture setup
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        //colors and formatting
        setBackgroundColor(self.view)
        setBackgroundColor(buttonsView)
        formatButtons(loginButton)
        formatButtons(registerButton)
        //delegates
        userField.delegate = self
        passwordField.delegate = self
        //notifications
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setBackgroundColor (_ view: UIView) {
        view.backgroundColor = GeneralConstants.nasaBlue
    }
    
    private func formatButtons(_ view: UIView) {
        view.backgroundColor = LoginConstants.buttonColor
        loginButton.setTitle("Sign in with Google", for: .normal)
        view.layer.borderColor = LoginConstants.buttonBorderColor.cgColor
        let icon = UIImageView()
        icon.image = UIImage(named: "google-icon")
        self.view.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
        icon.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor, constant: 2).isActive = true
        icon.heightAnchor.constraint(equalTo: loginButton.heightAnchor, multiplier: 0.90).isActive = true
        icon.widthAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
    }
    
    //MARK: Keyboard Behaviour
    @IBAction func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
            var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)

            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height + 20
            scrollView.contentInset = contentInset
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
}

//MARK: Extension - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.userField:
            self.passwordField.becomeFirstResponder()
        default:
            self.passwordField.resignFirstResponder()
      }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideLoginError()
    }
}

extension LoginViewController {
    func displayLoginError(error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
        UIView.animate(withDuration: 0.5) {
            self.errorLabel.alpha = 1
        }
    }
    func hideLoginError() {
        UIView.animate(withDuration: 0.5) {
            self.errorLabel.alpha = 0
            self.errorLabel.isHidden = true
        }
        self.errorLabel.text = ""
    }
}
