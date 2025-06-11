//
//  RecipeDetailViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    
    @IBOutlet weak var tableView: UITableView!
    var recipe: RecipeEntity!
    var ingredients: [RecipeIngEntity] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = recipe.name ?? "Detalle"
        nameLabel.text = recipe.name
        categoryLabel.text = "Categoría: \(recipe.descript ?? "Sin categoría")"

        tableView.delegate = self
        tableView.dataSource = self
        fetchIngredients()
    }


    func fetchIngredients() {
        if let ingSet = recipe.ingredient as? Set<RecipeIngEntity> {
            ingredients = Array(ingSet).sorted(by: { $0.name ?? "" < $1.name ?? "" })
            tableView.reloadData()
        }
    }

    @IBAction func addIngredientTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nuevo Ingrediente", message: "Agrega nombre, cantidad y unidad", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Nombre" }
        alert.addTextField {
            $0.placeholder = "Cantidad"
            $0.keyboardType = .decimalPad
        }
        alert.addTextField { $0.placeholder = "Unidad" }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let qtyText = alert.textFields?[1].text,
                  let quantity = Double(qtyText),
                  let unit = alert.textFields?[2].text else { return }

            let newIng = RecipeIngEntity(context: self.context)
            newIng.name = name
            newIng.quantity = quantity
            newIng.unit = unit
            newIng.recipe = self.recipe

            do {
                try self.context.save()
                self.fetchIngredients()
            } catch {
                print("❌ Error al guardar ingrediente: \(error)")
            }
        }))
        present(alert, animated: true)
    }
}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ing = ingredients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell", for: indexPath)
        cell.textLabel?.text = "\(ing.name ?? "") - \(ing.quantity.clean) \(ing.unit ?? "")"
        return cell
    }

    // Deslizar para eliminar
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ingToDelete = ingredients[indexPath.row]
            context.delete(ingToDelete)
            do {
                try context.save()
                fetchIngredients()
            } catch {
                print("❌ Error al eliminar ingrediente: \(error)")
            }
        }
    }
}

// Para mostrar Double sin punto decimal innecesario
extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", self) :
            String(self)
    }
}
