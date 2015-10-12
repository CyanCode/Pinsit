//
//  QueryTableViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 9/4/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse
import INSPullToRefresh

class QueryTableViewController: UITableViewController, QueryTableViewControllerDelegate {
    /// Objects displayed on tableView
    var objects = [PFObject]()
    
    /// Amount of objects to load on every load
    var objectsPerPage = 25
    
    /// Should the tableview load it's content from an array column?
    var loadFromArrayColumn: String? = nil
    
    /// The array from a column from the database
    private var columnContent: [AnyObject]?
    
    //MARK: TableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.ins_addPullToRefreshWithHeight(60, handler: { (scrollView) -> Void in
            self.loadObjects({ () -> Void in
                self.tableView.ins_endPullToRefresh()
            })
        })
        
        self.tableView.ins_addInfinityScrollWithHeight(60, handler: { (scrollView) -> Void in
            self.objectsPerPage += 25
            self.loadObjects({ () -> Void in
                self.tableView.ins_endInfinityScroll()
            })
        })
        
        self.tableView.ins_infiniteScrollBackgroundView.addSubview(INSDefaultPullToRefresh())
        self.tableView.ins_pullToRefreshBackgroundView.addSubview(INSDefaultInfiniteIndicator())
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loadFromArrayColumn != nil {
            return columnContent != nil ? columnContent!.count : 0
        } else {
            return objects.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if loadFromArrayColumn != nil {
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, content: columnContent != nil ? columnContent![indexPath.row] : "")
        } else {
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, object: objects[indexPath.row])
        }
    }
    
    func loadObjects() {
        loadObjects { () -> Void in }
    }
    
    private func loadObjects(done: () -> Void) {
        let query = queryForTableView()
        query.limit = objectsPerPage
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if objects == nil || objects!.count == 0 { done(); return } //Nothing we can do here
            
            if error != nil {
                 self.objectsDidFailToLoad(error)
            } else {
                if self.loadFromArrayColumn != nil {
                    print("Attempting to load from column: \(self.loadFromArrayColumn!)")
                    self.columnContent = objects![0][self.loadFromArrayColumn!] as? [AnyObject]
                } else {
                    self.objects = objects!
                }
                
                self.objectsDidLoadSuccessfully()
                self.tableView.reloadData()
            }
            
            done()
        }
    }
    
    //MARK: Overriden
    
    func objectsDidFailToLoad(error: NSError?) {
        print("objects failed to load: \(error?.localizedDescription)", terminator: "")
    }
    
    func objectsDidLoadSuccessfully() {
        print("objects loaded successfully", terminator: "")
    }
    
    func objectsWillLoad() {
        print("objects will load", terminator: "")
    }
    
    func queryForTableView() -> PFQuery {
        fatalError("queryForTableView must be overriden in order for QueryTableViewController to work")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, content: AnyObject) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

protocol QueryTableViewControllerDelegate: class {
    func objectsDidFailToLoad(error: NSError?)
    func objectsDidLoadSuccessfully()
    func objectsWillLoad()
    func queryForTableView() -> PFQuery
}
