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

    override func viewDidLoad() {
        super.viewDidLoad()
        marvelClient.callAPICharacters()
        
    }
}
