//
//  DMBDetailsTableViewCell.swift
//  DenkmälerBerlin
//
//  Created by JulianMcCloud on 11.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit

class DMBDetailsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var labelPropertyHeading: UILabel!
    @IBOutlet weak var labelPropertyValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.labelPropertyValue.text = "Leider keine Daten dazu vorhanden :/";
    }

}
