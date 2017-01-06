//
//  PChurchCell.swift
//  Preachers
//
//  Created by Abel Anca on 9/30/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

class PChurchCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgView.layer.cornerRadius        = 26.5
        imgView.layer.borderWidth         = 0
        imgView.layer.borderColor         = UIColor.black.cgColor
        imgView.clipsToBounds             = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
