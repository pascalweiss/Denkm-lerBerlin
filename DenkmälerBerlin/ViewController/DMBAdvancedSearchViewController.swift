//
//  AdvancedSearchViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 05.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit

protocol DMBAdvancedSearchDelegate {
    func sendDataBack(data: String)
}

class DMBAdvancedSearchViewController: UITableViewController {
    
    var delegate: DMBAdvancedSearchDelegate?
    
    var monumentType: [(type: String,on: Bool)] = [("Baudenkmal", true), ("Garten- /Parkdenkmal", true), ("Bodendenkmal", true)]
    
    // MARK: Elemente fuer Range Slider
    let customRangeSlider = RangeSlider(frame: CGRectZero)
    let labelLowerValue = UILabel()
    let labelUpperValue = UILabel()
    
    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(DMBAdvSearchTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(DMBAdvSearchTableViewCell))
        
        // Range Slider inklusive Wertanzeige in View einbinden
        // Do any additional setup after loading the view, typically from a nib.
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
        let width = view.bounds.width - 2.0 * margin
        let height: CGFloat = 31.0;
        
        customRangeSlider.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 100, width: width, height: height)
        
        labelLowerValue.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 100 + height, width: 200, height: height)
        labelLowerValue.textAlignment = NSTextAlignment.Left;
        
        labelUpperValue.frame = CGRect(x: view.frame.size.width - margin - 200, y: margin + topLayoutGuide.length + 100 + height, width: 200, height: height)
        labelUpperValue.textAlignment = NSTextAlignment.Right;
        
    }

    override func viewWillDisappear(animated: Bool) {
        navigationBackPassData(self)
    }
    
    // MARK: Button / Switch Target
    
    func switchValueChange(sender: UISwitch!){
        monumentType[sender.tag].on = sender.on
    }
    
    
    // MARK: Navigation
    func navigationBackPassData(sender: AnyObject) {
        // do the things
        self.delegate?.sendDataBack("Text")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return monumentType.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if (indexPath.section == 0){
            let advCell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(DMBAdvSearchTableViewCell), forIndexPath: indexPath) as! DMBAdvSearchTableViewCell
            
            advCell.nameLabel.text = monumentType[indexPath.row].type
            advCell.activateSwitch.tag = indexPath.row
            advCell.activateSwitch.addTarget(self, action: "switchValueChange:", forControlEvents: UIControlEvents.ValueChanged)
            
            cell = advCell
        }
        

        return cell
    }
    
    // MARK: Kann die raus???
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Veraenderte Position Schieberegler des Range Sliders holen
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
        
        labelLowerValue.text = "\(Int(rangeSlider.lowerValue))"
        labelUpperValue.text = "\(Int(rangeSlider.upperValue))"
    }

}
