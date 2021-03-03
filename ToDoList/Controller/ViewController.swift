//
//  ViewController.swift
//  ToDoList
//
//  Created by Евгений Клюенков on 09.01.2021.
//

import UIKit

class ViewController: UITableViewController {
    var tasksStoreManager = TaskStoreManager()
    var tasks : [Tasks] = []
    let addDialog  = UIAlertController(title: "Добавить дело", message: "Введите новое дело", preferredStyle: .alert) // Окно alert, куда вводим новые дела.
    let editDialog  = UIAlertController(title: "Редактировать дело", message: "Введите новый текст", preferredStyle: .alert) // Окно alert для редактирования дела
    let deleteDialog = UIAlertController(title: "Удалить все задачи", message: "Вы уверены?", preferredStyle: .alert)
    let emptyDialog = UIAlertController(title: "У вас нет ни одной задачи", message: nil, preferredStyle: .alert)
    
    var selectingRowForEditing : IndexPath? //Переменная сохраняющая номер ячейки которую мы редактируем
    var selectingRowEditingSuccess : ((Bool) -> Void)? = nil //Функция вызываемая когда измененную ячейку нужно скрыть
    let date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = tasksStoreManager.obtainTasks()
        setupAlertController()
        self.title = "Список дел"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapOnAddButton)) // Создание в ручную кнопки, при нажатии которой появляется окно alert
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapOnDeleteButton))
        
        tableView.tableFooterView = UIView() // Метод убирающий лишние полоски в TableView
        
    }
    
    func setupAlertController() {
        addDialog.addTextField(configurationHandler: nil) // Добавление строки TextField в окно Alert
        addDialog.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil)) //Добавление кнопки "Отмена" в окно Alert
        addDialog.addAction(UIAlertAction(title: "Добавить", style: .default, handler: addNewItem)) //Добавление кнопки "Добавить" в окно Alert и выполнение какого-либо действия при ее нажатии (handler)
        editDialog.addTextField(configurationHandler: nil)
        editDialog.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil))
        editDialog.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: editItem))
        deleteDialog.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        deleteDialog.addAction(UIAlertAction(title: "Удалить", style: .default, handler: deleteAllTaskFromCoreData))
        emptyDialog.addAction(UIAlertAction(title: "Добавить задачу", style: .default, handler: didTapOnAddButton))
    }
    
    func addNewItem(action: UIAlertAction) { //Функция для добавления нового дела при нажатии на "Добавить" в alertAction
        guard let title = addDialog.textFields?[0].text, title != "" else { return }
        let newTask = tasksStoreManager.addNewTask(with: title)
        tasks.append(newTask)
        let path = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [path], with: .fade)
    }
    
    @objc func didTapOnAddButton(action: UIAlertAction) {
        self.present(addDialog, animated: true) //Открывается окошко allert
        addDialog.textFields?[0].text = "" //Удаляется текст в поле, после предыдущей установки дела.
    }
    
    @objc func didTapOnDeleteButton() {
        if tasks != [] {
            self.present(deleteDialog, animated: true, completion: nil)
        } else {
            self.present(emptyDialog, animated: true, completion: nil)
        }
        
    }
    
    
    //Функция отвечающая за количество секций в нашем TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Функция отвечающая за количество элементов в секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //Функция отвечающая за внешний вид нашей ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todo_cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if let date = task.date {
            cell.detailTextLabel?.text = DateHelper.toDay(date: date)
        } else {
            cell.detailTextLabel?.text = "Дата создания неизвестна"
        }
        let accessoryType : UITableViewCell.AccessoryType = task.isCompleted ? .checkmark : .none
        cell.accessoryType = accessoryType//Способ отображения справа в ячейке что-нибудь, например галочка.
        return cell
    }
    
    
    //Функция для выбора элемента в секции
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.isCompleted = !task.isCompleted //Меняем значения (Выполнено/Невыполнено)
        tableView.reloadRows(at: [indexPath], with: .fade) //Обновление ячеек для перерисовка значения
    }
    //Функция для удаления дела в списке дел, при свайпе справа на лево
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Удаление
        tasksStoreManager.deleteTask(with: tasks.remove(at: indexPath.row))
        tableView.deleteRows(at: [indexPath], with: .fade) //Передаем ячейке, что элемент удален
    }
    //Функция для редактирования дела в списке дел, при свайпе слева на право
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        ////Какое-то действие вызвваемое при таком свайпе
        let action = UIContextualAction(style: .normal, title: "Изменить") { (action: UIContextualAction, view: UIView, success: @escaping (Bool) -> Void) in
            
            self.selectingRowForEditing = indexPath //Сохраняем номер выбранного элемента в ячейке
            self.selectingRowEditingSuccess = success //Сохранение функции success, чтобы ее можно было вызвать потом
            self.editDialog.textFields?[0].text = self.tasks[indexPath.row].title //Показывем в диалоге изменения текст текущего дела
            self.present(self.editDialog, animated: true) //Показывем editDialog при нажатии кнопки изменить
            //Действие при нажатии "Редактировать"
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //Функция для изменения элемента в ячейке
    func editItem(action: UIAlertAction) {
        let title = editDialog.textFields?[0].text
        if let title = title{
            tasksStoreManager.editTask(name: tasks[(selectingRowForEditing?.row)!], text: title)
        }
        selectingRowEditingSuccess?(true) //Операция изменения завершилась, можно кнопку изменить прятать
        tableView.reloadRows(at: [selectingRowForEditing!], with: .fade)//Перезагрузка измененных ячеек
    }
    
    func deleteAllTaskFromCoreData(action: UIAlertAction) {
        for obj in tasks {
            tasksStoreManager.deleteTask(with: obj)
            tasks.removeAll()
        }
        tableView.reloadData()
    }
}

