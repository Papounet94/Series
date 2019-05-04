//
//  SeriesViewController.swift
//  Series
//
//  Created by Christian BRUNEL on 24/04/2019.
//  Copyright © 2019 Christian BRUNEL. All rights reserved.
//

import UIKit
import CoreData

class SeriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    //MARK: - UI outlets
    // The TableView that displays the Series list
    @IBOutlet weak var seriesTableView: UITableView!
    // The outles of the Editing zone Fields
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var seasonBtn: UIButton!
    @IBOutlet weak var episodeBtn: UIButton!
    // The outlet of the Editing Zone
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Class variables
    // The Series list
    var series = [Serie]()
    // the context for the Coredata Database
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // The current selected Row in the table view (nil if none selected)
    // for enabling sorting of the series list, the selected serie has to saved, not only the row number
    var selectedSerie : Serie?
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)

    }
    
    //MARK: - Tableview Delegate methods
    
    // Number of rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return series.count
    }
    
    // cellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CustomSerieCell", for: indexPath) as! CustomSerieCell
        
        updateCellUI(cell: &cell, row: indexPath.row)

        return cell
    }
    
    // didSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when the user clicks on a selected row, he deselects it
        if selectedRow == indexPath.row {
            tableView.deselectRow(at: indexPath, animated: true)
            containerView.isHidden = true
            selectedRow = nil
            selectedSerie = nil
        }
        // otherwise he selects it and the editing view is set with the parameters of the selected row
        // and is shown at the bottom
        else
        {
            selectedRow = indexPath.row
            selectedSerie = series[selectedRow!]
            let selectedSeries = series[selectedRow!]
            updateFields(title: selectedSeries.name!, date: showDate(date: selectedSeries.date!), season: selectedSeries.season, episode: selectedSeries.episode)
            containerView.isHidden = false
        }
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
            textField.text = self.titleBtn.title(for: .normal)
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
            alertTextField.text = self.seasonBtn.title(for: .normal)
            // Accept only numeric input
            alertTextField.keyboardType = .numberPad
            textField = alertTextField
            textField.delegate = self
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
            alertTextField.text = self.episodeBtn.title(for: .normal)
            // Accept only numeric input
            alertTextField.keyboardType = .numberPad
            textField = alertTextField
            textField.delegate = self
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data Manipulation methods
    
    func loadSeries(with request : NSFetchRequest<Serie> = Serie.fetchRequest())  {
        do {
            series = try context.fetch(request)
            // List is sorted by ascending dates
            series.sort { $0.date! < $1.date! }
        }
        catch {
            print("Error fetching context \(error)")
        }
        seriesTableView.reloadData()
    }
    
    func saveSeries() {
        series.sort { $0.date! < $1.date! }
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
        seriesTableView.reloadData()
        if selectedRow != nil {
            // find the row for the selectedSerie as it may have changed after sorting
            selectedRow = series.firstIndex(of: selectedSerie!)
            seriesTableView.selectRow(at: IndexPath(row: selectedRow!, section: 0), animated: true, scrollPosition: .middle)
        }
    }
    
    //MARK: - Button Handlers
    
    // End Series Button
    @IBAction func endSeriesButtonPressed(_ sender: UIButton) {
        // set the date to 01/01/4000
        series[selectedRow!].date = makeDate(dateString: "01/01", desiredYear: 4000)
        // set the Terminated property to true
        // set the Announced and Running properties to false
        series[selectedRow!].running = false
        series[selectedRow!].announced = false
        series[selectedRow!].terminated = true
        saveSeries()
    }
    
    //New Season Button
    @IBAction func newSeasonButtonPressed(_ sender: UIButton) {
        // set the year to current year
        series[selectedRow!].date = makeDate(dateString: "01/01")
        // set the Announced property to true
        // set the Running and Terminated property to false
        series[selectedRow!].running = false
        series[selectedRow!].announced = true
        series[selectedRow!].terminated = false
        saveSeries()
    }
    
    //End Season Button
    @IBAction func endSeasonButtonPressed(_ sender: UIButton) {
        // set the date to 01/01/3000
        series[selectedRow!].date = makeDate(dateString: "01/01", desiredYear: 3000)
        // advance season number by +1
        series[selectedRow!].season += 1
        // set episode number to 1
        series[selectedRow!].episode = 1
        // set all properties to false
        series[selectedRow!].running = false
        series[selectedRow!].announced = false
        series[selectedRow!].terminated = false
        saveSeries()
    }
    
    //Next Week Button
    @IBAction func nextWeekButtonPressed(_ sender: UIButton) {
        // advance the date by 7 days
        series[selectedRow!].date! += 7*24*60*60 // 7 days in seconds
        // advance episode number by +1
        series[selectedRow!].episode += 1
        // set running property to true and all other to false
        series[selectedRow!].running = true
        series[selectedRow!].announced = false
        series[selectedRow!].terminated = false
        saveSeries()
    }
    
    //MARK: - Utility methods
    
    // Extract the reduced date from a Date value
    func showDate(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    // Create a Date value from a reduced date
    func makeDate(dateString : String, desiredYear: Int = 0) -> Date {
        
        let cal = Calendar.current
        // set year to the current year if no value is passed in desiredYear
        var year : Int
        year = desiredYear == 0 ? cal.component(.year, from: Date()) : desiredYear
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
    
    func updateCellUI( cell: inout CustomSerieCell, row: Int) {
        // fill in the cell fields
        cell.titleLabel.text = series[row].name!
        cell.episodeLabel.text = String(format: "S%02ldE%02ld", Int(series[row].season), Int(series[row].episode))
        cell.dateLabel.text = showDate(date: (series[row].date!))
        // if 'running' is true then display date in green
        if series[row].running {
            cell.dateLabel.textColor = UIColor(red: 0.0, green: 0.5, blue: 0, alpha: 1.0)
            cell.titleLabel.textColor = UIColor.darkGray
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            cell.dateLabel.font = UIFont.systemFont(ofSize: cell.dateLabel.font.pointSize)
        }
            // if 'announced' is true then display date in blue
        else if series[row].announced {
            cell.dateLabel.textColor = UIColor.blue
            cell.titleLabel.textColor = UIColor.darkGray
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            cell.dateLabel.font = UIFont.systemFont(ofSize: cell.dateLabel.font.pointSize)
        }
            // if 'terminated is true then display '----' as date, display title in italics gray
            // and do not display season and episode
        else if series[row].terminated {
            cell.titleLabel.textColor = UIColor.gray
            cell.dateLabel.textColor = UIColor.gray
            cell.episodeLabel.text = ""
            cell.dateLabel.text = "----"
            cell.titleLabel.font = UIFont.italicSystemFont(ofSize: cell.titleLabel.font.pointSize)
            cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
        }
            // if 'running', 'announced' and 'terminated' are false then display '????' as date
            // and do not display season and episode
        else {
            cell.titleLabel.textColor = UIColor.darkGray
            cell.dateLabel.textColor = UIColor.darkGray
            cell.episodeLabel.text = ""
            cell.dateLabel.text = "????"
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            cell.dateLabel.font = UIFont.systemFont(ofSize: cell.dateLabel.font.pointSize)
        }
        // do not update fields when no row is selected
        // update only the fields for the selected row
        if selectedRow != nil && selectedRow == row {
        updateFields(title: series[row].name!, date: showDate(date: (series[row].date!)), season: series[row].season, episode: series[row].episode)
        }
    }
    
    // Udate of the fields of the selected series
    
    func updateFields(title: String, date: String, season: Int64, episode: Int64) {
        
        titleBtn.setTitle(title, for: .normal)
        dateBtn.setTitle(date, for: .normal)
        seasonBtn.setTitle("\(season)", for: .normal)
        episodeBtn.setTitle("\(episode)", for: .normal)
    }
}

