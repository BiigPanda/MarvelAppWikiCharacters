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
    var marvelView = MainUIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadCharacters()
    
    }
    
    func downloadCharacters() {
        marvelClient.callAPICharacters { (heroes, error) in
                     let defaults = UserDefaults.standard
                     self.marvelView.heroesMarvel = defaults.array(forKey: "SavedArray") as! [MarvelHeroe]
                 }
    }
}
