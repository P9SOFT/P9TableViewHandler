//
//  P9TableViewHandler.swift
//
//
//  Created by Tae Hyun Na on 2019. 5. 14.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

@objc public protocol P9TableViewCellDelegate: class {
    
    func tableViewCellEvent(cellIdentifier:String, eventIdentifier:String?, indexPath:IndexPath?, data:Any?, extra:Any?)
}

public protocol P9TableViewCellProtocol: class {
    
    static func identifier() -> String
    static func instanceFromNib() -> UIView?
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9TableViewCellDelegate)
    func setIndexPath(_ indexPath: IndexPath)
}

public extension P9TableViewCellProtocol {
    
    static func identifier() -> String {
        
        return String(describing: type(of: self)).components(separatedBy: ".").first ?? ""
    }
    
    static func instanceFromNib() -> UIView? {
        
        return Bundle.main.loadNibNamed(identifier(), owner: nil, options: nil)?[0] as? UIView
    }
    
    func setDelegate(_ delegate:P9TableViewCellDelegate) {}
    
    func setIndexPath(_ indexPath: IndexPath) {}
}

@objc public protocol P9TableViewCellObjcProtocol: class {
    
    static func identifier() -> String
    static func instanceFromNib() -> UIView?
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9TableViewCellDelegate)
    func setIndexPath(_ indexPath: IndexPath)
}

@objc public protocol P9TableViewHandlerDelegate: class {
    
