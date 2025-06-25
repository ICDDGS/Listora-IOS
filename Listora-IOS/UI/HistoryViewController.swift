//
//  HistoryViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 02/06/25.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var stackGrafica: UIStackView!
    @IBOutlet weak var weekLabel: UILabel!
    
    private var gastosPorDia: [String: Double] = [:]
    private var semanaActual = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        stackGrafica.axis = .horizontal
        stackGrafica.distribution = .fillEqually
        stackGrafica.alignment = .bottom
        stackGrafica.spacing = 8
        actualizarSemana()
    }

    @IBAction func semanaAnterior(_ sender: UIButton) {
        semanaActual = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: semanaActual) ?? semanaActual
        actualizarSemana()
    }

    @IBAction func semanaSiguiente(_ sender: UIButton) {
        semanaActual = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: semanaActual) ?? semanaActual
        actualizarSemana()
    }

    @IBAction func exportarCSV(_ sender: UIButton) {
        let csv = gastosPorDia.map { "\($0.key),\($0.value)" }.joined(separator: "\n")
        let fileName = "gastos_semanales.csv"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        do {
            try csv.write(to: path, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            present(activityVC, animated: true)
        } catch {
            print("Error al guardar CSV: \(error)")
        }
    }

    func actualizarSemana() {
        let calendar = Calendar.current
        let inicio = calendar.startOfWeek(for: semanaActual)
        let fin = calendar.date(byAdding: .day, value: 6, to: inicio) ?? inicio

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        weekLabel.text = "Semana: \(formatter.string(from: inicio)) - \(formatter.string(from: fin))"
        weekLabel.textColor = .black

        let datos = cargarDatosDesdeHistorial()
        generarGraficaBarra(datos, en: stackGrafica)
    }


    func generarGraficaBarra(_ datos: [String: Double], en contenedor: UIStackView) {
        contenedor.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let maxValor = datos.values.max() ?? 1.0

        for dia in ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"] {
            let valor = datos[dia] ?? 0

            let barraContainer = UIStackView()
            barraContainer.axis = .vertical
            barraContainer.alignment = .center
            barraContainer.spacing = 4

            let alturaMax: CGFloat = 150
            let altura = CGFloat(valor) / CGFloat(maxValor) * alturaMax

            let barra = UIView()
            barra.backgroundColor = .systemBlue
            barra.layer.cornerRadius = 4
            barra.translatesAutoresizingMaskIntoConstraints = false
            barra.widthAnchor.constraint(equalToConstant: 20).isActive = true
            barra.heightAnchor.constraint(equalToConstant: altura).isActive = true

            let valorLabel = UILabel()
            valorLabel.text = String(format: "$%.2f", valor)
            valorLabel.font = .systemFont(ofSize: 10)
            valorLabel.textColor = .black
            valorLabel.textAlignment = .center

            let etiqueta = UILabel()
            etiqueta.text = dia
            etiqueta.font = .systemFont(ofSize: 10)
            etiqueta.textAlignment = .center
            etiqueta.textColor = .black

            barraContainer.addArrangedSubview(valorLabel)
            barraContainer.addArrangedSubview(barra)
            barraContainer.addArrangedSubview(etiqueta)

            contenedor.addArrangedSubview(barraContainer)
        }
    }

    func cargarDatosDesdeHistorial() -> [String: Double] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: semanaActual)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<HistorialEntity> = HistorialEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfWeek as NSDate, endOfWeek as NSDate)

        do {
            let resultados = try context.fetch(fetchRequest)

            var resumen: [String: Double] = [:]
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"  // Esto da: Mon, Tue, Wed, ...

            for registro in resultados {
                let dia = formatter.string(from: registro.date ?? Date())
                let clave = convertirADiaEsp(dia)
                resumen[clave, default: 0] += registro.price
            }

            return resumen

        } catch {
            print("Error al cargar historial: \(error)")
            return [:]
        }
    }

    func convertirADiaEsp(_ eng: String) -> String {
        switch eng {
        case "Mon": return "Lun"
        case "Tue": return "Mar"
        case "Wed": return "Mié"
        case "Thu": return "Jue"
        case "Fri": return "Vie"
        case "Sat": return "Sáb"
        case "Sun": return "Dom"
        default: return eng
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actualizarSemana()
    }



}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}



