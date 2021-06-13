//
//  AuthenticationViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/01.
//

import UIKit

protocol FormViewModel {
    func updateForm()
}

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}

struct LoginViewModel: AuthenticationViewModel {
    
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
}

struct RegistrationViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    var profileImage: UIImage?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false &&
            fullname?.isEmpty == false && username?.isEmpty == false && profileImage != nil
    }

    var buttonBackgroundColor: UIColor {
        return formIsValid ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
}
