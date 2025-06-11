//
//  RecipeListViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//

import UIKit
import CoreData

class RecipeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var recipes: [RecipeEntity] = []
    let pickerOptions = ["Desayuno", "Comida", "Cena"]
    var selectedPickerValue = "Desayuno"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mis Recetas"

        tableView.delegate = self
        tableView.dataSource = self

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

        // Campo de nombre
        alert.addTextField { $0.placeholder = "Nombre de la receta" }

        // Altura del UIAlertController
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1, constant: 270)
        alert.view.addConstraint(height)

        // Picker de categoría
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)

        alert.view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
            pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60),
            pickerView.heightAnchor.constraint(equalToConstant: 120)
        ])

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
            destinationVC.recipe = recipes[indexPath.row]
        }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as? RecipeTableViewCell else {
            return UITableViewCell()
        }

        let recipe = recipes[indexPath.row]
        cell.nameLabel.text = recipe.name
        cell.descLabel.text = recipe.descript
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let recipe = recipes[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, completion in
            RecipesListDataManager.shared.deleteList(recipe)
            self.loadLists()
            self.showToast(message: "Receta eliminada")
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
            detailVC.recipe = selectedRecipe
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }



}


