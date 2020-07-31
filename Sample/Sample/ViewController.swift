//
//  ViewController.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class ViewController: UIViewController {
    
    private let cellIdentifierForType:[String:String] = [
        "h1" : TextTableSectionHeaderView.identifier(),
        "h2" : TextTableSectionHeaderView.identifier(),
        "f2" : TextTableSectionFooterView.identifier(),
        "r1" : TextTableViewCell.identifier(),
        "r2" : ButtonTableViewCell.identifier()
    ]
    
    private var sections:[P9TableViewHandler.Section] = []
    private let handler:P9TableViewHandler = P9TableViewHandler()
    
    let tableView = UITableView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        handler.delegate = self
        handler.standby(identifier:"list", cellIdentifierForType: cellIdentifierForType, tableView: tableView)
        handler.registerCallback(callback: thumbnailTouch(data:extra:), forCellIdentifier: ButtonTableViewCell.identifier(), withEventIdentifier: EventId.thumbnailTouch.rawValue)
        
        loadSampleData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(x: view.safeAreaInsets.left,
                                 y: view.safeAreaInsets.top,
                                 width: view.bounds.size.width-(view.safeAreaInsets.left+view.safeAreaInsets.right),
                                 height: view.bounds.size.height-(view.safeAreaInsets.top+view.safeAreaInsets.bottom))
    }
    
    func loadSampleData() {
        
        guard let url = Bundle.main.url(forResource: "list", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let list = jsonObject["payload"] as? [[String:Any]] else {
                return
        }
        
        sections.removeAll()
        
        for s in list {
            if let r = s["records"] as? [[String:Any]] {
                var records:[P9TableViewHandler.Record] = []
                for i in r {
                    if let type = i["type"] as? Int {
                        records.append(P9TableViewHandler.Record(type: "r\(type)", data: i, extra: nil))
                    }
                }
                let sectionType = s["type"] as? Int ?? 0
                switch sectionType {
                case 1 :
                    sections.append(P9TableViewHandler.Section(headerType: "h\(sectionType)", headerData: s, footerType: nil, footerData: nil, records: records, extra: nil))
                case 2 :
                    sections.append(P9TableViewHandler.Section(headerType: "h\(sectionType)", headerData: s, footerType: "f\(sectionType)", footerData: s, records: records, extra: nil))
                default :
                    sections.append(P9TableViewHandler.Section(headerType: nil, headerData: nil, footerType: nil, footerData: nil, records: records, extra: nil))
                }
            }
        }
        
        handler.sections = sections
        tableView.reloadData()
    }
}

extension ViewController {
    
    func thumbnailTouch(data:Any?, extra:Any?) {
        
        print("thumbnailTouch")
    }
}

extension ViewController: P9TableViewHandlerDelegate {
    
    func tableViewHandlerCellDidSelect(handlerIdentifier: String, cellIdentifier: String, indexPath: IndexPath, data: Any?, extra: Any?) {
        
        print("handler \(handlerIdentifier) cell \(cellIdentifier) indexPath \(indexPath.section):\(indexPath.row) did select")
    }
    
    func tableViewHandlerCellEvent(handlerIdentifier: String, cellIdentifier:String, eventIdentifier:String?, data: Any?, extra: Any?) {
        
        print("handler \(handlerIdentifier) cell \(cellIdentifier) event \(eventIdentifier ?? "")")
    }
}
