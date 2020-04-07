//
//  DetailCharacterViewController.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 06/04/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

class DetailCharacterViewController: UIViewController {
    var detailHeroeObject = DetailCharacter()
    @IBOutlet weak var lblNameDetailCharacter: UILabel!
    @IBOutlet weak var lblTitlteSeries: UILabel!
    @IBOutlet weak var lblTitleComics: UILabel!
    @IBOutlet weak var imageDetailCharacter: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNameDetailCharacter.text = detailHeroeObject.nameDetail
        imageDetailCharacter.sd_setImage(with: URL(string: detailHeroeObject.thumbnailDetail), placeholderImage: UIImage(named:"img_splash_logo"))
        lblTitlteSeries.text = "\(detailHeroeObject.titleSeries)"
        lblTitleComics.text  = "\(detailHeroeObject.titleComics)"
    }
    
    @IBAction func backToMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
