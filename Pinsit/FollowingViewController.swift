//
//  FollowingViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/5/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet var tableView: UITableView!
    var names: [String]!
    var thumbnails: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.registerClass(CustomCell.self, forHeaderFooterViewReuseIdentifier: "cell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CustomCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as CustomCell
        cell.nameLabel.text = names[indexPath.row]
        cell.thumbnail.image = thumbnails[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: Toggle Menu
    func addGesture() {
        var edge = UIScreenEdgePanGestureRecognizer(target: self, action: "toggleMenu:")
        edge.edges = UIRectEdge.Right
        edge.delegate = self
        self.view.addGestureRecognizer(edge)
    }
    
    func toggleMenu(sender: UIGestureRecognizer) {
        let control = tabBarController
        (tabBarController as SidebarController).sidebar.showInViewController(self, animated: true)
    }
}
