//
//  RecipeListViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//

// RecipeListViewController.swift

import UIKit
import CoreData

class RecipeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var recipes: [RecipeEntity] = []
    let pickerOptions = ["Desayuno", "Comida", "Cena"]
    var selectedPickerValue = "Desayuno"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "background") ?? .systemGroupedBackground

        let nib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RecipeTableViewCell")

        loadLists()
    }

    func loadLists() {
        recipes = RecipesListDataManager.shared.fetchLists()
        tableView.reloadData()
    }

    @IBAction func addRecipe(_ sender: Any) {
        showRecipeAlert()
    }

    private func showRecipeAlert() {
        let alert = UIAlertController(title: "Nueva Receta", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.placeholder = "Nombre de la receta" }

        // Ajustamos la altura del diálogo
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1, constant: 310)
        alert.view.addConstraint(height)

        // === Etiqueta: "Seleccionar categoría" ===
        let categoryLabel = UILabel()
        categoryLabel.text = "Seleccionar categoría"
        categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        categoryLabel.textColor = .gray
        categoryLabel.textAlignment = .center
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(categoryLabel)

        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 120),
            categoryLabel.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
        ])

        // === PickerView ===
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        alert.view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
            pickerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Acciones
        let saveAction = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else {
                self.showToast(message: "Falta el nombre de la receta")
                return
            }

            RecipesListDataManager.shared.createList(name: name, descript: self.selectedPickerValue)
            self.loadLists()
            self.showToast(message: "Receta guardada")
        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }


    func showToast(message: String) {
        let toast = UILabel(frame: CGRect(x: 40, y: self.view.frame.size.height - 100,
                                          width: self.view.frame.size.width - 80, height: 35))
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toast.textColor = .white
        toast.textAlignment = .center
        toast.font = UIFont.systemFont(ofSize: 14.0)
        toast.text = message
        toast.alpha = 1.0
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        view.addSubview(toast)
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
            toast.alpha = 0.0
        }) { _ in toast.removeFromSuperview() }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeDetail",
           let destinationVC = segue.destination as? RecipeDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.recipe = recipes[indexPath.section]
        }
    }
    func showEditRecipeAlert(for recipe: RecipeEntity) {
        let alert = UIAlertController(title: "Editar Receta", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Nombre de la receta"
            textField.text = recipe.name
        }

        let height = NSLayoutConstraint(item: alert.view!, attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1, constant: 310)
        alert.view.addConstraint(height)

        let categoryLabel = UILabel()
        categoryLabel.text = "Seleccionar categoría"
        categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        categoryLabel.textColor = .gray
        categoryLabel.textAlignment = .center
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(categoryLabel)

        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 120),
            categoryLabel.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
        ])

        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self

        if let index = pickerOptions.firstIndex(of: recipe.descript ?? "") {
            pickerView.selectRow(index, inComponent: 0, animated: false)
            selectedPickerValue = pickerOptions[index]
        }

        alert.view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
            pickerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else {
                self.showToast(message: "Falta el nombre de la receta")
                return
            }

            recipe.name = name
            recipe.descript = self.selectedPickerValue

            do {
                try recipe.managedObjectContext?.save()
                self.loadLists()
                self.showToast(message: "Receta actualizada")
            } catch {
                print("Error al guardar edición de receta: \(error)")
            }
        })

        present(alert, animated: true)
    }

}

// MARK: - UIPickerView

extension RecipeListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerValue = pickerOptions[row]
    }
}

// MARK: - UITableView

extension RecipeListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // una celda por sección
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12 // separación entre celdas
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.section]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
            detailVC.recipe = selectedRecipe
            navigationController?.pushViewController(detailVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let recipe = recipes[indexPath.section]

        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, completion in
            RecipesListDataManager.shared.deleteList(recipe)
            self.loadLists()
            self.showToast(message: "Receta eliminada")
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Editar") { _, _, completion in
            self.showEditRecipeAlert(for: recipe)
            completion(true)
        }
        editAction.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as? RecipeTableViewCell else {
            return UITableViewCell()
        }

        let recipe = recipes[indexPath.section]
        cell.nameLabel.text = recipe.name
        cell.descLabel.text = recipe.descript

        return cell
    }
}

