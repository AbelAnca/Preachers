//
//  PPreachCell.swift
//  Preachers
//
//  Created by Abel Anca on 12/15/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

class PPreachCell: UICollectionViewCell {
    
    @IBOutlet var lblBiblicalText: UILabel!
    @IBOutlet var lblDate: UILabel!
    
    @IBOutlet var conView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.backgroundColor           = UIColor.preachersGrey()
        contentView.layer.cornerRadius        = 4
        contentView.clipsToBounds             = true
    }

}
