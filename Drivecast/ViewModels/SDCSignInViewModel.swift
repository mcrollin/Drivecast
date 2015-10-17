//
//  SDCSignInViewModel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct SDCSignInViewModel {
    
    // Observables
    let emailText           = MutableProperty<String>("")
    let passwordText        = MutableProperty<String>("")
    let emailTextEnabled    = MutableProperty<Bool>(false)
    let passwordTextEnabled = MutableProperty<Bool>(false)
    let signInButtonEnabled = MutableProperty<Bool>(false)
    let signInFormIsVisible = MutableProperty<Bool>(false)
    let userIsAuthenticated = MutableProperty<Bool>(SDCUser.authenticatedUser != nil)
    
    // Action
    private(set) var signInAction: Action<AnyObject?, Bool, NoError>? = nil
    
    init() {
        enableSignIn()
        initializeSignInAction()
    }
    
    func checkAuthentication() {
        if let user = SDCUser.authenticatedUser {
            SDCSafecastAPI.retrieveUser(user.id, email: user.email) { result in
                switch result {
                case .Success(let user):
                    SDCUser.authenticatedUser = user
                case .Failure(let error):
                    log(error)
                }
                
                self.userIsAuthenticated.value = true
            }
        } else {
            self.signInButtonEnabled.value  = true
            self.emailTextEnabled.value     = true
            self.passwordTextEnabled.value  = true
            self.signInFormIsVisible.value  = true
        }
    }
    
    private func signIn(email: String, password: String) {
        signInButtonEnabled.value   = false
        signInFormIsVisible.value   = false
        emailTextEnabled.value      = false
        passwordTextEnabled.value   = false
        
        SDCSafecastAPI.signInUser(email, password: password) { result in
            switch result {
            case .Success(let user):
                log(user)
                
                SDCUser.authenticatedUser       = user
                self.userIsAuthenticated.value  = true
            case .Failure(let error):
                // @todo: Need to prompt a message to the user (reg exp to find the right error)
                log(error)
                
                self.signInButtonEnabled.value  = true
                self.emailTextEnabled.value     = true
                self.passwordTextEnabled.value  = true
                self.signInFormIsVisible.value  = true
            }
        }
    }
    
    // Initializes the sign in button action
    private mutating func initializeSignInAction() {
        signInAction = Action(enabledIf:signInButtonEnabled) { _ in
            
            return SignalProducer { sink, _ in
                let email       = self.emailText.value
                let password    = self.passwordText.value
                
                self.signIn(email, password: password)
                
                sendNext(sink, true)
                sendCompleted(sink)
            }
        }
    }
    
    // Validates that the email and passwords are valid
    private func validateCredentials(email: String, password: String) -> Bool {
        if email.characters.count < 3
            || !email.containsString("@")
            || !email.containsString(".")
            || email.characters.last == "@"
            || email.characters.last == "."
            || email.characters.first == "@"
            || email.characters.first == "."
            || password.characters.count < 1 {
                return false
        }
        
        return true
    }
    
    // Enables the sign in button when email and password meets requirements
    private func enableSignIn() {
        let emailSignalProducer     = emailText.producer
        let passwordSignalProducer  = passwordText.producer
        
        signInButtonEnabled <~ combineLatest(emailSignalProducer, passwordSignalProducer)
            .map { email, password in
                return self.validateCredentials(email, password: password)
            }
    }
}