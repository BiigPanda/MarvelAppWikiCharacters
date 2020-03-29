//
//  MainViewController.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 22/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private let marvelClient = MarvelHeroeService()
    
    @IBOutlet var marvelView: MainUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.downloadCharacters(completionHandler: { (heroes, error) in
//            if heroes.count > 0 {
//                self.marvelView.heroesMarvel = heroes
//                self.marvelView.awakeFromNib()
//            }
//        })

    }    
}

extension MainViewController : MainUIViewCharactersDelegate {
    func downloadCharacters(completionHandler: @escaping (_ result: [MarvelHeroe], _ error: Error?) -> Void) {
        self.marvelView = MainUIView()
        marvelClient.callAPICharacters { (heroes, error) in
            if (error == nil){
                self.marvelView.heroesMarvel = heroes
                self.marvelView.awakeFromNib()
            }
        }
    }
}
