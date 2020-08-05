//
//  ButtonTableViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    fileprivate var data:[String:Any]?
    fileprivate weak var delegate:P9TableViewCellDelegate?
    fileprivate var indexPath:IndexPath?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var switchButton: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if data != nil, let touch = touches.first {
            let touchedPosition = touch.location(in: self)
            if thumbnailImageView.frame.contains(touchedPosition) == true {
                delegate?.tableViewCellEvent(cellIdentifier: Self.identifier(), eventIdentifier: EventId.thumbnailTouch.rawValue, indexPath: indexPath, data: data, extra: nil)
                return
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    @IBAction func switchButtonToggled(_ sender: Any) {
        
        delegate?.tableViewCellEvent(cellIdentifier: Self.identifier(), eventIdentifier: EventId.switchButtonChanged.rawValue, indexPath: nil, data: data, extra: switchButton.isOn)
    }
}

extension ButtonTableViewCell: P9TableViewCellProtocol {
    
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2 else {
            return 0
        }
        let height:CGFloat = data["height"] as? CGFloat ?? 70
        return height
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 2 else {
            return
        }
        self.data = data
        self.backgroundColor = (data["backgroundColor"] as? String ?? "ffffff").colorByHex
        self.switchButton.setOn((data["flag"] as? Bool ?? false), animated: false)
    }
    
    func setDelegate(_ delegate: P9TableViewCellDelegate) {
        
        self.delegate = delegate
    }
    
    func setIndexPath(_ indexPath: IndexPath) {
        
        self.indexPath = indexPath
    }
}
