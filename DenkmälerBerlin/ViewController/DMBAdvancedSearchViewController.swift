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
    func sendDataBack(data: String)
}

class DMBAdvancedSearchViewController: UITableViewController {
    
    var delegate: DMBAdvancedSearchDelegate?
    
    // Arrays fuer die TableView
    var allMonuTypes  = [(type: String, on: Bool)]()
    var allDistricts  = [(type: String, on: Bool)]()
    var allTimeLimits = [(type: String, on: Bool)]()
    var allSections   = [[(type: String, on: Bool)]]()
    let headerTitles  = ["Denkmaltypen", "Bezirke", "Zeitraum"]
    
    // MARK: Elemente fuer Range Slider
    let customRangeSlider = RangeSlider(frame: CGRectZero)
    let labelLowerValue = UILabel()
    let labelUpperValue = UILabel()
    
    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for district in DMBModel.sharedInstance.getAllDistricts() {
            
            if district.getName() != nil  && district.getName()?.isEmpty != true {
                allDistricts.append((type: district.getName()!, on: true))
            }
        }
        
        // Test-Ausgabe auf der Konsole
//        for district in allDistricts {
//            print("District: \(district.type)")
//        }
        
        for monuType in DMBModel.sharedInstance.getAllTypes() {
            if monuType.getName() != nil && monuType.getName()?.isEmpty != true {
                allMonuTypes.append((type: monuType.getName()!, on: true))
            }
        }
        
        // Test-Ausgabe auf der Konsole
//        for monuType in allMonuTypes {
//            print("MonuType: \(monuType.type)")
//        }
        
        // Leere Zeile fuer Range Slider erzeugen
        allTimeLimits.append((type: "", on: true))
        
        allSections = [allMonuTypes, allDistricts, allTimeLimits]
        
        tableView.registerClass(DMBAdvSearchTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(DMBAdvSearchTableViewCell))
        
        // Range Slider inklusive Wertanzeige in View einbinden
        view.addSubview(customRangeSlider)
        customRangeSlider.addTarget(self, action: "rangeSliderValueChanged:", forControlEvents: .ValueChanged)
        
        labelLowerValue.text = "\(Int(customRangeSlider.lowerValue))"
        view.addSubview(labelLowerValue)
        
        labelUpperValue.text = "\(Int(customRangeSlider.upperValue))"
        view.addSubview(labelUpperValue)
    }
    
    // MARK: Range Slider positionieren
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let height: CGFloat = 30.0;
        let shift:  CGFloat = 75.0;
        let label:  CGFloat = 100.0;
        let width = view.bounds.width - 2.0 * margin - 1.0 * label
        
        customRangeSlider.frame = CGRect(x: margin + (label / 2), y: self.tableView.contentSize.height - shift, width: width, height: height)
        labelLowerValue.frame = CGRect(x: margin, y: self.tableView.contentSize.height - shift, width: label, height: height)
        labelLowerValue.textAlignment = NSTextAlignment.Left;
        labelUpperValue.frame = CGRect(x: view.frame.size.width - margin - label, y: self.tableView.contentSize.height - shift, width: label, height: height)
        labelUpperValue.textAlignment = NSTextAlignment.Right;
    }

    override func viewWillDisappear(animated: Bool) {
        navigationBackPassData(self)
    }
    
    // MARK: Button / Switch Target
    func switchValueChange(sender: UISwitch!){
//        allSections[sender.tag].on = sender.on
    }
    
    // MARK: Navigation
    func navigationBackPassData(sender: AnyObject) {
        // do the things
        self.delegate?.sendDataBack("Text")
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
        
        if indexPath.section == 0 || indexPath.section == 1 {
            let advCell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(DMBAdvSearchTableViewCell), forIndexPath: indexPath) as! DMBAdvSearchTableViewCell
            advCell.nameLabel.text = allSections[indexPath.section][indexPath.row].type
            advCell.activateSwitch.tag = indexPath.row
            advCell.activateSwitch.addTarget(self, action: "switchValueChange:", forControlEvents: UIControlEvents.ValueChanged)
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
    }

}
