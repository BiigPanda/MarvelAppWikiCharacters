//
//  MainUIView.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 22/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

protocol MainUIViewCharactersDelegate: class {
    func downloadCharacters(completionHandler: @escaping (_ result: [MarvelHeroe], _ error: Error?) -> Void)
}

class MainUIView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var mainHeroeTableView: UITableView!
    var heroesMarvel = [MarvelHeroe()]
    weak var delegate: MainUIViewCharactersDelegate?

    override func awakeFromNib() {
     //   print(heroesMarvel)
//        if heroesMarvel.count == 0 {
//            delegate?.downloadCharacters(completionHandler: { (heroes, error) in
//                if error == nil {
//                    self.heroesMarvel = heroes
//                }
//            })
//        } else {
//            self.mainHeroeTableView.reloadData()
//        }
        self.mainHeroeTableView.delegate = self
        self.mainHeroeTableView.dataSource = self
        self.mainHeroeTableView.register(UINib(nibName: "MarvelHeroMainTableViewCell", bundle: nil), forCellReuseIdentifier: "MarvelHeroeCell")

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if heroesMarvel.count == 0 || heroesMarvel[0].name == "" {
//            return 1
//        } else {
//            return heroesMarvel.count
//        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = self.mainHeroeTableView.dequeueReusableCell(withIdentifier: "MarvelHeroeCell", for: indexPath) as! MarvelHeroMainTableViewCell
       // let cell = Bundle.main.loadNibNamed("MarvelHeroMainTableViewCell", owner: self, options: nil)?.first as! MarvelHeroMainTableViewCell
//        if heroesMarvel.count == 1 {
                cell.lblNameHeroe.text = "No hay datos"
//        } else {
//            let heroeMarvelDetail = heroesMarvel[indexPath.row]
//                  cell.lblNameHeroe.text = heroeMarvelDetail.name
//                  cell.descripHeroe.text = heroeMarvelDetail.descrip
//                  cell.lblNumSeries.text = String(describing: heroeMarvelDetail.numSeries)
//                  cell.lblNumComics.text = String(describing: heroeMarvelDetail.numComic)
//                  return cell
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}
