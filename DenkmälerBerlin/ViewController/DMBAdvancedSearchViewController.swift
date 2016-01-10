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

    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */


}
