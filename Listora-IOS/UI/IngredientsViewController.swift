//
//  IngredientsViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 02/06/25.
//

import UIKit

class IngredientsViewController: UIViewController {

    var listName: String?
    var ingredients: [String] = []

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = listName ?? "Ingredientes"

        setupTableView()
        setupAddButton()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addIngredient)
        )
    }

    @objc private func addIngredient() {
        let alert = UIAlertController(title: "Nuevo Ingrediente", message: "Ingresa el nombre del ingrediente", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Ej: Leche"
        }

        let addAction = UIAlertAction(title: "Agregar", style: .default) { _ in
            if let ingredient = alert.textFields?.first?.text, !ingredient.isEmpty {
                self.ingredients.append(ingredient)
                self.tableView.reloadData()
            }
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}

extension IngredientsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        cell.textLabel?.text = ingredients[indexPath.row]
        return cell
    }

    // Marcado como comprado (opcional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = ingredients[indexPath.row]
        print("Comprado: \(item)")
    }
}


