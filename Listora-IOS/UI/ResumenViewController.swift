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
        exportarAExcel()
    }

    @IBAction func volverAListas(_ sender: UIButton) {
        guardarEnHistorial()
        navigationController?.popToRootViewController(animated: true)
    }

    
    func exportarAExcel() {
        let fileName = "ResumenCompras.csv"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = documentsURL.appendingPathComponent(fileName)


        var csvText = "Ingrediente,Cantidad,Unidad,Precio\n"

        for compra in compras {
            let linea = "\(compra.name ?? ""),\(compra.quantity),\(compra.unit ?? ""),\(compra.price)\n"
            csvText.append(contentsOf: linea)
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)

            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true)
        } catch {
            print("Error al exportar archivo CSV: \(error)")
        }
    }
    func guardarEnHistorial() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        for compra in compras {
            let historial = HistorialEntity(context: context)
            historial.name = compra.name
            historial.quantity = compra.quantity
            historial.unit = compra.unit
            historial.price = compra.price
            historial.date = compra.purchasedDate ?? Date()
        }

        do {
            try context.save()
            print("Historial guardado correctamente.")
        } catch {
            print("Error al guardar en historial: \(error)")
        }
    }


}

