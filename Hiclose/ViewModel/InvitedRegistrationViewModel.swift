//
//  InvitedRegistrationViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/18.
//

import UIKit

protocol FormViewModelDelegate {
    func updateForm()
}

struct InviteRegistrationViewModel {
    var inviteCode: String?
    
    var formIsValid: Bool {
        return inviteCode?.isEmpty == false
    }
    
    var buttonIsEnabled: Bool {
        return formIsValid ? true : false
    }
}
