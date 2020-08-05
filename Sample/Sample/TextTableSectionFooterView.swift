//
//  TextTableSectionFooterView.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class TextTableSectionFooterView: UIView {
    
    fileprivate var data:[String:Any]?
    fileprivate weak var delegate:P9TableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if data != nil, let touch = touches.first {
            let touchedPosition = touch.location(in: self)
            if iconLabel.frame.contains(touchedPosition) == true {
                delegate?.tableViewCellEvent(cellIdentifier: Self.identifier(), eventIdentifier: EventId.iconTouch.rawValue, indexPath: nil, data: data, extra: nil)
                return
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
}

extension TextTableSectionFooterView: P9TableViewCellProtocol {
    
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2 else {
            return 0
        }
        let height:CGFloat = data["height"] as? CGFloat ?? 30
        return height
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2 else {
            return
        }
        self.data = data
        self.titleLabel.text = data["footerTitle"] as? String ?? ""
        self.titleLabel.textColor = (data["textColor"] as? String ?? "000000").colorByHex
        self.backgroundColor = (data["backgroundColor"] as? String ?? "ffffff").colorByHex
    }
    
    func setDelegate(_ delegate: P9TableViewCellDelegate) {
        
        self.delegate = delegate
    }
}
