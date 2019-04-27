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

    @IBOutlet weak var seriesTableView: UITableView!
    
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
    
    //MARK: - Handling creation of New series
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Series", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newSerie = Serie(context: self.context)
            newSerie.name = textField.text!
            newSerie.date = Date(timeIntervalSinceNow: 0)
            newSerie.season = 1
            newSerie.episode = 1
            newSerie.running = true
            newSerie.announced = false
            newSerie.terminated = false
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
}

