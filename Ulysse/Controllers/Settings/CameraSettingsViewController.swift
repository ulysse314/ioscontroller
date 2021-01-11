import UIKit

class CameraSettingsViewController: UITableViewController {

  enum CameraSettingsSection: Int {
    case onOff = 0
    case stream
  }

  let streamNames = [ "twitch": "Twitch", "": "None" ]
  let streams = [ "twitch", "" ]
  let communication =  (UIApplication.shared.delegate as! AppDelegate).communication;
  let streamUserDefaultKey = "camera_stream"

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch CameraSettingsSection(rawValue: section) {
    case .onOff:
      return "Camera"
    case .stream:
      return "Streams"
    case .none:
      return ""
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch CameraSettingsSection(rawValue: section) {
    case .onOff:
      return 1
    case .stream:
      return streams.count
    case .none:
      return 0
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
    switch CameraSettingsSection(rawValue: indexPath.section) {
    case .onOff:
      cell.textLabel?.text = "Camera"
      let cameraInfo: Dictionary? = self.communication?.allValues?["camera"] as? Dictionary<String, Any?> ?? nil
      let boolNumber: NSNumber? = (cameraInfo?["state"] as? NSNumber ?? nil)
      let isCamearOn: Bool! = boolNumber?.boolValue ?? false
      cell.accessoryView = self.getSwitch(action: #selector(cameraAction), value: isCamearOn)
      break
    case .stream:
      let selectedStream = UserDefaults.standard.string(forKey: self.streamUserDefaultKey) ?? ""
      let cellStream = self.streams[indexPath.row]
      cell.textLabel?.text = self.streamNames[cellStream]
      cell.accessoryType = (selectedStream == cellStream) ? .checkmark : .none
      break
    case .none:
      break
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch CameraSettingsSection(rawValue: indexPath.section) {
    case .onOff:
      break
    case .stream:
      self.tableView.deselectRow(at: indexPath, animated: true)
      let cellStream = self.streams[indexPath.row]
      UserDefaults.standard.setValue(cellStream, forKey: self.streamUserDefaultKey)
      self.tableView.reloadSections(IndexSet.init(integer: CameraSettingsSection.stream.rawValue), with: .automatic)
      break
    case .none:
      break
    }
  }

  // MARK: - Private

  @objc func cameraAction(_ sender: UISwitch) {
    self.communication?.setValues([ "camera": [ "state": sender.isOn, "live_stream_name": "" ]])
  }

  func getSwitch(action: Selector, value: Bool) -> UISwitch {
    let result = UISwitch.init()
    result.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
    result.isOn = value
    return result
  }

}
