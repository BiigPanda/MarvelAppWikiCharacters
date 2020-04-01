//
//  MainViewController.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 22/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var searchBarHeroe: UISearchBar!
    
    @IBOutlet weak var tableViewHeroes: UITableView!
    
    private let marvelClient = MarvelHeroeService()
    var heroesCharacter : [MarvelHeroe] = []
    var filterHeroesCharacter : [MarvelHeroe] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadCharacters()
        tableViewHeroes.delegate = self
        tableViewHeroes.dataSource = self
        tableViewHeroes.keyboardDismissMode = .onDrag
        searchBarHeroe.placeholder = "Search by Name of Heroe..."
        tableViewHeroes.register(UINib(nibName: "MarvelHeroMainTableViewCell", bundle: nil), forCellReuseIdentifier: "MarvelHeroeCell")
    }
    
    func downloadCharacters() {
          let hud = JGProgressHUD(style: .dark)
          hud.textLabel.text = "Loading"
          hud.show(in: self.view)
          marvelClient.callAPICharacters { (heroes, error) in
              if (error == nil){
                self.heroesCharacter = heroes
                self.tableViewHeroes.reloadData()
                hud.dismiss()
              }
          }
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterHeroesCharacter.count > 0 {
            return filterHeroesCharacter.count
        }
        return heroesCharacter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewHeroes.dequeueReusableCell(withIdentifier: "MarvelHeroeCell", for: indexPath) as! MarvelHeroMainTableViewCell

        if filterHeroesCharacter.count > 0 {
            let heroeMarvelDetail = filterHeroesCharacter[indexPath.row]
            cell.lblNameHeroe.text = heroeMarvelDetail.name
            if heroeMarvelDetail.descrip == "" || heroeMarvelDetail.descrip == nil {
                cell.descripHeroe.text = "This heroe hasn't description"
            } else {
                cell.descripHeroe.text = heroeMarvelDetail.descrip
            }
            cell.lblNumSeries.text = "\(heroeMarvelDetail.numSeries ?? 0)"
            cell.lblNumComics.text = "\(heroeMarvelDetail.numComic ?? 0)"
            cell.imgHeroe.sd_setImage(with: URL(string: heroeMarvelDetail.thumbnail), placeholderImage: UIImage(named:"img_splash_logo"))
            return cell
        } else {
            let heroeMarvelDetail = heroesCharacter[indexPath.row]
            cell.lblNameHeroe.text = heroeMarvelDetail.name
            if heroeMarvelDetail.descrip == "" || heroeMarvelDetail.descrip == nil {
                cell.descripHeroe.text = "This heroe hasn't description"
            } else {
                cell.descripHeroe.text = heroeMarvelDetail.descrip
            }
            cell.lblNumSeries.text = "\(heroeMarvelDetail.numSeries ?? 0)"
            cell.lblNumComics.text = "\(heroeMarvelDetail.numComic ?? 0)"
            cell.imgHeroe.sd_setImage(with: URL(string: heroeMarvelDetail.thumbnail), placeholderImage: UIImage(named:"img_splash_logo"))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filterHeroesCharacter = heroesCharacter
            tableViewHeroes.reloadData()
            return
        }
        filterHeroesCharacter = heroesCharacter.filter({ (heroe) -> Bool in
            guard let text = searchBar.text else {return false}
            return heroe.name.contains(text)
        })
        tableViewHeroes.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarHeroe.resignFirstResponder()
    }
    
}

