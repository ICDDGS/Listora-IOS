//
//  SettingsViewController.swift
//  Listora-IOS
//
//  Created by Alejandro on 01/07/25.
//

import UIKit
import UserNotifications
import CoreData

class SettingsViewController: UIViewController {

    // Etiquetas
    let notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Activar notificaciones"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let timePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Elegir hora de notificación"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Switch y Picker
    let notificationsSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()

    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Agregar elementos a la vista
        [notificationsLabel, notificationsSwitch, timePickerLabel, timePicker].forEach {
            view.addSubview($0)
        }

        setupConstraints()

        notificationsSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)

        let enabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        notificationsSwitch.isOn = enabled
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            notificationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notificationsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            notificationsSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notificationsSwitch.topAnchor.constraint(equalTo: notificationsLabel.bottomAnchor, constant: 10),

            timePickerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerLabel.topAnchor.constraint(equalTo: notificationsSwitch.bottomAnchor, constant: 40),

            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.topAnchor.constraint(equalTo: timePickerLabel.bottomAnchor, constant: 10)
        ])
    }

    @objc func switchChanged(_ sender: UISwitch) {
        let center = UNUserNotificationCenter.current()
        if sender.isOn {
            center.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        UserDefaults.standard.set(true, forKey: "notifications_enabled")
                    } else {
                        sender.isOn = false
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: "notifications_enabled")
            center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        }
    }

    @objc func timeChanged(_ sender: UIDatePicker) {
        if notificationsSwitch.isOn {
            scheduleDailyReminder(at: sender.date)
        }
    }


    func scheduleDailyReminder(at date: Date) {
        guard UserDefaults.standard.bool(forKey: "notifications_enabled") else { return }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<IngredientEntity> = IngredientEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isPurchased == false")

        do {
            let pendientes = try context.fetch(fetchRequest)
            print("🧾 Ingredientes sin comprar encontrados: \(pendientes.count)")


            if pendientes.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
                return
            }

            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)

            var trigger = DateComponents()
            trigger.hour = components.hour
            trigger.minute = components.minute

            let content = UNMutableNotificationContent()
            content.title = "Recordatorio de compras"
            content.body = "Tienes listas pendientes por revisar 🛒"
            content.sound = .default

            let request = UNNotificationRequest(identifier: "dailyReminder",
                                                content: content,
                                                trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true))

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error al programar notificación: \(error)")
                } else {
                    print("✅ Notificación programada")
                }
            }

        } catch {
            print("Error al verificar ingredientes: \(error)")
        }
    }
}


