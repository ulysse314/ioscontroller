import UIKit

class DetailDomainViewController: UITableViewController {
  
  var moduleDomain: ModuleDomain

  @objc required public init(moduleDomain: ModuleDomain) {
    self.moduleDomain = moduleDomain
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.moduleDomainValuesDidUpdate), name: NSNotification.Name(rawValue: ModuleDomain.ValuesUpdated), object: moduleDomain)
    self.title = self.moduleDomain.name
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError("init(coder:) has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - TableView

  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.moduleDomain.modules.count + (self.moduleDomain.errors.count == 0 ? 0 : 1)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section > 0 || self.moduleDomain.errors.count == 0 {
      let moduleIndex: Int = self.moduleDomain.errors.count == 0 ? section : (section - 1)
      return self.moduleDomain.modules[moduleIndex].values.count
    } else {
      return self.moduleDomain.errors.count
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section > 0 || self.moduleDomain.errors.count == 0 {
      let moduleIndex: Int = self.moduleDomain.errors.count == 0 ? section : (section - 1)
      return self.moduleDomain.modules[moduleIndex].name
    } else {
      return "Errors"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
    let moduleIndex: Int = self.moduleDomain.errors.count == 0 ? indexPath.section : (indexPath.section - 1)
    if moduleIndex >= 0 {
      let module: Module = self.moduleDomain.modules[moduleIndex]
      let key: String = module.sortedKeys[indexPath.row]
      cell.textLabel?.text = key
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
      cell.textLabel?.text = self.moduleDomain.errors[indexPath.row].message
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  // MARK: - ModuleDomain notification

  @objc func moduleDomainValuesDidUpdate(_ notification: Notification) {
    self.tableView.reloadData()
  }

}
