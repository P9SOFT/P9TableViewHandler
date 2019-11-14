//
//  TextTableViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 11. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class TextTableViewCell: UITableViewCell {
    
    fileprivate var data:[String:Any]?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension TextTableViewCell: P9TableViewCellProtocol {
    
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 1 else {
            return 0
        }
        let height:CGFloat = data["height"] as? CGFloat ?? 60
        return height
    }
    
    func setData(_ data: Any?, extra: Any?) {
        
        guard let data = data as? [String:Any], let type = data["type"] as? Int, type == 1 else {
            return
        }
        self.data = data
        titleLabel.text = data["title"] as? String ?? ""
        titleLabel.textColor = (data["textColor"] as? String ?? "000000").colorByHex
        self.backgroundColor = (data["backgroundColor"] as? String ?? "ffffff").colorByHex
    }
}
