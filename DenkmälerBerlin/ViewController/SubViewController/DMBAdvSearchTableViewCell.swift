//
//  DMBAdvSearchTableViewCell.swift
//  DenkmälerBerlin
//
//  Created by Max on 10.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit

class DMBAdvSearchTableViewCell: UITableViewCell {
    
    var nameLabel: UILabel!
    var activateSwitch: UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // TextLabel
        nameLabel = super.textLabel
        
        contentView.addSubview(nameLabel)
        
        //Switch
        activateSwitch = UISwitch()
        activateSwitch.center.y = contentView.center.y
        activateSwitch.onTintColor = UIColor.blueColor()
        activateSwitch.on = true
        
        accessoryView = activateSwitch
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
