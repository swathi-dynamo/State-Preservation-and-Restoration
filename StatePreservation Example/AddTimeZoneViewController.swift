//
//  AddTimeZoneViewController.swift
//  Clocks
//
//  Created by Swathi Dynamo on 2020-04-20.
//  Copyright © 2020 com.dynamo. All rights reserved.
//

import UIKit

class AddTimeZoneViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView? = nil
    @IBOutlet var navigationBar: UINavigationBar? = nil
    
    var observations = [NSObjectProtocol]()
    let timezones = TimeZone.knownTimeZoneIdentifiers.sorted()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = .addTimeZoneTitle
        self.tableView?.register(UINib(nibName: .cellKey, bundle: nil), forCellReuseIdentifier:.cellKey)
        
        observations += State.shared.addObserver(actionType: AddTimeView.Action.self) {  state, action in
            guard let sv = state.addTimeView else { return }
            self.tableView?.contentOffset.y = CGFloat(sv.scrollOffset)
        }
    }
        
    @IBAction func cancel(_ sender: Any?) {
        State.shared.changeViewVisibility(false)
    }
}

extension AddTimeZoneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timezones.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow, timezones.indices.contains(indexPath.row) {
            Utilities.shared.addTimezone(timezones[indexPath.row])
        }
        State.shared.changeViewVisibility(false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cellKey, for: indexPath)
        cell.textLabel?.text = timezones[indexPath.row]
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        State.shared.scrollAddTimeViewView(offsetY: Double(tableView?.contentOffset.y ?? 0))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            State.shared.scrollAddTimeViewView(offsetY: Double(tableView?.contentOffset.y ?? 0))
        }
    }
}
