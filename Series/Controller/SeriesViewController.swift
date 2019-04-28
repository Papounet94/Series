//
//  SeriesViewController.swift
//  Series
//
//  Created by Christian BRUNEL on 24/04/2019.
//  Copyright © 2019 Christian BRUNEL. All rights reserved.
//

import UIKit
import CoreData

class SeriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - UI outlets
    @IBOutlet weak var seriesTableView: UITableView!
    
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var seasonBtn: UIButton!
    @IBOutlet weak var episodeBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    var series = [Serie]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        seriesTableView.delegate = self
        seriesTableView.dataSource = self
        
        seriesTableView.register(UINib(nibName: "SerieCell", bundle: nil), forCellReuseIdentifier: "CustomSerieCell")
        loadSeries()
        containerView.isHidden = true
    }
    
    //MARK: - Tableview Delegate methods
    
    // Number of rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return series.count
    }
    
    // cellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSerieCell", for: indexPath) as! CustomSerieCell
        cell.titleLabel.text = series[indexPath.row].name!
        cell.episodeLabel.text = String(format: "S%02ldE%02ld", Int(series[indexPath.row].season), Int(series[indexPath.row].episode))
        cell.dateLabel.text = showDate(date: (series[indexPath.row].date!))

        return cell
    }
    
    // didSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let selectedSeries = series[selectedRow!]
        titleBtn.setTitle(selectedSeries.name, for: .normal)
        dateBtn.setTitle(showDate(date: selectedSeries.date!), for: .normal)
        seasonBtn.setTitle("\(selectedSeries.season)", for: .normal)
        episodeBtn.setTitle("\(selectedSeries.episode)", for: .normal)
        containerView.isHidden = false
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Handling creation of New series
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Series", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newSerie = Serie(context: self.context)
            newSerie.name = textField.text!
            newSerie.date = Date()
            self.series.append(newSerie)
            self.saveSeries()
        }
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Add the name of the Series"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Methods for responding to UI actions
    
    // Modify series title
    @IBAction func titleBtnPressed(_ sender: UIButton) {
        // Prepare an Alert View with a TexField for input
        let alert = UIAlertController(title: "Modify Title", message: "", preferredStyle: .alert)
        var textField = UITextField()
        // Set the action to perform when clicking Done button
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            self.series[self.selectedRow!].name = textField.text!
            self.titleBtn.setTitle(textField.text!, for: .normal)
            self.saveSeries()
        }
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = self.titleBtn.title(for: .normal)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Modify series Date
    @IBAction func dateBtnPressed(_ sender: UIButton) {
        // prepare an AlertView with enough space for the Date Picker
        let alert = UIAlertController(title: "Modify Date\n\n\n\n\n\n\n\n", message: "", preferredStyle: .alert)
        let datePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        datePicker.datePickerMode = .date
        //Set the current date of the Date Picker to the date of the Date Button
        datePicker.setDate(makeDate(dateString: dateBtn.title(for: .normal)!), animated: false)
        alert.view.addSubview(datePicker)
        // Manage the action of the Done Button af the Alert View
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            self.series[self.selectedRow!].date = datePicker.date
            self.dateBtn.setTitle(self.showDate(date: datePicker.date), for: .normal)
            self.saveSeries()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Modify series season number
    @IBAction func seasonBtnPressed(_ sender: UIButton) {
        // Prepare an Alert View with a TexField for input
        let alert = UIAlertController(title: "Modify Season Number", message: "", preferredStyle: .alert)
        var textField = UITextField()
        // Set the action to perform when clicking Done button
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            let tmp = textField.text!
            self.series[self.selectedRow!].season = Int64(tmp)!
            self.seasonBtn.setTitle(textField.text!, for: .normal)
            self.saveSeries()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = self.seasonBtn.title(for: .normal)
            // Accept only numeric input
            alertTextField.keyboardType = .numberPad
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //Modify series episode number
    @IBAction func episodeBtnPressed(_ sender: UIButton) {
        // Prepare an Alert View with a TexField for input
        let alert = UIAlertController(title: "Modify Episode Number", message: "", preferredStyle: .alert)
        var textField = UITextField()
        // Set the action to perform when clicking Done button
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            let tmp = textField.text!
            self.series[self.selectedRow!].episode = Int64(tmp)!
            self.episodeBtn.setTitle(textField.text!, for: .normal)
            self.saveSeries()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = self.episodeBtn.title(for: .normal)
            // Accept only numeric input
            alertTextField.keyboardType = .numberPad
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data Manipulation methods
    
    func loadSeries(with request : NSFetchRequest<Serie> = Serie.fetchRequest())  {
        do {
            series = try context.fetch(request)
        }
        catch {
            print("Error fetching context \(error)")
        }
        seriesTableView.reloadData()
    }
    
    func saveSeries() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
        seriesTableView.reloadData()
        if selectedRow != nil {
            seriesTableView.selectRow(at: IndexPath(row: selectedRow!, section: 0), animated: true, scrollPosition: .middle)
        }
    }
    
    //MARK: - Utility methods
    
    // Extract the reduced date from a Date value
    func showDate(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    // Create a Date value from a reduced date
    func makeDate(dateString : String) -> Date {
        
        // Get the current year
        let cal = Calendar.current
        let year = cal.component(.year, from: Date())
        //Gets [day, month] from reduced date
        let components = dateString.split(separator: "/")
        // Format a new date with these components
        var comp = DateComponents()
        comp.year = year
        comp.month = Int(components[1])
        comp.day = Int(components[0])
        // Should be adapted if the app is distributed
        comp.timeZone = TimeZone(identifier: "Europe/Paris")
        comp.hour = 12
        
        return cal.date(from: comp)!
    }
}

