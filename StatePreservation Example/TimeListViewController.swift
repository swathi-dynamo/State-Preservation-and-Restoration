//
//  TimeListViewController.swift
//  Clocks
//
//  Created by Swathi Dynamo on 2020-04-20.
//  Copyright © 2020 com.dynamo. All rights reserved.
//

import UIKit

class TimeListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    var observations = [NSObjectProtocol]()
    var sortedTimezones: [Timezone] = []
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = .timeListTitle
        tableView.register(UINib(nibName: .cellKey, bundle: nil),
                           forCellReuseIdentifier: .cellKey)
        observations += State.shared.addObserver(actionType: ListView.Action.self) {  state, action in
            if action == ListView.Action.scrolled {
                self.tableView.contentOffset.y = CGFloat(state.listView.scrollOffset)
            } else {
                self.tableView?.contentOffset.y = CGFloat(state.listView.scrollOffset)
                self.tableView.setEditing(state.listView.isEditing, animated: action != nil)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: state.listView.isEditing ? .done : .edit,
                                                                         target: self,
                                                                         action: #selector(self.editButton(_:)))
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                         target: self,
                                                                         action: #selector(self.addButton(_:)))
            }
        }
        observations += Utilities.shared.addObserver(actionType: Utilities.Action.self) { timezones, action in
            self.handleDocumentNotification(timezones: timezones, action: action)
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            if let s = self, let tv = s.tableView, let indexPaths = tv.indexPathsForVisibleRows {
                for indexPath in indexPaths {
                    if s.sortedTimezones.indices.contains(indexPath.row),
                        let cell = tv.cellForRow(at: indexPath) {
                        self?.updateDisplay(timezone: s.sortedTimezones[indexPath.row], completion: { (dateComponents) in
                            if let hour = dateComponents.hour, let min = dateComponents.minute, let sec = dateComponents.second  {
                                cell.detailTextLabel?.text = String(hour) + ":" + String(format: "%02ld", min) + ":" + String(format: "%02ld", sec)
                            }
                        })
                    }
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    func updateDisplay(timezone: Timezone, completion:(DateComponents) -> ())  {
        guard let tz = TimeZone(identifier: timezone.identifier) else { return completion(DateComponents()) }
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = tz
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        completion(dateComponents)
    }
    
    @objc func addButton(_ sender: Any?) {
        State.shared.changeViewVisibility(true)
    }
    
    @objc func editButton(_ sender: Any?) {
        State.shared.toggleEditModeOnMaster()
    }
    
    func updateSortedTimezones(timezones: Utilities.DataType) {
        sortedTimezones = Array(timezones.lazy.sorted { (left, right) -> Bool in
            return left.value.name < right.value.name
        }.map { $0.value })
    }
    
    func handleDocumentNotification(timezones: Utilities.DataType, action: Utilities.Action?) {
        switch action {
        case .added(let uuid)?:
            updateSortedTimezones(timezones: timezones)
            let index = sortedTimezones.firstIndex { $0.uuid == uuid }!
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        case .removed(let uuid)?:
            let index = sortedTimezones.firstIndex { $0.uuid == uuid }!
            updateSortedTimezones(timezones: timezones)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        case .updated(let uuid)?:
            let before = sortedTimezones.firstIndex { $0.uuid == uuid }!
            updateSortedTimezones(timezones: timezones)
            let after = sortedTimezones.firstIndex { $0.uuid == uuid }!
            if before != after {
                tableView.moveRow(at: IndexPath(row: before, section: 0), to: IndexPath(row: after, section: 0))
            }
            tableView.reloadRows(at: [IndexPath(row: after, section: 0)], with: .none)
        case .none:
            let previousTimezones = sortedTimezones.map { $0.uuid }
            updateSortedTimezones(timezones: timezones)
            if previousTimezones != sortedTimezones.map({ $0.uuid }) {
                tableView.reloadData()
            } else if let indexPaths = tableView.indexPathsForVisibleRows {
                tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
    }
    

}

extension TimeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.sortedTimezones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cellKey, for: indexPath)
        let timezone = sortedTimezones[indexPath.row]
        cell.textLabel?.text = timezone.name
        self.updateDisplay(timezone: timezone) { (dateComponents) in
            if let hour = dateComponents.hour, let min = dateComponents.minute, let sec = dateComponents.second {
                cell.detailTextLabel?.text = String(hour) + ":" + String(format: "%02ld", min) + ":" + String(format: "%02ld", sec)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        Utilities.shared.removeTimezone(sortedTimezones[indexPath.row].uuid)
    }
    
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        State.shared.scrollListView(offsetY: Double(tableView?.contentOffset.y ?? 0))
    }
    
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            State.shared.scrollListView(offsetY: Double(tableView?.contentOffset.y ?? 0))
        }
    }
}
