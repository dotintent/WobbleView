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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        return cell
    }
}
