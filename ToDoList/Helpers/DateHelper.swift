//
//  DateHelper.swift
//  ToDoList
//
//  Created by Евгений Клюенков on 03.03.2021.
//

import UIKit


class DateHelper{
    
    class func toDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
}
