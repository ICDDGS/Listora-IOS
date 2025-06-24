//
//  ListViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 02/06/25.
//

import UIKit
import CoreData

class ListViewController: UIViewController {

    var shoppingLists: [ShoppingListEntity] = []
    
    let primaryColor = UIColor(named: "primary")
    let secondaryColor = UIColor(named: "secondary")
    let backgroundColor = UIColor(named: "background")
    let onPrimaryColor = UIColor(named: "onPrimary")

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addListButton: UIButton!

    


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "background")
        navigationController?.navigationBar.barTintColor = UIColor(named: "primary")
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "onPrimary") ?? .white]
            
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "background")

        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
        
        addListButton.backgroundColor = secondaryColor
        addListButton.setTitleColor(.white, for: .normal)
        addListButton.layer.cornerRadius = 12



        loadLists()
    }


    // MARK: - Cargar desde el DataManager

    func loadLists() {
        shoppingLists = ShoppingListDataManager.shared.fetchLists()
        tableView.reloadData()
    }

    // MARK: - Agregar lista

    @IBAction func addListAction(_ sender: Any) {
        let alert = UIAlertController(title: "Nueva Lista", message: nil, preferredStyle: .alert)
        
        let titleFont = [NSAttributedString.Key.foregroundColor: UIColor(named: "primary") ?? .blue]
            let attributedTitle = NSAttributedString(string: "Nueva Lista", attributes: titleFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")

        alert.addTextField { textField in
            textField.placeholder = "Nombre de la lista"
        }

        alert.addTextField { textField in
            textField.placeholder = "Presupuesto"
            textField.keyboardType = .decimalPad
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 120),
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 250),
            datePicker.heightAnchor.constraint(equalToConstant: 120)
        ])

        let height = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 350)
        alert.view.addConstraint(height)

        let addAction = UIAlertAction(title: "Agregar", style: .default) { _ in
            guard
                let name = alert.textFields?[0].text, !name.isEmpty,
                let budgetText = alert.textFields?[1].text,
                let budget = Double(budgetText)
            else {
                self.showToast(message: "Faltan datos para crear la lista")
                return
            }

            ShoppingListDataManager.shared.createList(name: name, budget: budget, dete: datePicker.date)
            self.loadLists()
            self.showToast(message: "Lista creada con éxito")

        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    func showEditAlert(for list: ShoppingListEntity) {
        let alert = UIAlertController(title: "Editar Lista", message: nil, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Nombre de la lista"
            textField.text = list.name
        }

        alert.addTextField { textField in
            textField.placeholder = "Presupuesto"
            textField.keyboardType = .decimalPad
            textField.text = String(format: "%.2f", list.budget)
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = list.date ?? Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        alert.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 120),
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 250),
            datePicker.heightAnchor.constraint(equalToConstant: 120)
        ])

        let height = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 350)
        alert.view.addConstraint(height)

        let saveAction = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard
                let name = alert.textFields?[0].text, !name.isEmpty,
                let budgetText = alert.textFields?[1].text,
                let budget = Double(budgetText)
            else {
                self.showToast(message: "Faltan datos para editar la lista")
                return
            }

            ShoppingListDataManager.shared.updateList(list, name: name, budget: budget, date: datePicker.date)
            self.loadLists()
            self.showToast(message: "Lista actualizada")

        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

}

// MARK: - TableView Delegates

extension ListViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shoppingLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // una celda por sección
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12 // espacio entre celdas
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = shoppingLists[indexPath.section]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let ingredientsVC = storyboard.instantiateViewController(withIdentifier: "IngredientsViewController") as? IngredientsViewController {
            ingredientsVC.shoppingList = selectedList
            navigationController?.pushViewController(ingredientsVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let list = shoppingLists[indexPath.section]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, completion in
            ShoppingListDataManager.shared.deleteList(list)
            self.loadLists()
            self.showToast(message: "Lista eliminada")
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Editar") { _, _, completion in
            self.showEditAlert(for: list)
            completion(true)
        }

        editAction.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        let list = shoppingLists[indexPath.section]
        cell.nameLabel.text = list.name

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        cell.dateLabel.text = list.date != nil ? formatter.string(from: list.date!) : "-"
        cell.presupuestoLabel.text = String(format: "$%.2f", list.budget)

        return cell
    }


}
