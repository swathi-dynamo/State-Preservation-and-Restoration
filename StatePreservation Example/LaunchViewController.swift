//
//  LaunchViewController.swift
//  Clocks
//
//  Created by Swathi Dynamo on 2020-04-20.
//  Copyright © 2020 com.dynamo. All rights reserved.
//



import UIKit

class LaunchViewController: UIViewController {
    
	var observations = [NSObjectProtocol]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        let masterViewController = TimeListViewController(nibName: "TimeListViewController", bundle: nil)
        self.navigationController?.pushViewController(masterViewController, animated: false)
        
        if observations.isEmpty {
            observations += State.shared.addObserver(actionType: LaunchView.Action.self) {  state, action in
                self.displayAddTimeZone(show: (state.addTimeView != nil),
                                        animated: (action == .addTimeViewVisibility),
                                             completion: nil)
           }
        }
        
	}
    
	func displayAddTimeZone(show: Bool, animated: Bool, completion: (() -> ())?) {
		if show && presentedViewController == nil {            
            let addTimeZone = AddTimeZoneViewController(nibName: "AddTimeZoneViewController", bundle: nil)
			self.present(addTimeZone, animated: animated, completion: completion)
		} else if !show && presentedViewController != nil {
			self.dismiss(animated: animated, completion: completion)
		} else {
			completion?()
		}
	}
	
}
