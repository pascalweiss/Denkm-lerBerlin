//
//  FilterViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 30.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit

class DMBFilterViewController : UITableViewController {
    
    @IBOutlet weak var labelZeitraumDetail: UILabel!
    
    var startZeitraumValue: Int = 0
    
    
    //MARK -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func viewDidAppear(animated: Bool) {
        labelZeitraumDetail.text = String(startZeitraumValue)
    }
    
}
