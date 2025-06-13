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

    let imageView = UIImageView()
    let nameLabel = UILabel()
    let categoryLabel = UILabel()

    let addToListButton = UIButton(type: .system)
    let quantityLabel = UILabel()
    let minusButton = UIButton(type: .system)
    let quantityValueLabel = UILabel()
    let plusButton = UIButton(type: .system)

    let tableView = UITableView()
    let addButton = UIButton(type: .system)
    let preparationLabel = UILabel()
    let preparationTextView = UITextView()

    var tableViewHeightConstraint: NSLayoutConstraint!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recipe.name ?? "Detalle"
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        fetchIngredients()
    }

    func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        [imageView, nameLabel, categoryLabel, addToListButton, quantityLabel, minusButton, quantityValueLabel, plusButton, tableView, addButton, preparationLabel, preparationTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        [scrollView].forEach {
            view.addSubview($0)
        }

        scrollView.addSubview(containerView)

        imageView.image = UIImage(systemName: "fork.knife")
        imageView.contentMode = .scaleAspectFit

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.text = recipe.name

        categoryLabel.font = .systemFont(ofSize: 16)
        categoryLabel.textColor = .gray
        categoryLabel.text = "Categoría: \(recipe.descript ?? "Sin categoría")"

        addToListButton.setTitle("Agregar a lista", for: .normal)
        addToListButton.backgroundColor = UIColor(named: "primary")
        addToListButton.setTitleColor(.white, for: .normal)
        addToListButton.layer.cornerRadius = 6
        addToListButton.addTarget(self, action: #selector(addToListTapped), for: .touchUpInside)

        quantityLabel.text = "Cantidad"
        quantityLabel.font = .systemFont(ofSize: 16)

        minusButton.setTitle("-", for: .normal)
        minusButton.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)

        plusButton.setTitle("+", for: .normal)
        plusButton.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)

        quantityValueLabel.text = "1"
        quantityValueLabel.font = .systemFont(ofSize: 16)

        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeIngredientCell")
        tableView.delegate = self
        tableView.dataSource = self

        addButton.setTitle("Agregar Ingrediente", for: .normal)
        addButton.backgroundColor = UIColor(named: "primary")
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 6
        addButton.addTarget(self, action: #selector(addIngredientTapped), for: .touchUpInside)

        preparationLabel.text = "Pasos de Preparación"
        preparationLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        preparationTextView.text = recipe.steps ?? "Escribe los pasos aquí..."
        preparationTextView.font = .systemFont(ofSize: 16)
        preparationTextView.backgroundColor = UIColor.systemGray6
        preparationTextView.layer.borderWidth = 1
        preparationTextView.layer.borderColor = UIColor.systemGray4.cgColor
        preparationTextView.layer.cornerRadius = 10
        preparationTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
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

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            addToListButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            addToListButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addToListButton.heightAnchor.constraint(equalToConstant: 32),

            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            quantityLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            minusButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 16),
            minusButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30),

            quantityValueLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 8),
            quantityValueLabel.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),

            plusButton.leadingAnchor.constraint(equalTo: quantityValueLabel.trailingAnchor, constant: 8),
            plusButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: addToListButton.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: addToListButton.trailingAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),

            preparationLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 24),
            preparationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            preparationTextView.topAnchor.constraint(equalTo: preparationLabel.bottomAnchor, constant: 8),
            preparationTextView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            preparationTextView.trailingAnchor.constraint(equalTo: addToListButton.trailingAnchor),
            preparationTextView.heightAnchor.constraint(equalToConstant: 150),
            preparationTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 44)
        tableViewHeightConstraint.isActive = true
    }

    func fetchIngredients() {
        if let ingSet = recipe.ingredient as? Set<RecipeIngEntity> {
            ingredients = Array(ingSet)
            tableView.reloadData()
            tableViewHeightConstraint.constant = CGFloat(ingredients.count) * 44.0
        }
    }

    @objc func addIngredientTapped() {
        let alert = UIAlertController(title: "Ingrediente", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Nombre" }
        alert.addTextField { $0.placeholder = "Cantidad"; $0.keyboardType = .decimalPad }
        alert.addTextField { $0.placeholder = "Unidad" }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let qtyText = alert.textFields?[1].text, let quantity = Double(qtyText),
                  let unit = alert.textFields?[2].text else { return }

            let ing = RecipeIngEntity(context: self.context)
            ing.name = name
            ing.quantity = quantity
            ing.unit = unit
            ing.recipe = self.recipe

            do {
                try self.context.save()
                self.fetchIngredients()
            } catch {
                print("❌ Error al guardar: \(error)")
            }
        }))
        present(alert, animated: true)
    }

    @objc func increaseQuantity() {
        if let current = Int(quantityValueLabel.text ?? "1") {
            quantityValueLabel.text = "\(current + 1)"
        }
    }

    @objc func decreaseQuantity() {
        if let current = Int(quantityValueLabel.text ?? "1"), current > 1 {
            quantityValueLabel.text = "\(current - 1)"
        }
    }

    @objc func addToListTapped() {
        let fetchRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()

        do {
            let lists = try context.fetch(fetchRequest)
            let alert = UIAlertController(title: "Selecciona una lista", message: nil, preferredStyle: .actionSheet)

            for list in lists {
                alert.addAction(UIAlertAction(title: list.name, style: .default, handler: { _ in
                    self.addIngredientsToList(list)
                }))
            }

            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            present(alert, animated: true)

        } catch {
            print("Error al obtener listas: \(error)")
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
        } catch {
            print("Error al guardar en la lista: \(error)")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recipe.steps = preparationTextView.text
        do {
            try context.save()
        } catch {
            print("❌ Error al guardar pasos: \(error)")
        }
    }
}

extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ing = ingredients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell", for: indexPath)
        cell.textLabel?.text = "\(ing.name ?? "") - \(ing.quantity.clean) \(ing.unit ?? "")"
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ingredient = ingredients[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: "Eliminar") { _, _, done in
            self.context.delete(ingredient)
            try? self.context.save()
            self.fetchIngredients()
            done(true)
        }

        let edit = UIContextualAction(style: .normal, title: "Editar") { _, _, done in
            self.addIngredientTapped() // Simplified for now
            done(true)
        }

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", self) :
            String(self)
    }
}

