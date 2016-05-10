//
//  InventoryListTableViewController.swift
//  Grocr
//
//  Created by solidstone on 5/10/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class InventoryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let ListToUsers = "ListToUsers"
    
    // MARK: Properties
    var items = [InventoryItem]()
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    let ref = Firebase(url: "https://containers.firebaseio.com/grocery-items")
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up swipe to delete
        tableView.allowsMultipleSelectionDuringEditing = false
        
        // User Count
        userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
        userCountBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        user = User(uid: "Generic", email: "Storage@inventory.thing")
    }
    
    // * synchronize data table view
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            var newItems = [InventoryItem]()
            for item in snapshot.children {
                let inventoryItem = InventoryItem(snapshot: item as! FDataSnapshot)
                newItems.append(inventoryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                self.user = User(authData: authData)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as UITableViewCell!
        let inventoryItem = items[indexPath.row]
        
        cell.textLabel?.text = inventoryItem.name
        cell.detailTextLabel?.text = inventoryItem.addedByUser
        
        // Determine whether the cell is checked
        toggleCellCheckbox(cell, isCompleted: inventoryItem.completed)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // 1
            let inventoryItem = items[indexPath.row]
            // 2
            inventoryItem.ref?.removeValue()
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 1
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        // 2
        var inventoryItem = items[indexPath.row]
        // 3
        let toggledCompletion = !inventoryItem.completed
        // 4
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        // 5
        inventoryItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
    }
    func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(sender: AnyObject) {
        // Alert View for input
        var alert = UIAlertController(title: "Container",
            message: "Add an Item",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Add",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                // 1
                let textField = alert.textFields![0] as UITextField!
                
                // 2
                let inventoryItem = InventoryItem(name: textField.text!, addedByUser: self.user.email, completed: false)
                
                // 3
                let inventoryItemRef = self.ref.childByAppendingPath(textField.text!.lowercaseString)
                
                // 4
                inventoryItemRef.setValue(inventoryItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    func userCountButtonDidTouch() {
        performSegueWithIdentifier(ListToUsers, sender: nil)
    }
    
}
