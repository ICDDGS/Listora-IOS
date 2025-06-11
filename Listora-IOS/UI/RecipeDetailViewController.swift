//
//  RecipeDetailViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController {
    var recipe: RecipeEntity!
    var ingredients: [RecipeIngEntity] = []
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    
    let nameLabel = UILabel()
    let categoryLabel = UILabel()
    let tableView = UITableView()
    let addButton = UIButton(type: .system)
    let preparationLabel = UILabel()
    
    let imageView = UIImageView()
    let addToListButton = UIButton(type: .system)
    let quantityLabel = UILabel()
    let minusButton = UIButton(type: .system)
    let quantityValueLabel = UILabel()
    let plusButton = UIButton(type: .system)

    var tableViewHeightConstraint: NSLayoutConstraint!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recipe.name ?? "Detalle"
        view.backgroundColor = .white
        addToListButton.addTarget(self, action: #selector(addToListTapped), for: .touchUpInside)

        
        setupViews()
        setupConstraints()
        fetchIngredients()
    }

    func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        preparationLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        quantityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        addToListButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(addToListButton)
        containerView.addSubview(quantityLabel)
        containerView.addSubview(minusButton)
        containerView.addSubview(quantityValueLabel)
        containerView.addSubview(plusButton)
        containerView.addSubview(tableView)
        containerView.addSubview(addButton)
        containerView.addSubview(preparationLabel)

        imageView.image = UIImage(systemName: "fork.knife")
        imageView.contentMode = .scaleAspectFit

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.text = recipe.name

        categoryLabel.font = .systemFont(ofSize: 16)
        categoryLabel.textColor = .gray
        categoryLabel.text = "Categoría: \(recipe.descript ?? "Sin categoría")"

        addToListButton.setTitle("Agregar a lista", for: .normal)
        addToListButton.backgroundColor = .systemBlue
        addToListButton.setTitleColor(.white, for: .normal)
        addToListButton.layer.cornerRadius = 6

        quantityLabel.text = "Cantidad"
        quantityLabel.font = .systemFont(ofSize: 16)

        minusButton.setTitle("-", for: .normal)
        minusButton.backgroundColor = .systemGray5
        minusButton.layer.cornerRadius = 6

        plusButton.setTitle("+", for: .normal)
        plusButton.backgroundColor = .systemGray5
        plusButton.layer.cornerRadius = 6

        quantityValueLabel.text = "1"
        quantityValueLabel.font = .systemFont(ofSize: 16)

        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeIngredientCell")
        tableView.delegate = self
        tableView.dataSource = self

        addButton.setTitle("Agregar Ingrediente", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 6
        addButton.addTarget(self, action: #selector(addIngredientTapped), for: .touchUpInside)

        preparationLabel.text = "Pasos de Preparación"
        preparationLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            addToListButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            addToListButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addToListButton.heightAnchor.constraint(equalToConstant: 32),

            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            quantityLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            minusButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            minusButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 16),
            minusButton.widthAnchor.constraint(equalToConstant: 40),
            minusButton.heightAnchor.constraint(equalToConstant: 30),

            quantityValueLabel.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            quantityValueLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 8),

            plusButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            plusButton.leadingAnchor.constraint(equalTo: quantityValueLabel.trailingAnchor, constant: 8),
            plusButton.widthAnchor.constraint(equalToConstant: 40),
            plusButton.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: addToListButton.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: addToListButton.trailingAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),

            preparationLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 24),
            preparationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            preparationLabel.trailingAnchor.constraint(equalTo: addToListButton.trailingAnchor),
            preparationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 44)
        tableViewHeightConstraint.isActive = true
    }


    func fetchIngredients() {
        if let ingSet = recipe.ingredient as? Set<RecipeIngEntity> {
            ingredients = Array(ingSet).sorted { $0.name ?? "" < $1.name ?? "" }
            tableView.reloadData()
            tableViewHeightConstraint.constant = CGFloat(ingredients.count) * 44.0
        }
    }

    @objc func addIngredientTapped() {
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

    func showEditIngredientAlert(ingredient: RecipeIngEntity) {
        let alert = UIAlertController(title: "Editar ingrediente", message: nil, preferredStyle: .alert)
        
        alert.addTextField { $0.text = ingredient.name }
        alert.addTextField {
            $0.text = String(ingredient.quantity)
            $0.keyboardType = .decimalPad
        }
        alert.addTextField { $0.text = ingredient.unit }
        
        let guardar = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard
                let name = alert.textFields?[0].text, !name.isEmpty,
                let cantidadText = alert.textFields?[1].text, let cantidad = Double(cantidadText),
                let unidadText = alert.textFields?[2].text, !unidadText.isEmpty
            else {
                return
            }
            
            ingredient.name = name
            ingredient.quantity = cantidad
            ingredient.unit = unidadText
            
            do {
                try self.context.save()
                self.fetchIngredients()
            } catch {
                print("❌ Error al editar ingrediente: \(error)")
            }
        }

        alert.addAction(guardar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    @objc func addToListTapped() {
        let fetchRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
        
        do {
            let lists = try context.fetch(fetchRequest)
            
            let alert = UIAlertController(title: "Selecciona una lista", message: nil, preferredStyle: .actionSheet)
            
            for list in lists {
                let action = UIAlertAction(title: list.name ?? "Lista", style: .default) { _ in
                    self.addIngredientsToList(list)
                }
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            present(alert, animated: true)
            
        } catch {
            print("❌ Error al obtener listas: \(error)")
        }
    }

    func addIngredientsToList(_ list: ShoppingListEntity) {
        guard let ingSet = recipe.ingredient as? Set<RecipeIngEntity>,
              let multiplier = Double(quantityValueLabel.text ?? "1") else { return }
        
        for ing in ingSet {
            let newIng = IngredientEntity(context: context)
            newIng.name = ing.name
            newIng.quantity = ing.quantity * multiplier
            newIng.unit = ing.unit
            newIng.price = 0
            newIng.isPurchased = false
            newIng.list = list
        }
        
        do {
            try context.save()
            let done = UIAlertController(title: "Agregado", message: "Ingredientes agregados a la lista", preferredStyle: .alert)
            done.addAction(UIAlertAction(title: "OK", style: .default))
            present(done, animated: true)
        } catch {
            print("Error al guardar ingredientes en la lista: \(error)")
        }
    }

}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ing = ingredients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell", for: indexPath)
        cell.textLabel?.text = "\(ing.name ?? "") - \(ing.quantity.clean) \(ing.unit ?? "")"
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ingredient = ingredients[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, completion in
            self.context.delete(ingredient)
            do {
                try self.context.save()
                self.fetchIngredients()
                completion(true)
            } catch {
                print("❌ Error al eliminar ingrediente: \(error)")
                completion(false)
            }
        }

        let editAction = UIContextualAction(style: .normal, title: "Editar") { _, _, completion in
            self.showEditIngredientAlert(ingredient: ingredient)
            completion(true)
        }

        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", self) :
            String(self)
    }
}

