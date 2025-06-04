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

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mis listas"

        tableView.delegate = self
        tableView.dataSource = self

        // Registrar celda personalizada
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")

        fetchShoppingLists()
    }

    // MARK: - Core Data

    func fetchShoppingLists() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()

        do {
            shoppingLists = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error al cargar listas: \(error)")
        }
    }

    func saveShoppingList(name: String, budget: Double, date: Date) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let newList = ShoppingListEntity(context: context)
        newList.name = name
        newList.budget = budget
        newList.date = date

        do {
            try context.save()
            print("Lista guardada")
            fetchShoppingLists()
        } catch {
            print("Error al guardar: \(error)")
        }
    }

    // MARK: - Crear lista

    @IBAction func addListAction(_ sender: Any) {
        let alert = UIAlertController(title: "Nueva Lista", message: nil, preferredStyle: .alert)

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
                return
            }

            self.saveShoppingList(name: name, budget: budget, date: datePicker.date)
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegates

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = shoppingLists[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailVC.shoppingList = selectedList
            navigationController?.pushViewController(detailVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        let list = shoppingLists[indexPath.row]
        cell.nameLabel.text = list.name

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let date = list.date {
            cell.dateLabel.text = formatter.string(from: date)
        } else {
            cell.dateLabel.text = "-"
        }

        cell.presupuestoLabel.text = String(format: "$%.2f", list.budget)

        return cell
    }
}
