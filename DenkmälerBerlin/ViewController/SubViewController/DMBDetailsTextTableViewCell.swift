//
//  DMBDetailsTextTableViewCell.swift
//  DenkmälerBerlin
//
//  Created by JulianMcCloud on 11.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import UIKit

class DMBDetailsTextTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var btnMoreText: UIButton!
    @IBOutlet weak var tvDescriptionText: UITextView!
    @IBOutlet weak var labelDescriptionHeading: UILabel!
    var superViewController: UIViewController!;
    var fullText: String!;
    
    func passControllerReference(controller: UIViewController){
        self.superViewController = controller;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tvDescriptionText.text = "Leider keine Beschreibung verfügbar.";
        self.btnMoreText.enabled = false;
    }

    @IBAction func buttonWasTouched(sender: AnyObject) {
        NSLog("Button pressed");
        // Construct Modal showing the full description text
        // measures
        let deviceWidth = UIScreen.mainScreen().bounds.width;
        let deviceHeight = UIScreen.mainScreen().bounds.height;
        let modalViewController: UIViewController = UIViewController.init();
        // modal Stuff
        modalViewController.view.frame = CGRect(x: 0, y: 0, width: deviceWidth, height: deviceHeight);
        modalViewController.modalTransitionStyle = .CoverVertical;
        modalViewController.modalPresentationStyle = .CurrentContext;
        modalViewController.view.backgroundColor = UIColor.whiteColor();
        modalViewController.view.opaque = false;
        
        // Header
        let headerLabel: UILabel = UILabel.init(frame: CGRect(x: 0, y: 20, width: deviceWidth, height: 44));
        headerLabel.backgroundColor = UIColor.lightGrayColor();
        let titleLabel: UILabel = UILabel.init(frame: CGRect(x: 10, y: 30, width: 0, height: 44));
        let font = UIFont.boldSystemFontOfSize(18);
        titleLabel.font = font;
        titleLabel.text = "Beschreibung";
        titleLabel.sizeToFit();
        modalViewController.view.addSubview(headerLabel);
        modalViewController.view.addSubview(titleLabel);
        
        // Button
        let button: UIButton = UIButton.init(type: UIButtonType.System);
        button.frame = CGRect(x: deviceWidth - 44, y: 25, width: 0, height: 44);
        button.addTarget(self, action: "dismissmodal:", forControlEvents: UIControlEvents.TouchUpInside);
        button.setTitle("Fertig", forState: UIControlState.Normal);
        button.titleLabel?.adjustsFontSizeToFitWidth = true;
        button.sizeToFit();
        modalViewController.view.addSubview(button);
        
        // Text Element
        let textView: UITextView = UITextView.init(frame: CGRect(x: 10, y: 64, width: deviceWidth - 10, height: 0));
        textView.text = fullText;
        textView.editable = false;
        textView.sizeToFit();
        modalViewController.view.addSubview(textView);
        
        //display it
        superViewController.presentViewController(modalViewController, animated: true, completion: { () -> Void in });
        
    }
    
    func dismissmodal(sender: AnyObject){
        NSLog("Dismiss hit");
        superViewController.dismissViewControllerAnimated(true, completion: { () -> Void in });
    }
    
}
