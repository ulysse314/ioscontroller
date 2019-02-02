//
//  ModuleViewController.swift
//  Ulysse
//
//  Copyright © 2019 Ulysse 314 Boat. All rights reserved.
//

import UIKit

class ModuleViewController: UITableViewController {
  
  var module: Module

  @objc required public init(module: Module) {
    self.module = module
    super.init(nibName: nil, bundle: nil)
    self.module.addObserver(self, forKeyPath: "values", options: [.new], context: nil)
    self.title = module.name
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError("init(coder:) has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    module.removeObserver(self, forKeyPath: "values")
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.module.keys.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
    let key = self.module.keys[indexPath.row]
    cell.textLabel?.text = key
    let value = self.module.values[key]
    if value is Int {
      cell.detailTextLabel?.text = String(value as! Int)
    } else if value is Float {
      cell.detailTextLabel?.text = String(value as! Float)
    } else if value is NSNumber {
      cell.detailTextLabel?.text = (value as! NSNumber).stringValue
    } else if value is NSNull {
      cell.detailTextLabel?.text = "<null>"
    } else if value is String {
      cell.detailTextLabel?.text = value as? String
    } else {
      cell.detailTextLabel?.text = "-"
    }
    return cell
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    self.tableView.reloadData()
  }

}
