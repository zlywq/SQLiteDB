//
//  HomeViewController.swift
//  SQLiteDB-iOS
//
//  Created by zlywq on 15/1/19.
//  Copyright (c) 2014 RookSoft Pte. Ltd. and zlywq All rights reserved.
//

import Foundation


import Foundation

import UIKit

class ViewControllerHome: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    override func viewWillDisappear(animated: Bool) {
    }

    
    
    @IBAction func btnDoDBactionsClicked(sender: AnyObject) {
        
        var dbCon = DASqlite.singleton()
        dbCon.insertTable1("n1", age: 1, price: 1.2)
        dbCon.insertTable1("n2", age: 1, price: 2.3)
        var rows = dbCon.getTable1(1)
        printRows(rows)
        dbCon.deleteTable1("n1")
        NSLog("---------")
        rows = dbCon.getTable1(1)
        printRows(rows)
    }
    
    func printRows(rows:[SQLRow]){
        for row in rows{
            var name = row.cellValStr("name")
            var age = row.cellValInt("age")
            var price = row.cellValDouble("price")
            NSLog("name=\(name),age=\(age),price=\(price)")
        }
    }
    
    
    
    
    
    
    
    
}

