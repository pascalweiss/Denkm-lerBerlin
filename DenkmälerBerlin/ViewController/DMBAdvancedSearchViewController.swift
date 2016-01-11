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
    
    var monumentType: [String] = ["Baudenkmal"]
    
    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(DMBAdvSearchTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(DMBAdvSearchTableViewCell))
        
    }

    override func viewWillDisappear(animated: Bool) {
        navigationBackPassData(self)
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
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if (indexPath.section == 0){
            let advCell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(DMBAdvSearchTableViewCell), forIndexPath: indexPath) as! DMBAdvSearchTableViewCell
            
            advCell.nameLabel.text = monumentType[indexPath.row]
            
            cell = advCell
        }
        

        return cell
    }


}
