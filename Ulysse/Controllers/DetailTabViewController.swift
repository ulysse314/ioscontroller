import UIKit

class DetailDomainViewController: UITableViewController {
  
  let boatComponentButtonItem: BoatComponentButtonItem
  var errors: Array<BoatComponentError> = [BoatComponentError]()

  @objc required public init(boatComponentButtonItem: BoatComponentButtonItem) {
    self.boatComponentButtonItem = boatComponentButtonItem
    super.init(nibName: nil, bundle: nil)
    self.title = self.boatComponentButtonItem.name
    for boatComponent in self.boatComponentButtonItem.boatComponents {
      NotificationCenter.default.addObserver(self, selector: #selector(self.boatComponentValuesDidUpdate), name:NSNotification.Name(rawValue: BoatComponentButtonItem.ValuesUpdated), object: boatComponent)
    }
    updateErrors()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError("init(coder:) has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - TableView

  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.boatComponentButtonItem.boatComponents.count + (self.errors.count == 0 ? 0 : 1)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section > 0 || self.errors.count == 0 {
      let moduleIndex: Int = self.errors.count == 0 ? section : (section - 1)
      return self.boatComponentButtonItem.boatComponents[moduleIndex].values.count
    } else {
      return self.errors.count
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section > 0 || self.errors.count == 0 {
      let moduleIndex: Int = self.errors.count == 0 ? section : (section - 1)
      return self.boatComponentButtonItem.boatComponents[moduleIndex].name
    } else {
      return "Errors"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
    let moduleIndex: Int = self.errors.count == 0 ? indexPath.section : (indexPath.section - 1)
    if moduleIndex >= 0 {
      let module: BoatComponent = self.boatComponentButtonItem.boatComponents[moduleIndex]
      let key: String = module.sortedKeys[indexPath.row]
      cell.textLabel?.text = module.humanKey(key: key)
      let value = module.humanValue(key: key, short: false)
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
      cell.textLabel?.text = self.errors[indexPath.row].message
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  // MARK: - BoatComponentButtonItem notification

  @objc func boatComponentValuesDidUpdate(_ notification: Notification) {
    updateErrors()
    self.tableView.reloadData()
  }

  // MARK: Private

  func updateErrors() {
    self.errors.removeAll()
    for boatComponent in self.boatComponentButtonItem.boatComponents {
      self.errors += boatComponent.errors
    }
  }

}
