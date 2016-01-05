//
//  TableHeaderView.swift
//  DenkmälerBerlin
//
//  Created by Max on 05.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit

class DMBTableHeaderView: UIView {

    init(tableView: UITableView, viewForHeaderInSection section: Int, mapViewSender: MapViewController){
        super.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: mapViewSender.tableView(tableView, heightForHeaderInSection: section)))
        
        if (section == 0){
            // Advanced Search Button
            let tableViewFrame = self.frame
            let advancedSearchButton = UIButton(frame: CGRect(x: tableViewFrame.width - 130, y: 0, width: 130, height: 18))
            advancedSearchButton.setTitle("Erweiterte Suche >", forState: UIControlState.Normal)
            advancedSearchButton.titleLabel?.adjustsFontSizeToFitWidth = true
            advancedSearchButton.addTarget(mapViewSender, action: "segueToAdvancedSearchView:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.addSubview(advancedSearchButton)
        }
        
        if (mapViewSender.showHistory || (section != 0 && mapViewSender.filteredData[section - 1].isEmpty) || section == 0) {
            return
        } else {
            
            // Label
            let titleLabel = UILabel(frame: CGRect(x: 10, y: self.frame.size.height - 18, width: tableView.frame.size.width, height: 18))
            titleLabel.text = mapViewSender.tableView(tableView, titleForHeaderInSection: section)
            titleLabel.font = UIFont.boldSystemFontOfSize(12)
            
            self.addSubview(titleLabel)
            
            if (section != 0 && mapViewSender.filteredData[section - 1].count > 1) { // 1 ändern!! Value ab dem "Mehr Anzeigen" gezeigt wird
                // Button
                let showMoreButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 105, y: self.frame.size.height - 18, width: 100, height: 18))
                showMoreButton.setTitle("Mehr Anzeigen", forState: UIControlState.Normal)
                showMoreButton.titleLabel?.adjustsFontSizeToFitWidth = true
                showMoreButton.tag = section
                showMoreButton.addTarget(self, action: "showMoreResultsButton:", forControlEvents: UIControlEvents.TouchUpInside)
                
                self.addSubview(showMoreButton)
            }
            
            return
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
