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
    
    
    var series = [Serie]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        seriesTableView.delegate = self
        seriesTableView.dataSource = self
        loadSeries()
    }
    
    //MARK: - Tableview Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return series.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SerieCell", for: indexPath)
        cell.textLabel!.text = series[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSeries = series[indexPath.row]
        titleBtn.setTitle(selectedSeries.name, for: .normal)
        dateBtn.setTitle(showDate(date: selectedSeries.date!), for: .normal)
        seasonBtn.setTitle("\(selectedSeries.season)", for: .normal)
        episodeBtn.setTitle("\(selectedSeries.episode)", for: .normal)

        tableView.deselectRow(at: indexPath, animated: true)
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
            textField.placeholder = "Add the ame of the Series"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Methods for responding to UI actions
    
    
    
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

