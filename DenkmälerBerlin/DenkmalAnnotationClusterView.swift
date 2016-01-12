//  FBAnnotationClusterView.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//
//  Edited by Chris to DenkmalAnnotationClusterView.swift
//
//
//  Copyright © 2015 HTWBerlin. All rights reserved.

import Foundation
import MapKit
import Darwin

class DenkmalAnnotationClusterView : MKAnnotationView {
    
    var count = 0
    var fontSize:CGFloat = 12
    var imageName = "clusterSmall"
    var borderWidth:CGFloat = 3
    var countLabel:UILabel? = nil
    //var countOfDiffAnnotationTypes = 0
    var countOfDiffAnnotationTypes = [String:Int]()

    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let cluster:DenkmalAnnotationCluster = annotation as! DenkmalAnnotationCluster
        count = cluster.annotations.count
        countOfDiffAnnotationTypes = cluster.countOfAnnotationTyps
        
        // change the size of the cluster image based on number of stories
        switch count {
            case 0...20:
                fontSize = 12
                imageName = "clusterSmall"
                borderWidth = 3
            
            case 21...50:
                fontSize = 13
                imageName = "clusterMedium"
                borderWidth = 4
            
            default:
                fontSize = 14
                imageName = "clusterLarge"
                borderWidth = 5
            
        }
        
        backgroundColor = UIColor.clearColor()
        setupLabel()
        setTheCount(count)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    func setupLabel(){
        countLabel = UILabel(frame: bounds)
        
        if let countLabel = countLabel {
            countLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            countLabel.textAlignment = .Center
            countLabel.backgroundColor = UIColor.clearColor()
            countLabel.textColor = UIColor.whiteColor()
            countLabel.adjustsFontSizeToFitWidth = true
            countLabel.minimumScaleFactor = 2
            countLabel.numberOfLines = 1
            countLabel.font = UIFont.boldSystemFontOfSize(fontSize)
            countLabel.baselineAdjustment = .AlignCenters
            addSubview(countLabel)
        }
        
    }
    
    func setTheCount(localCount:Int){
        count = localCount;
        countLabel?.text = "\(localCount)"
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        // Images are faster than using drawRect:
        let imageAsset = UIImage(named: imageName)!
        
        countLabel?.frame = self.bounds
        image = imageAsset
        centerOffset = CGPointZero
    }
    
}