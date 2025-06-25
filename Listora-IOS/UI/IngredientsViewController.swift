//
//  IngredientsViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 02/06/25.
//

import UIKit
import CoreData

class IngredientsViewController: UIViewController {

    var shoppingList: ShoppingListEntity?
    var ingredients: [IngredientEntity] = []
    let unidades = ["kg", "g", "L", "ml", "pza", "taza"]
    var selectedUnidad = "kg"
    var unidadField: UITextField?

    @IBOutlet weak var labelBudget: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = shoppingList?.name ?? "Ingredientes"
        view.backgroundColor = UIColor(named: "background")
                
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = UIColor(named: "background") ?? .white

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance



        tableView.delegate = self
        tableView.dataSource = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addIngredientTapped)
        )


        fetchIngredients()
    }
    @IBAction func irAResumenTapped(_ sender: UIButton) {
        verificarYMostrarResumen()
    }

    
    @objc func goToResumen() {
        let totalIngredientes = ingredients.count
        let completados = ingredients.filter { $0.isPurchased }.count

        if completados < totalIngredientes {
            let alerta = UIAlertController(
                title: "Lista incompleta",
                message: "Aún hay ingredientes sin marcar como comprados. ¿Deseas continuar?",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            alerta.addAction(UIAlertAction(title: "Sí, continuar", style: .default) { _ in
                self.mostrarResumen()
            })
            present(alerta, animated: true)
        } else {
            mostrarResumen()
        }
    }
    

    func fetchIngredients() {
        guard let list = shoppingList,
              let set = list.ingredients as? Set<IngredientEntity> else {
            return
        }
        ingredients = Array(set).sorted { $0.name ?? "" < $1.name ?? "" }
        tableView.reloadData()
        updateBudgetLabel()
    }

    func createIngredient(name: String, quantity: Double, unit: String, price: Double, isPurchased: Bool = false) {
        guard let list = shoppingList else { return }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let ingredient = IngredientEntity(context: context)
        ingredient.name = name
        ingredient.quantity = quantity
        ingredient.unit = unit
        ingredient.price = price
        ingredient.isPurchased = isPurchased
        ingredient.list = list

        do {
            try context.save()
            print("Ingrediente guardado")
            fetchIngredients()
        } catch {
            print("Error al guardar ingrediente: \(error)")
        }
    }

    @objc func addIngredientTapped() {
        let alert = UIAlertController(title: "Nuevo ingrediente", message: nil, preferredStyle: .alert)

        // Campo 0: Nombre
        alert.addTextField { $0.placeholder = "Nombre" }

        // Campo 1: Cantidad
        alert.addTextField {
            $0.placeholder = "Cantidad"
            $0.keyboardType = .decimalPad
        }

        // Campo 2: Unidad (con PickerView)
        alert.addTextField { field in
            field.placeholder = "Unidad"
            field.text = self.selectedUnidad

            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            picker.selectRow(0, inComponent: 0, animated: false)

            field.inputView = picker
            self.unidadField = field
        }

        // Campo 3: Precio
        alert.addTextField {
            $0.placeholder = "Precio"
            $0.keyboardType = .decimalPad
        }

        let guardar = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard
                let name = alert.textFields?[0].text, !name.isEmpty,
                let cantidadText = alert.textFields?[1].text, let cantidad = Double(cantidadText),
                let unidadText = alert.textFields?[2].text, !unidadText.isEmpty,
                let precioText = alert.textFields?[3].text, let precio = Double(precioText)
            else {
                self.showToast(message: "Datos invalidos")
                return
            }

            self.createIngredient(name: name, quantity: cantidad, unit: unidadText, price: precio)
            self.showToast(message: "Ingrediente agregado")

        }

        alert.addAction(guardar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        present(alert, animated: true)
    }


    func updateBudgetLabel() {
        guard let list = shoppingList else {
            labelBudget.isHidden = true
            return
        }

        let presupuesto = list.budget
        let totalGastado = ingredients.reduce(0) { $0 + $1.price }

        if presupuesto == 0 {
            labelBudget.isHidden = true
        } else {
            labelBudget.isHidden = false
            let restante = presupuesto - totalGastado

            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "es_MX")

            labelBudget.text = "Presupuesto restante: \(formatter.string(from: NSNumber(value: restante)) ?? "$0.00")"

            labelBudget.textColor = restante < 0 ? .systemRed : .black

        }
    }
    
    func showEditIngredientAlert(ingredient: IngredientEntity) {
        let alert = UIAlertController(title: "Editar ingrediente", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.text = ingredient.name }

        alert.addTextField {
            $0.text = String(ingredient.quantity)
            $0.keyboardType = .decimalPad
        }

        // Campo con PickerView para unidad
        alert.addTextField { field in
            field.placeholder = "Unidad"
            field.text = ingredient.unit ?? "kg"

            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self

            if let currentIndex = self.unidades.firstIndex(of: ingredient.unit ?? "kg") {
                picker.selectRow(currentIndex, inComponent: 0, animated: false)
                self.selectedUnidad = self.unidades[currentIndex]
            }

            field.inputView = picker
            self.unidadField = field
        }

        alert.addTextField {
            $0.text = String(ingredient.price)
            $0.keyboardType = .decimalPad
        }

        let guardar = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard
                let name = alert.textFields?[0].text, !name.isEmpty,
                let cantidadText = alert.textFields?[1].text, let cantidad = Double(cantidadText),
                let unidadText = alert.textFields?[2].text, !unidadText.isEmpty,
                let precioText = alert.textFields?[3].text, let precio = Double(precioText)
            else {
                self.showToast(message: "Datos Invalidos")
                return
            }

            ingredient.name = name
            ingredient.quantity = cantidad
            ingredient.unit = unidadText
            ingredient.price = precio
            self.showToast(message: "Ingrediente actualizado")


            do {
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
                self.fetchIngredients()
            } catch {
                self.showToast(message: "Error al editar ingrediente")

            }
        }

        alert.addAction(guardar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        present(alert, animated: true)
    }
    func verificarYMostrarResumen() {
        let totalIngredientes = ingredients.count
        let completados = ingredients.filter { $0.isPurchased }.count

        if completados < totalIngredientes {
            let alerta = UIAlertController(
                title: "Lista incompleta",
                message: "Aún hay ingredientes sin marcar como comprados. ¿Deseas continuar?",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            alerta.addAction(UIAlertAction(title: "Sí, continuar", style: .default) { _ in
                self.mostrarResumen()
            })
            present(alerta, animated: true)
        } else {
            mostrarResumen()
        }
    }
    func mostrarResumen() {
        guard let resumenVC = storyboard?.instantiateViewController(withIdentifier: "ResumenViewController") as? ResumenViewController else {
            return
        }
        resumenVC.compras = ingredients.filter { $0.isPurchased }
        resumenVC.total = ingredients.reduce(0) { $0 + $1.price }
        navigationController?.pushViewController(resumenVC, animated: true)
    }




}

