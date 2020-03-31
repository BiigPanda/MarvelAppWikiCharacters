//
//  MainViewController.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 22/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tableViewHeroes: UITableView!
    
    private let marvelClient = MarvelHeroeService()
    var heroesCharacter : [MarvelHeroe] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadCharacters()
        tableViewHeroes.delegate = self
        tableViewHeroes.dataSource = self
        tableViewHeroes.register(UINib(nibName: "MarvelHeroMainTableViewCell", bundle: nil), forCellReuseIdentifier: "MarvelHeroeCell")
    }
    
    func downloadCharacters() {
          marvelClient.callAPICharacters { (heroes, error) in
              if (error == nil){
                self.heroesCharacter = heroes
                self.tableViewHeroes.reloadData()
              }
          }
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroesCharacter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewHeroes.dequeueReusableCell(withIdentifier: "MarvelHeroeCell", for: indexPath) as! MarvelHeroMainTableViewCell

        if heroesCharacter.count == 1 {
            cell.lblNameHeroe.text = "No hay datos"
        } else {
            let heroeMarvelDetail = heroesCharacter[indexPath.row]
            cell.lblNameHeroe.text = heroeMarvelDetail.name
            cell.descripHeroe.text = heroeMarvelDetail.descrip
            cell.lblNumSeries.text = "\(heroeMarvelDetail.numSeries ?? 0)"
            cell.lblNumComics.text = "\(heroeMarvelDetail.numComic ?? 0)"
            return cell
        }
                return cell
            }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}

