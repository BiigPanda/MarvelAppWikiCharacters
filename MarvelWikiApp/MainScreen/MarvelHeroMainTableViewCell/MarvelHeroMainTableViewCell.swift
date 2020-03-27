//
//  MarvelHeroMainTableViewCell.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 25/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

class MarvelHeroMainTableViewCell: UITableViewCell {

    @IBOutlet weak var lblNumSeries: UILabel!
    @IBOutlet weak var lblNumComics: UILabel!
    @IBOutlet weak var descripHeroe: UITextView!
    @IBOutlet weak var lblNameHeroe: UILabel!
    @IBOutlet weak var imgHeroe: UIImageView!
    var viewModelHeroe: MarvelHeroe = MarvelHeroe()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
