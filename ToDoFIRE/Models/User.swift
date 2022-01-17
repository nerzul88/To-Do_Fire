//
//  User.swift
//  ToDoFIRE
//
//  Created by Александр Касьянов on 17.01.2022.
//

import Foundation
import Firebase

struct Users {
    
    let uid: String
    let email: String
    //инициализатор для извлечения id и email для возможности локальной работы
    init(user: User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
