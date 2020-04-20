//
//  State.swift
//  Clocks
//
//  Created by Swathi Dynamo on 2020-04-20.
//  Copyright © 2020 com.dynamo. All rights reserved.
//

import Foundation

class State {
    
	static let shared = State()
	private var rootView: LaunchView = LaunchView()
    
	func scrollListView(offsetY: Double) {
		rootView.listView.scrollOffset = offsetY
		commitAction(ListView.Action.scrolled)
	}
	
	func scrollAddTimeViewView(offsetY: Double) {
		rootView.addTimeView?.scrollOffset = offsetY
		commitAction(AddTimeView.Action.scrolled)
	}
		
	func toggleEditModeOnMaster() {
		rootView.listView.isEditing = !rootView.listView.isEditing
		commitAction(ListView.Action.changedEditMode)
	}
	
	func changeViewVisibility(_ visible: Bool) {
		if visible, rootView.addTimeView == nil {
			rootView.addTimeView = AddTimeView()
		} else {
			rootView.addTimeView = nil
		}
        commitAction(LaunchView.Action.addTimeViewVisibility)
	}
	
	func serialized() throws -> Data {
		return try JSONEncoder().encode(rootView)
	}
}

extension State: NotifyingStore {
	static let documentName = "State"
	typealias DataType = LaunchView
	var persistToUrl: URL? { return nil }
	var content: DataType { get { return rootView } }
    
	func loadWithoutNotifying(jsonData: Data) {
		do {
			rootView = try JSONDecoder().decode(DataType.self, from: jsonData)
		} catch {
		}
	}
}

struct LaunchView: Codable {
    
    enum Action {
        case addTimeViewVisibility
    }
    
    var listView: ListView
    var addTimeView: AddTimeView?
    
    init() {
        listView = ListView()
    }
}

struct ListView: Codable {
    
    enum Action {
        case scrolled
        case changedEditMode
    }
    
    var scrollOffset: Double = 0
    var isEditing: Bool = false
}

struct AddTimeView: Codable {
    
    enum Action {
        case scrolled
    }
    
    var scrollOffset: Double = 0
}

