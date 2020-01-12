import Foundation

class PiModule: Module {

  override func humanKey(key: String) -> String {
    if key == "cpu%" {
      return "CPU %"
    } else if key == "disk.available" {
      return "Disk free MB"
    } else if key == "disk.size" {
      return "Disk size MB"
    } else if key == "disk.used" {
      return "Disk used MB"
    } else if key == "disk.used%" {
      return "Disk used %"
    } else if key == "dtsz" {
      return "Sent data size"
    } else if key == "ram.free" {
      return "Ram free MB"
    } else if key == "ram.used" {
      return "Ram used MB"
    } else if key == "ram.total" {
      return "Ram total MB"
    } else if key == "ram.used%" {
      return "Rame used %"
    } else if key == "temp" {
      return "Temperature"
    } else if key == "uplddrt" {
      return "Upload duration"
    } else if key == "lpdrt" {
      return "Loop duration"
    }
    return key
  }

}
