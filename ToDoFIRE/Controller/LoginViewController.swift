//
//  ViewController.swift
//  ToDoFIRE
//
//  Created by Александр Касьянов on 11.01.2022.
//

import UIKit
import Foundation
import Firebase

class LoginViewController: UIViewController {
    
    let segueIdentifier = "tasksSegue"
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginTapped(_ sender: UIButton) {
        //проверяем состояние текстовых полей аутентификации
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        }
    }
    
    //регистрация нового пользователя
    @IBAction func registerTapped(_ sender: UIButton) {
        //поскольку регистрация будет происходить не на отдельном экране, а в той же форме,
        //проверяем состояние текстовых полей регистрации
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (user, error) in
            guard error == nil, user != nil else {
                print(error!.localizedDescription)
                return
            }
            
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        //наcтройка скроллинга экрана при ввода данных с экранной клавиатуры
        //наблюдатель за тем, что клавиатура появилась
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        //наблюдатель за тем, что клавиатура скрылась
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        //предварительно скрываем warnLabel
        warnLabel.alpha = 0
        //проверяем, изменился ли пользователь и его данные
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //очищаем данные из текстовых строк после выхода из аккаунта
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    @objc func kbDidShow(notification: Notification) {
        //достаём словарь userinfo из notification
        guard let userInfo = notification.userInfo else {return}
        //получаем размер клавиатуры
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //получаем высоту клавиатуры
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: (self.view.bounds.size.height + kbFrameSize.height))
        //настройка индикатора скролла
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
    }

    @objc func kbDidHide(notification: Notification) {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    //текст warning label
    func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: { [weak self] in
            self?.warnLabel.alpha = 1
        }) { [weak self] complete in
            self?.warnLabel.alpha = 0
        }
    }


}

