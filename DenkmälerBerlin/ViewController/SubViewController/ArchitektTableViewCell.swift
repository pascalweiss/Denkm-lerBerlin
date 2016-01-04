//
//  ArchitektTableViewCell.swift
//  DenkmälerBerlin
//
//  Created by Max on 31.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit

class ArchitektTableViewCell: UITableViewCell {
    @IBOutlet weak var lab_name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
