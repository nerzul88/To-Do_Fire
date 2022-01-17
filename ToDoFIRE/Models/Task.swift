//
//  Task.swift
//  ToDoFIRE
//
//  Created by Александр Касьянов on 17.01.2022.
//

import Foundation
import Firebase

let databaseUrl: String = "https://todofire-1d855-default-rtdb.europe-west1.firebasedatabase.app/"

struct Task {
    let title: String
    let userId: String
    let ref: DatabaseReference?
    //var ref: DatabaseReference!
    //var ref = Database.database(url: databaseUrl).reference()
    var completed: Bool = false
    //инициализатор для локального создания объекта
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    //инициализатор для извлечения объекта из базы данных
    init(snapshot: DataSnapshot) {
        //snapshot - "срез" данных на текущий момент в формате JSON
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        ["title": title, "userId": userId, "completed": completed]
    }
}
