//
//  MainUIView.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 22/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit

class MainUIView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var mainHeroeTableView: UITableView!
    var heroesMarvel = [MarvelHeroe()]

    override func awakeFromNib() {
     //   print(heroesMarvel)
        mainHeroeTableView.delegate = self
        mainHeroeTableView.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if heroesMarvel.count == 0 || heroesMarvel[0].name == "" {
            return 0
        } else {
            return heroesMarvel.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.mainHeroeTableView.dequeueReusableCell(withIdentifier: "MarvelHeroeCell" ) as! MarvelHeroMainTableViewCell
        if heroesMarvel.count == 0 {
                cell.lblNameHeroe.text = "No hay datos"
        } else {
            let heroeMarvelDetail = heroesMarvel[indexPath.row]
                  cell.lblNameHeroe.text = heroeMarvelDetail.name
                  cell.descripHeroe.text = heroeMarvelDetail.descrip
                  cell.lblNumSeries.text = String(describing: heroeMarvelDetail.numSeries)
                  cell.lblNumComics.text = String(describing: heroeMarvelDetail.numComic)
                  return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}
