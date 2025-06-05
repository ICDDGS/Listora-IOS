//
//  ResumenViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 04/06/25.
//

import UIKit
import CoreData

class ResumenViewController: UIViewController, UITableViewDataSource {

    var compras: [IngredientEntity] = []
    var total: Double = 0.0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTotal: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resumen"
        tableView.dataSource = self

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")

        labelTotal.text = "Total gastado: \(formatter.string(from: NSNumber(value: total)) ?? "$0.00")"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return compras.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let compra = compras[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "resumenCell")
        cell.textLabel?.text = compra.name
        cell.detailTextLabel?.text = "\(compra.quantity) \(compra.unit ?? "") - $\(compra.price)"
        return cell
    }

    @IBAction func exportarExcel(_ sender: UIButton) {
        // Aquí implementarás exportación más adelante
        print("Exportar a Excel (pendiente)")
    }

    @IBAction func volverAListas(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

