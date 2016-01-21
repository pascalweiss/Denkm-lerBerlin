//
//  AdvancedSearchViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 05.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit
import Foundation

protocol DMBAdvancedSearchDelegate {
    func sendDataBack(data: DMBFilter)
}

class DMBAdvancedSearchViewController: UITableViewController {
    
    var delegate: DMBAdvancedSearchDelegate?
    
    // Filter
    var filter: DMBFilter?
    
    // Arrays fuer die TableView
    var allMonuTypes  = [(type: String, on: Bool)]()
    var allDistricts  = [(type: String, on: Bool)]()
    var allTimeLimits = [(type: String, on: Bool)]()
    var allSections   = [[(type: String, on: Bool)]]()
    let headerTitles  = ["Zeitraum", "Denkmaltypen", "Bezirke"]
    
    // MARK: Elemente fuer Range Slider
    let customRangeSlider = RangeSlider(frame: CGRectZero)
    let labelLowerValue = UILabel()
    let labelUpperValue = UILabel()
    
    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if filter == nil {
            filter = DMBFilter()
        }
        
        for district in DMBModel.sharedInstance.getAllDistricts() {
            let distrName = district.getName()
            
            if distrName != nil  && distrName?.isEmpty != true {
                let on = getFilterAttributeFromString(distrName!)
                allDistricts.append((type: distrName!, on: on))
            }
        }
        
        // Test-Ausgabe auf der Konsole
//        for district in allDistricts {
//            print("District: \(district.type)")
//        }
        
        for monuType in DMBModel.sharedInstance.getAllTypes() {
            let monTypeName = monuType.getName()
            if monTypeName != nil && monTypeName?.isEmpty != true {
                let on = getFilterAttributeFromString(monTypeName!)
                allMonuTypes.append((type: monTypeName!, on: on))
            }
        }
        
        // Test-Ausgabe auf der Konsole
//        for monuType in allMonuTypes {
//            print("MonuType: \(monuType.type)")
//        }
        
        // Leere Zeile fuer Range Slider erzeugen
        allTimeLimits.append((type: "", on: true))
        
        allSections = [allTimeLimits, allMonuTypes, allDistricts]
        
        tableView.registerClass(DMBAdvSearchTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(DMBAdvSearchTableViewCell))
        
        // Range Slider inklusive Wertanzeige in View einbinden
        view.addSubview(customRangeSlider)
        customRangeSlider.addTarget(self, action: "rangeSliderValueChanged:", forControlEvents: .ValueChanged)
        
        let fomatter = NSDateFormatter()
        fomatter.dateFormat = "yyyy"
        
        if filter != nil {
            customRangeSlider.lowerValue = Double(fomatter.stringFromDate((filter?.from)!))!
            customRangeSlider.upperValue = Double(fomatter.stringFromDate((filter?.to)!))!
        }
        labelLowerValue.text = "\(Int(customRangeSlider.lowerValue))"
        view.addSubview(labelLowerValue)

