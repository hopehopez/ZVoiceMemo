//
//  ZMemoCell.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/15.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZMemoCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
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