// MARK: - TableView
extension IngredientsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredient = ingredients[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "IngredientCell")
        cell.textLabel?.text = "\(ingredient.name ?? "") - \(ingredient.quantity) \(ingredient.unit ?? "")"
        cell.detailTextLabel?.text = String(format: "$%.2f", ingredient.price)
        cell.accessoryType = ingredient.isPurchased ? .checkmark : .none

        cell.detailTextLabel?.textColor = .black
        cell.textLabel?.textColor = .black
        cell.backgroundColor = UIColor(named: "background")

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ingredient = ingredients[indexPath.row]
        ingredient.isPurchased.toggle()
        
        if ingredient.isPurchased {
            ingredient.purchasedDate = Date()
        } else {
            ingredient.purchasedDate = nil
        }

        do {
            try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
            fetchIngredients()
        } catch {
            print("Error al actualizar estado de compra: \(error)")
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ingredient = ingredients[indexPath.row]

        // Acción de eliminar
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, completion in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(ingredient)
            do {
                try context.save()
                self.fetchIngredients()
                completion(true)
                self.showToast(message: "Ingrediente eliminado")
            } catch {
                print("Error al eliminar ingrediente: \(error)")
                self.showToast(message: "Error al eliminar")
                completion(false)
            }
        }

        // Acción de editar
        let editAction = UIContextualAction(style: .normal, title: "Editar") { _, _, completion in
            self.showEditIngredientAlert(ingredient: ingredient)
            completion(true)
        }

        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    
}

// MARK: - PickerView
extension IngredientsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unidades.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unidades[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnidad = unidades[row]
        unidadField?.text = selectedUnidad
    }
}





