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
    self.module.addObserver(self, forKeyPath: "errorMessages", options: [.new], context: nil)
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
    module.removeObserver(self, forKeyPath: "errorMessages")
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.module.errorMessages == nil ? 1 : 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 1 || self.module.errorMessages == nil) {
      return self.module.keys.count
    } else {
      return self.module.errorMessages!.count
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (section == 1 || self.module.errorMessages == nil) {
      return "Values"
    } else {
      return "Errors"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
    if (indexPath.section == 1 || self.module.errorMessages == nil) {
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
    } else {
      cell.textLabel?.text = self.module.errorMessages![indexPath.row]
    }
    return cell
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    self.tableView.reloadData()
  }

}
