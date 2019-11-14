//
//  P9TableViewHandler.swift
//
//
//  Created by Tae Hyun Na on 2019. 5. 14.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

protocol P9TableViewCellDelegate: class {
    
    func tableViewCellEvent(cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?)
}

protocol P9TableViewCellProtocol: class {
    
    static func identifier() -> String
    static func instanceFromNib() -> UIView
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9TableViewCellDelegate)
}

extension P9TableViewCellProtocol {
    
    static func identifier() -> String {
        
        return String(describing: type(of: self)).components(separatedBy: ".").first ?? ""
    }
    
    static func instanceFromNib() -> UIView {
        
        return Bundle.main.loadNibNamed(identifier(), owner: nil, options: nil)?[0] as! UIView
    }
    
    func setDelegate(_ delegate:P9TableViewCellDelegate) {}
}

protocol P9TableViewHandlerDelegate: class {
    
    func tableViewHandlerWillBeginDragging(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    func tableViewHandlerDidScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    func tableViewHandlerDidEndScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
//    func tableViewHandler(handlerIdentifier:String, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
//    func tableViewHandler(handlerIdentifier:String, willDisplayHeaderView view: UIView, forSection section: Int)
//    func tableViewHandler(handlerIdentifier:String, willDisplayFooterView view: UIView, forSection section: Int)
//    func tableViewHandler(handlerIdentifier:String, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
//    func tableViewHandler(handlerIdentifier:String, didEndDisplayingHeaderView view: UIView, forSection section: Int)
//    func tableViewHandler(handlerIdentifier:String, didEndDisplayingFooterView view: UIView, forSection section: Int)
    func tableViewHandlerCellDidSelect(handlerIdentifier:String, cellIdentifier:String, indexPath:IndexPath, data:Any?, extra:Any?)
    func tableViewHandlerCellEvent(handlerIdentifier:String, cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?)
}

extension P9TableViewHandlerDelegate {
    
    func tableViewHandlerWillBeginDragging(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint) {}
    func tableViewHandlerDidEndScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint) {}
    func tableViewHandlerDidScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint) {}
    func tableViewHandlerCellDidSelect(handlerIdentifier:String, cellIdentifier:String, indexPath:IndexPath, data:Any?, extra:Any?) {}
    func tableViewHandlerCellEvent(handlerIdentifier:String, cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?) {}
}

open class P9TableViewHandler: NSObject {
    
    @objc(P9TableViewRecord) public class Record : NSObject {
        var type:String
        var data:Any?
        var extra:Any?
        @objc public init(type:String, data:Any?, extra:Any?=nil) {
            self.type = type
            self.data = data
            self.extra = extra
        }
    }
    
    @objc(P9TableViewSection) public class Section : NSObject {
        var headerType:String?
        var headerData:Any?
        var footerType:String?
        var footerData:Any?
        var extra:Any?
        var records:[Record]?
        @objc public init(headerType:String?, headerData:Any?, footerType:String?, footerData:Any?, records:[Record]?, extra:Any?) {
            self.headerType = headerType
            self.headerData = headerData
            self.footerType = footerType
            self.footerData = footerData
            self.records = records
            self.extra = extra
        }
    }
    
    fileprivate let moduleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    fileprivate var handlerIdentifier:String = ""
    fileprivate var cellIdentifierForType:[String:String] = [:]
    fileprivate var sections:[Section] = []
    
    weak var delegate:P9TableViewHandlerDelegate?
    
    func standby(identifier:String, cellIdentifierForType:[String:String], tableView:UITableView) {
        
        handlerIdentifier = identifier
        self.cellIdentifierForType = cellIdentifierForType
        self.cellIdentifierForType.forEach { (key, value) in
            tableView.register(UINib.init(nibName: value, bundle: nil), forCellReuseIdentifier: value)
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setSections(sections:[Section]) {
        
        self.sections = sections
    }
}

extension P9TableViewHandler: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].headerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName),
            let tableViewCellContentsCell = cls as? P9TableViewCellProtocol.Type else {
                return CGFloat.leastNormalMagnitude
        }
        
        return tableViewCellContentsCell.cellHeightForData(sections[section].headerData, extra: sections[section].extra)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].headerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName),
            let tableViewCellContentsCell = cls as? P9TableViewCellProtocol.Type else {
                return nil
        }
        
        let view = tableViewCellContentsCell.instanceFromNib()
        (view as? P9TableViewCellProtocol)?.setData(sections[section].headerData, extra: sections[section].extra)
        (view as? P9TableViewCellProtocol)?.setDelegate(self)
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].footerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName),
            let tableViewCellContentsCell = cls as? P9TableViewCellProtocol.Type else {
                return CGFloat.leastNormalMagnitude
        }
        
        return tableViewCellContentsCell.cellHeightForData(sections[section].footerData, extra: sections[section].extra)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].footerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName),
            let tableViewCellContentsCell = cls as? P9TableViewCellProtocol.Type else {
                return nil
        }
        
        let view = tableViewCellContentsCell.instanceFromNib()
        (view as? P9TableViewCellProtocol)?.setData(sections[section].footerData, extra: sections[section].extra)
        (view as? P9TableViewCellProtocol)?.setDelegate(self)
        return view
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard section >= 0, section < sections.count else {
            return 0
        }
        return sections[section].records?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count,
              let clsName = cellIdentifierForType[records[indexPath.row].type], clsName.count > 0,
              let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName),
              let tableViewCellContentsCell = cls as? P9TableViewCellProtocol.Type else {
            return 0
        }
        
        return tableViewCellContentsCell.cellHeightForData(records[indexPath.row].data, extra: records[indexPath.row].extra)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count,
              let clsName = cellIdentifierForType[records[indexPath.row].type], clsName.count > 0 else {
                return UITableViewCell.init(frame: .zero)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: clsName, for: indexPath)
        if let tableViewCellContentsCell = cell as? P9TableViewCellProtocol {
            tableViewCellContentsCell.setData(records[indexPath.row].data, extra: records[indexPath.row].extra)
            tableViewCellContentsCell.setDelegate(self)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count else {
                return
        }
        
        let cellIdentifier = cellIdentifierForType[records[indexPath.row].type] ?? records[indexPath.row].type
        delegate?.tableViewHandlerCellDidSelect(handlerIdentifier: handlerIdentifier, cellIdentifier: cellIdentifier, indexPath: indexPath, data: records[indexPath.row].data, extra: records[indexPath.row].extra)
    }
}

extension P9TableViewHandler: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        delegate?.tableViewHandlerWillBeginDragging(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.tableViewHandlerDidScroll(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            delegate?.tableViewHandlerDidEndScroll(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        delegate?.tableViewHandlerDidEndScroll(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
}

extension P9TableViewHandler: P9TableViewCellDelegate {
    
    public func tableViewCellEvent(cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?) {
        
        delegate?.tableViewHandlerCellEvent(handlerIdentifier: handlerIdentifier, cellIdentifier:cellIdentifier, eventIdentifier: eventIdentifier, data: data, extra: extra)
    }
}
