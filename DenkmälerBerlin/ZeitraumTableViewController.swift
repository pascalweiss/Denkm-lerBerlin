//
//  ZeitraumTableViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 31.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit

class ZeitraumTableViewController: UITableViewController {
    
    @IBOutlet weak var lab_startDetail: UILabel!
    @IBOutlet weak var lab_endDetail: UILabel!
    
    @IBOutlet weak var tc_startCell: UITableViewCell!
    @IBOutlet weak var tc_endCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog(String(indexPath))
        
        
        
    }
    
    
}
