//
//  ViewController.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 07/04/15.
//  Copyright (c) 2015 inFullMobile. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        
        return cell
    }
}