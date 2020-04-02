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
import CoreData

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var searchBarHeroe: UISearchBar!
    
    @IBOutlet weak var tableViewHeroes: UITableView!
    
    private let marvelClient = MarvelHeroeService()
    var heroesCharacter : [MarvelHeroe] = []
    var filterHeroesCharacter : [MarvelHeroe] = []
        
    var heroeTasks = [NSManagedObject]()
        
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
          heroeTasks = loadCharacter() ?? [NSManagedObject]()
        if heroeTasks.count == 0 {
            marvelClient.callAPICharacters { (heroes, error) in
                    if (error == nil){
                      self.heroesCharacter = heroes
                      self.tableViewHeroes.reloadData()
                      hud.dismiss()
                    }
                }
        } else {
            self.tableViewHeroes.reloadData()
            hud.dismiss()
        }
      }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterHeroesCharacter.count > 0 {
            return filterHeroesCharacter.count
        } else {
            if heroeTasks.count > 0 {
                return heroeTasks.count
            } else {
                return heroesCharacter.count
            }
        }
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
            if heroeTasks.count > 0 {
                let marvelHeroe = heroeTasks[indexPath.row]
                cell.lblNameHeroe.text = marvelHeroe.value(forKey: "name") as? String
                if marvelHeroe.value(forKey: "descrip") as? String == "" || marvelHeroe.value(forKey: "descrip") as? String == nil {
                    cell.descripHeroe.text = "This heroe hasn't description"
                } else {
                    cell.descripHeroe.text = marvelHeroe.value(forKey: "descrip") as? String
                }
                cell.lblNumSeries.text = "\(marvelHeroe.value(forKey: "numseries") ?? "0")"
                cell.lblNumComics.text = "\(marvelHeroe.value(forKey: "numcomics") ?? "0")"
                cell.imgHeroe.sd_setImage(with: URL(string: (marvelHeroe.value(forKey: "thumbnail") as? String)!), placeholderImage: UIImage(named:"img_splash_logo"))
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
    
    func loadCharacter() -> [NSManagedObject]? {
         // 1
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let managedContext = appDelegate.persistentContainer.viewContext
        
         // 2
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MarvelHeroeCharacter")
         var result = [NSManagedObject]()
        
         // 3
         do {
           let records = try managedContext.fetch(fetchRequest)
            if let records = records as? [NSManagedObject]{
                result = records
                return result
            }
        } catch let error as NSError {
           print("No ha sido posible cargar \(error), \(error.userInfo)")
            return nil
        }
        // 4
        return nil
    }
}

