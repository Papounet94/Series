//
//  CustomSerieCell.swift
//  Series
//
//  Created by Christian BRUNEL on 28/04/2019.
//  Copyright © 2019 Christian BRUNEL. All rights reserved.
//

import UIKit

class CustomSerieCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    
    override func awakeFromNib() {
        super .awakeFromNib()
    }
}
