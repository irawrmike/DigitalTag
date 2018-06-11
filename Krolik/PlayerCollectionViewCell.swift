//
//  PlayerCollectionViewCell.swift
//  Krolik
//
//  Created by Colin on 2018-06-11.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import UIKit

class PlayerCollectionViewCell: UICollectionViewCell {
    override func prepareForReuse() {
        for subview in self.contentView.subviews {
            
            if let _ = subview as? UIImageView {
                subview.removeFromSuperview()
            }
        }
    }
}
