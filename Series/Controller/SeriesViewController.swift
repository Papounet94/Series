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
    

    func loadSeries(with request : NSFetchRequest<Serie> = Serie.fetchRequest())  {
        do {
            series = try context.fetch(request)
        }
        catch {
            print("Error fetching context \(error)")
        }
    }
    
    func saveSeries() {
        do {
            try context.save()        }
        catch {
            print("Error saving context \(error)")
        }
    }
}

