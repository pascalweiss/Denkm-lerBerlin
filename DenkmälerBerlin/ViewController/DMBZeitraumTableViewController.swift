//
//  ZeitraumTableViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 31.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit

class DMBZeitraumTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var lab_startDetail: UILabel!
    @IBOutlet weak var lab_endDetail: UILabel!
    
    @IBOutlet weak var tc_startCell: UITableViewCell!
    @IBOutlet weak var tc_endCell: UITableViewCell!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerDataSourceYears: [[Int]] = []
    var pickerChoosenDate: [Int] // 20 und 15 sind default werte
    
    var filterView: DMBFilterViewController?
    
    required init?(coder aDecoder: NSCoder) {
        pickerChoosenDate = [20, 1, 5]
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
            
        for i in 0...2 {
            pickerDataSourceYears.append([])
            
            for j in 0...30 {
                if (i == 0 && j <= 21) || (i != 0 && j <= 9) {
                    pickerDataSourceYears[i].append(j)
                }
                
            }
        }
        pickerView.selectRow(20, inComponent: 0, animated: false)
        pickerView.selectRow(1, inComponent: 1, animated: false)
        pickerView.selectRow(5, inComponent: 2, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog(String(indexPath))
        
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSourceYears[component].count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerDataSourceYears[component][row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerChoosenDate[component] = pickerDataSourceYears[component][row]
        lab_startDetail.text =  String(pickerChoosenDate[0]) + String(pickerChoosenDate[1])  + String(pickerChoosenDate[2])
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0..<1: return 100
        case 1..<2: return 30
        default: return 40
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSLog(segue.identifier!)
    }
    
    // MARK: Actions
    override func willMoveToParentViewController(parent: UIViewController?) {
        
        if parent == nil && filterView != nil {
            print("Button pressed")
            filterView!.startZeitraumValue = getBuildZeitIntegerFromArray(pickerChoosenDate)
            

        } else {
            let parentNavigationController = parent as! UINavigationController
            filterView = parentNavigationController.viewControllers[parentNavigationController.viewControllers.count-2] as! DMBFilterViewController
        }
        
        
    }
    
    // MARK: Get Functions
    
    func getBuildZeitIntegerFromArray(zeitIntegerArray: [Int]) -> Int {
        let zeitString = String(zeitIntegerArray[0]) + String(zeitIntegerArray[1]) + String(zeitIntegerArray[2])
        return Int(zeitString)!
    }
}
