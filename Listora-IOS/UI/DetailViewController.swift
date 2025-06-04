//
//  DetailViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 03/06/25.
//

import UIKit

class DetailViewController: UIViewController {

    var shoppingList: ShoppingListEntity?

    private let nameLabel = UILabel()
    private let budgetLabel = UILabel()
    private let dateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detalle de lista"

        setupLabels()
        loadData()
    }

    private func setupLabels() {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, budgetLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func loadData() {
        guard let list = shoppingList else { return }

        nameLabel.text = "Nombre: \(list.name ?? "-")"
        budgetLabel.text = String(format: "Presupuesto: $%.2f", list.budget)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let date = list.date {
            dateLabel.text = "Fecha límite: \(formatter.string(from: date))"
        } else {
            dateLabel.text = "Fecha límite: -"
        }
    }

}