        labelUpperValue.text = "\(Int(customRangeSlider.upperValue))"
        view.addSubview(labelUpperValue)
    }
    
    // MARK: Range Slider positionieren
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let height: CGFloat = 30.0;
        let shift:  CGFloat = 62.0;
        let label:  CGFloat = 100.0;
        let width = view.bounds.width - 2.0 * margin - 1.0 * label
        
        customRangeSlider.frame = CGRect(x: margin + (label / 2), y: shift, width: width, height: height)
        labelLowerValue.frame = CGRect(x: margin, y: shift, width: label, height: height)
        labelLowerValue.textAlignment = NSTextAlignment.Left;
        labelUpperValue.frame = CGRect(x: view.frame.size.width - margin - label, y: shift, width: label, height: height)
        labelUpperValue.textAlignment = NSTextAlignment.Right;
    }

    override func viewWillDisappear(animated: Bool) {
        navigationBackPassData(self)
    }
    
    // MARK: Button / Switch Target
    func switchMonTypesValueChange(sender: UISwitch!){
        
        // Eigenartiger bug -- Das hier fixed ihn - ist aber dirty
        // Wenn der Switch von Treptow gedrückt dann wurde fascher Selector aufgerufen
        if sender.tag > allMonuTypes.count {
            switchDistrictsValueChange(sender)
            return
        }
        
        allMonuTypes[sender.tag].on = sender.on
        allSections[1][sender.tag].on = sender.on
        
        setFilterAttributeFromString(allMonuTypes[sender.tag].type, on: sender.on)
        
    }
    
    func switchDistrictsValueChange(sender: UISwitch!){
        
        allDistricts[sender.tag].on = sender.on
        allSections[2][sender.tag].on = sender.on
        
        setFilterAttributeFromString(allDistricts[sender.tag].type, on: sender.on)

    }
    
    // MARK: Navigation
    func navigationBackPassData(sender: AnyObject) {
        // do the things
        self.delegate?.sendDataBack(filter!)
    }

    // MARK: - Table view data source
    // Anzahl Sections zaehlen und zurueckliefern
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allSections.count
    }

    // Anzahl Zeilen je Section zaehlen
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSections[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if indexPath.section == 1 || indexPath.section == 2 {
            let advCell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(DMBAdvSearchTableViewCell), forIndexPath: indexPath) as! DMBAdvSearchTableViewCell
            advCell.nameLabel.text = allSections[indexPath.section][indexPath.row].type
            advCell.activateSwitch.tag = indexPath.row
            advCell.activateSwitch.on = allSections[indexPath.section][indexPath.row].on
            let action = indexPath.section == 1 ? "switchMonTypesValueChange:" : "switchDistrictsValueChange:"
            advCell.activateSwitch.addTarget(self, action: Selector.init(action), forControlEvents: UIControlEvents.ValueChanged)
            cell = advCell
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    
    // MARK: Kann die Methode raus???
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Veraenderte Position Schieberegler des Range Sliders holen
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        //print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))") // Test-Ausgabe auf der Konsole
        labelLowerValue.text = "\(Int(rangeSlider.lowerValue))"
        labelUpperValue.text = "\(Int(rangeSlider.upperValue))"
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.dateFormat = "yyyy"
        filter?.from = formatter.dateFromString(labelLowerValue.text!)!
        filter?.to = formatter.dateFromString(labelUpperValue.text!)!
        
    }
    
    func getFilterAttributeFromString(string: String) -> Bool {
        var re = false
        switch string {
        case "Ensemble":  re = filter!.ensemble
        case "Ensembleteil":  re = filter!.ensembleteil
        case "Gesamtanlage":  re = filter!.gesamtanlage
        case "Baudenkmal":  re = filter!.baudenkmal
        case "Gartendenkmal":  re = filter!.gartendenkmal
        case "Bodendenkmal":  re = filter!.bodendenkmal
            case "Charlottenburg-Wilmersdorf": re = filter!.charlottenburgWilmersdorf
            case "Steglitz-Zehlendorf": re = filter!.steglitzZehlendorf
            case "Spandau": re = filter!.spandau
            case "Friedrichshain-Kreuzberg": re = filter!.friedrichshainKreuzberg
            case "Tempelhof-Schöneberg": re = filter!.tempelhofSchöneberg
            case "Mitte": re = filter!.mitte
            case "Neukölln": re = filter!.neukölln
            case "Lichtenberg": re = filter!.lichtenberg
            case "Marzahn-Hellersdorf": re = filter!.marzahnHellersdorf
            case "Pankow": re = filter!.pankow
            case "Reinickendorf":  re = filter!.reinickendorf
            case "Treptow-Köpenick": re = filter!.treptowKöpenick
            
        default: break
        }
        return re
    }
    
    func setFilterAttributeFromString(string: String, on: Bool) {
        switch string {
        case "Ensemble": filter?.ensemble = on
        case "Ensembleteil": filter?.ensembleteil = on
        case "Gesamtanlage": filter?.gesamtanlage = on
        case "Baudenkmal": filter?.baudenkmal = on
        case "Gartendenkmal": filter?.gartendenkmal = on
        case "Bodendenkmal": filter?.bodendenkmal = on
        case "Charlottenburg-Wilmersdorf": filter!.charlottenburgWilmersdorf = on
        case "Steglitz-Zehlendorf": filter!.steglitzZehlendorf = on
        case "Spandau": filter!.spandau = on
        case "Friedrichshain-Kreuzberg": filter!.friedrichshainKreuzberg = on
        case "Tempelhof-Schöneberg": filter!.tempelhofSchöneberg = on
        case "Mitte": filter!.mitte = on
        case "Neukölln": filter!.neukölln = on
        case "Lichtenberg": filter!.lichtenberg = on
        case "Marzahn-Hellersdorf": filter!.marzahnHellersdorf = on
        case "Pankow": filter!.pankow = on
        case "Reinickendorf":  filter!.reinickendorf = on
        case "Treptow-Köpenick": filter!.treptowKöpenick = on
        default: break
        }
    }

}