    @objc optional func tableViewHandlerWillBeginDragging(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func tableViewHandlerDidScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func tableViewHandlerDidEndScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func tableViewHandler(handlerIdentifier:String, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func tableViewHandler(handlerIdentifier:String, willDisplayHeaderView view: UIView, forSection section: Int)
    @objc optional func tableViewHandler(handlerIdentifier:String, willDisplayFooterView view: UIView, forSection section: Int)
    @objc optional func tableViewHandler(handlerIdentifier:String, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func tableViewHandler(handlerIdentifier:String, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    @objc optional func tableViewHandler(handlerIdentifier:String, didEndDisplayingFooterView view: UIView, forSection section: Int)
    @objc optional func tableViewHandlerCellDidSelect(handlerIdentifier:String, cellIdentifier:String, indexPath:IndexPath, data:Any?, extra:Any?)
    @objc optional func tableViewHandlerCellEvent(handlerIdentifier:String, cellIdentifier:String, eventIdentifier:String?, indexPath:IndexPath?, data:Any?, extra:Any?)
}

@objc open class P9TableViewHandler: NSObject {
    
    @objc(P9TableViewRecord) public class Record : NSObject {
        @objc public var type:String
        @objc public var data:Any?
        @objc public var extra:Any?
        @objc public init(type:String, data:Any?, extra:Any?) {
            self.type = type
            self.data = data
            self.extra = extra
        }
    }
    
    @objc(P9TableViewSection) public class Section : NSObject {
        @objc public var headerType:String?
        @objc public var headerData:Any?
        @objc public var footerType:String?
        @objc public var footerData:Any?
        @objc public var extra:Any?
        @objc public var records:[Record]?
        @objc public init(headerType:String?, headerData:Any?, footerType:String?, footerData:Any?, records:[Record]?, extra:Any?) {
            self.headerType = headerType
            self.headerData = headerData
            self.footerType = footerType
            self.footerData = footerData
            self.records = records
            self.extra = extra
        }
    }
    
    public typealias CallbackBlock = (_ indexPath:IndexPath?, _ data:Any?, _ extra:Any?) -> Void
    
    fileprivate let moduleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    fileprivate var handlerIdentifier:String = ""
    fileprivate var cellIdentifierForType:[String:String] = [:]
    fileprivate var callbackBlocks:[String:CallbackBlock] = [:]
    
    @objc public var sections:[Section] = []
    @objc public weak var delegate:P9TableViewHandlerDelegate?
    
    @objc public func standby(identifier:String, cellIdentifierForType:[String:String], tableView:UITableView) {
        
        handlerIdentifier = identifier
        self.cellIdentifierForType = cellIdentifierForType
        self.cellIdentifierForType.forEach { (key, value) in
            tableView.register(UINib(nibName: value, bundle: nil), forCellReuseIdentifier: value)
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc public func registCallback(callback: @escaping CallbackBlock, forCellIdentifier cellIdentifier:String, withEventIdentifier eventIdentifier:String?=nil) {
        
        callbackBlocks[key(forCellIdentifier: cellIdentifier, withEventIdentifier: eventIdentifier)] = callback
    }
    
    @objc public func unregistCallback(forCellIdentifier cellIdentifier:String, withEventIdentifier eventIdentifier:String?=nil) {
        
        callbackBlocks.removeValue(forKey: key(forCellIdentifier: cellIdentifier, withEventIdentifier: eventIdentifier))
    }
    
    @objc public func unregistAllCallbacks() {
        
        callbackBlocks.removeAll()
    }
}

extension P9TableViewHandler {
    
    fileprivate func key(forCellIdentifier cellIdentifier:String, withEventIdentifier eventIdentifier:String?=nil) -> String {
        
        if let eventIdentifier = eventIdentifier {
            return "\(cellIdentifier):\(eventIdentifier)"
        }
        return "\(cellIdentifier):"
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
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName) else {
                return CGFloat.leastNormalMagnitude
        }
        
        if let cellType = cls as? P9TableViewCellProtocol.Type {
            return cellType.cellHeightForData(sections[section].headerData, extra: sections[section].extra)
        }
        if let cellType = cls as? P9TableViewCellObjcProtocol.Type {
            return cellType.cellHeightForData(sections[section].headerData, extra: sections[section].extra)
        }
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].headerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName) else {
                return nil
        }
        
        if let cellType = cls as? P9TableViewCellProtocol.Type, let view = cellType.instanceFromNib() {
            if let cell = view as? P9TableViewCellProtocol {
                cell.setData(sections[section].headerData, extra: sections[section].extra)
                cell.setDelegate(self)
                cell.setIndexPath(IndexPath(row: 0, section: section))
            }
            return view
        }
        if let cellType = cls as? P9TableViewCellObjcProtocol.Type, let view = cellType.instanceFromNib() {
            if let cell = view as? P9TableViewCellObjcProtocol {
                cell.setData(sections[section].headerData, extra: sections[section].extra)
                cell.setDelegate(self)
                cell.setIndexPath(IndexPath(row: 0, section: section))
            }
            return view
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].footerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName) else {
                return CGFloat.leastNormalMagnitude
        }
        
        if let cellType = cls as? P9TableViewCellProtocol.Type {
            return cellType.cellHeightForData(sections[section].footerData, extra: sections[section].extra)
        }
        if let cellType = cls as? P9TableViewCellObjcProtocol.Type {
            return cellType.cellHeightForData(sections[section].footerData, extra: sections[section].extra)
        }
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard section >= 0, section < sections.count,
            let type = sections[section].footerType,
            let clsName = cellIdentifierForType[type], clsName.count > 0,
            let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName) else {
                return nil
        }
        
        if let cellType = cls as? P9TableViewCellProtocol.Type, let view = cellType.instanceFromNib() {
            if let cell = view as? P9TableViewCellProtocol {
                cell.setData(sections[section].footerData, extra: sections[section].extra)
                cell.setDelegate(self)
                cell.setIndexPath(IndexPath(row: 0, section: section))
            }
            return view
        }
        if let cellType = cls as? P9TableViewCellObjcProtocol.Type, let view = cellType.instanceFromNib() {
            if let cell = view as? P9TableViewCellObjcProtocol {
                cell.setData(sections[section].footerData, extra: sections[section].extra)
                cell.setDelegate(self)
                cell.setIndexPath(IndexPath(row: 0, section: section))
            }
            return view
        }
        return nil
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
              let cls:AnyClass = Bundle.main.classNamed(moduleName + "." + clsName) ?? Bundle.main.classNamed(clsName) else {
            return 0
        }
        
        if let tableViewCellContentsCell = cls as? P9TableViewCellProtocol.Type {
            return tableViewCellContentsCell.cellHeightForData(records[indexPath.row].data, extra: records[indexPath.row].extra)
        }
        if let tableViewCellContentsCell = cls as? P9TableViewCellObjcProtocol.Type {
            return tableViewCellContentsCell.cellHeightForData(records[indexPath.row].data, extra: records[indexPath.row].extra)
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count,
              let clsName = cellIdentifierForType[records[indexPath.row].type], clsName.count > 0 else {
                return UITableViewCell(frame: .zero)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: clsName, for: indexPath)
        if let cell = cell as? P9TableViewCellProtocol {
            cell.setData(records[indexPath.row].data, extra: records[indexPath.row].extra)
            cell.setDelegate(self)
            cell.setIndexPath(indexPath)
        }
        if let cell = cell as? P9TableViewCellObjcProtocol {
            cell.setData(records[indexPath.row].data, extra: records[indexPath.row].extra)
            cell.setDelegate(self)
            cell.setIndexPath(indexPath)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section >= 0, indexPath.section < sections.count,
              let records = sections[indexPath.section].records, indexPath.row >= 0, indexPath.row < records.count else {
                return
        }
        
        let cellIdentifier = cellIdentifierForType[records[indexPath.row].type] ?? records[indexPath.row].type
        
        if let callback = callbackBlocks[key(forCellIdentifier: cellIdentifier)] {
            callback(indexPath, records[indexPath.row].data, records[indexPath.row].extra)
        } else {
            delegate?.tableViewHandlerCellDidSelect?(handlerIdentifier: handlerIdentifier, cellIdentifier: cellIdentifier, indexPath: indexPath, data: records[indexPath.row].data, extra: records[indexPath.row].extra)
        }
    }
}

extension P9TableViewHandler: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        delegate?.tableViewHandlerWillBeginDragging?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.tableViewHandlerDidScroll?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            delegate?.tableViewHandlerDidEndScroll?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        delegate?.tableViewHandlerDidEndScroll?(handlerIdentifier: handlerIdentifier, contentSize: scrollView.contentSize, contentOffset: scrollView.contentOffset)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        delegate?.tableViewHandler?(handlerIdentifier: handlerIdentifier, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        delegate?.tableViewHandler?(handlerIdentifier: handlerIdentifier, willDisplayHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        delegate?.tableViewHandler?(handlerIdentifier: handlerIdentifier, willDisplayFooterView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        delegate?.tableViewHandler?(handlerIdentifier: handlerIdentifier, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
        delegate?.tableViewHandler?(handlerIdentifier: handlerIdentifier, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        
        delegate?.tableViewHandler?(handlerIdentifier: handlerIdentifier, didEndDisplayingFooterView: view, forSection: section)
    }
}

extension P9TableViewHandler: P9TableViewCellDelegate {
    
    public func tableViewCellEvent(cellIdentifier: String, eventIdentifier: String?, indexPath: IndexPath?, data: Any?, extra: Any?) {
        
        if let eventIdentifier = eventIdentifier, let callback = callbackBlocks[key(forCellIdentifier: cellIdentifier, withEventIdentifier: eventIdentifier)] {
            callback(indexPath, data, extra)
        } else {
            delegate?.tableViewHandlerCellEvent?(handlerIdentifier: handlerIdentifier, cellIdentifier: cellIdentifier, eventIdentifier: eventIdentifier, indexPath: indexPath, data: data, extra: extra)
        }
    }
}
