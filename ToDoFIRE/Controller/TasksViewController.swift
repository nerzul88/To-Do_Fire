//
//  TasksViewController.swift
//  ToDoFIRE
//
//  Created by Александр Касьянов on 11.01.2022.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: Users!
    var ref: DatabaseReference!
    //var ref = Database.database(url: databaseUrl).reference()
    var tasks = Array<Task>()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        //форма для добавления задач через alert controller
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        //создаём кнопку создания задачи
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            //проверяем, есть ли текстовое поле
            guard let textField = alertController.textFields?.first, textField.text != "" else {return}
            //создаём задачу
            //guard let textFieldText = textField.text else {return}
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            //указываем, где хранится задача на сервере (создаём task reference)
            let tasksRef = self?.ref.child(task.title.lowercased())
            //размещаем задачу на сервере
            tasksRef?.setValue(task.convertToDictionary())
        }
        //создаём кнопку отмены создания задачи
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //добавляем кнопки в alert controller
        alertController.addAction(save)
        alertController.addAction(cancel)
        //отображаем alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = taskTitle
        //обновляем ячейку
        toggleCompletion(cell, isCompleted: isCompleted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //функционал для удаления ячеек
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    //добавление кнопки удаления
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    //выполнение кода при нажатии пальцем на соответствующую ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        //обновляем ячейку
        toggleCompletion(cell, isCompleted: isCompleted)
        //передаём изменения в базу данных
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    //метод для обновления ячейки
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    
    //получаем данные из базы через наблюдателя
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //массив для исключения дублирования данных
        var _tasks = Array<Task>()
        //создаём наблюдателя
        ref.observe(.value) { [weak self] (snapshot) in
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
    }
    //удаляем предупреждения о недоступности данных после выхода из аккаунта
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //помещаем currentUser в user
        guard let currentUser = Auth.auth().currentUser else {return}
        user = Users(user: currentUser)
        //добираемся до задач
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
       
}
