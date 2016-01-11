//
//  TableHeaderView.swift
//  DenkmälerBerlin
//
//  Created by Max on 05.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit

class DMBSearchResultsHeaderView: UITableViewHeaderFooterView {
    
    let mapViewSender: MapViewController
    let section: Int
    
    init(reuseIdentifier: String?, forMapView mapViewSender: MapViewController, forSection section: Int) {
        self.section = section
        self.mapViewSender = mapViewSender
        super.init(reuseIdentifier: reuseIdentifier)
        
        let tableView = mapViewSender.searchResultsTableView.tableView
        
        
        if (section == 0){
            // Advanced Search Button
            let advancedSearchButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 130, y: self.frame.size.height, width: 130, height: 18))
            advancedSearchButton.setTitle("Erweiterte Suche >", forState: UIControlState.Normal)
            advancedSearchButton.titleLabel?.adjustsFontSizeToFitWidth = true
            advancedSearchButton.addTarget(mapViewSender, action: "segueToAdvancedSearchView:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.addSubview(advancedSearchButton)
        }
        
        if (mapViewSender.showHistory || (mapViewSender.filteredData.isEmpty || (section != 0 && mapViewSender.filteredData[section - 1].isEmpty && !mapViewSender.filteredData.isEmpty)) || section == 0) {
            return
        } else {
            
            if (section != 0 && mapViewSender.filteredData[section - 1].count > mapViewSender.maxRowNumberPerSection.0) { // 1 ändern!! Value ab dem "Mehr Anzeigen" gezeigt wird
                // Button
                let showMoreButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 105, y: self.frame.size.height, width: 100, height: 18))
                showMoreButton.setTitle("Mehr Anzeigen", forState: UIControlState.Normal)
                showMoreButton.titleLabel?.adjustsFontSizeToFitWidth = true
                showMoreButton.tag = section
                showMoreButton.addTarget(mapViewSender, action: "showMoreResultsButton:", forControlEvents: UIControlEvents.TouchUpInside)
                
                self.addSubview(showMoreButton)
            }
            
            return
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
