// Different way to register tableView cells. Inspired by iOS-OSS application.
// what you only need to set cell reuse identifier in xib file as it's class name. 

import UIKit

public enum Nib: String {
  case BackerDashboardEmptyStateCell
}

extension UITableView {
  public func register(nib: Nib) {
    self.register(UINib(nibName: nib.rawValue, bundle: nil), forCellReuseIdentifier: nib.rawValue)
  }
}

let tableView = UITableView()
tableView.register(.BackerDashboardEmptyStateCell)