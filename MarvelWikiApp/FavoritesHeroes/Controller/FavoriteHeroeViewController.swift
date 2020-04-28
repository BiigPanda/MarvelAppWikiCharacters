//
//  FavoriteHeroeViewController.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 23/04/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage
import CoreData

class FavoriteHeroeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var favoritesHeroes : [FavoriteHeroe] = []
    var detailHeroeCharacter = DetailCharacter()

    private let detailMarvelClient = DetailCharacterService()

    @IBOutlet weak var tbvFavoritesHeroes: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesHeroes = loadFavoritesCharacters()
        tbvFavoritesHeroes.delegate = self
        tbvFavoritesHeroes.dataSource = self
        tbvFavoritesHeroes.keyboardDismissMode = .onDrag
        tbvFavoritesHeroes.register(UINib(nibName: "MarvelHeroMainTableViewCell", bundle: nil), forCellReuseIdentifier: "MarvelHeroeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favoritesHeroes = loadFavoritesCharacters()
        tbvFavoritesHeroes.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return favoritesHeroes.count
       }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if favoritesHeroes.count > 0 {
            let cell = tbvFavoritesHeroes.dequeueReusableCell(withIdentifier: "MarvelHeroeCell", for: indexPath) as! MarvelHeroMainTableViewCell
                   cell.detailMarvelHeroeView.clipsToBounds = true
                   cell.detailMarvelHeroeView.layer.cornerRadius = 10
                   let heroeMarvelDetail = favoritesHeroes[indexPath.row]
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
            let cell = tbvFavoritesHeroes.dequeueReusableCell(withIdentifier: "MarvelHeroeCell", for: indexPath) as! MarvelHeroMainTableViewCell
            cell.lblNameHeroe.text = "No Hay Favs"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var detailFavHeroe = FavoriteHeroe()
            detailFavHeroe = favoritesHeroes[indexPath.row]
           
            guard let idDetailHeroe = detailFavHeroe.identifier else {
                print ("identifier error")
                return
            }
            let idHeroe = "\(idDetailHeroe)"
            downloadDetailCharacter(idDetailCharacter: idHeroe, completionHandler: {(detailHeroe, error) in
                self.tbvFavoritesHeroes.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: "detailCharacterFavorite", sender: nil)
            })
        
    }
    
    // MARK: Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailCharacterFavorite" {
            let detailVC = segue.destination as! DetailCharacterViewController
            detailVC.detailHeroeObject = self.detailHeroeCharacter
            detailVC.isFavActive = false
        }
    }
    
    
    func loadFavoritesCharacters() -> [FavoriteHeroe] {
            // 1
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           let managedContext = appDelegate.persistentContainer.viewContext
           var arrayHeroes : [FavoriteHeroe] = []
           var emptyHeroe = FavoriteHeroe()
           
            // 2
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteHeroeCharacter")
           
            // 3
            do {
              let records = try managedContext.fetch(fetchRequest)
               // crear un objeto vacío añadir cada campo a su propiedad correspondiente  crear el array de heroes y devolverlo
             
               if let records = records as? [NSManagedObject]{
                   for record in records {
                       emptyHeroe.name = record.value(forKey: "name") as? String
                       emptyHeroe.descrip = record.value(forKey: "descrip") as? String
                       emptyHeroe.thumbnail = record.value(forKey: "thumbnail") as? String ?? ""
                       emptyHeroe.identifier = record.value(forKey: "identifier") as? Int32
                       emptyHeroe.numComic = record.value(forKey: "numcomics") as? Int32
                       emptyHeroe.numSeries = record.value(forKey: "numseries") as? Int32
                       emptyHeroe.isFav = record.value(forKey: "isFav") as? Bool ?? false
                       arrayHeroes.append(emptyHeroe)
                       emptyHeroe = FavoriteHeroe()
                   }
                   return arrayHeroes
               }
           } catch let error as NSError {
              print("No ha sido posible cargar \(error), \(error.userInfo)")
               return []
           }
           // 4
           return []
       }
    
    func downloadDetailCharacter(idDetailCharacter: String, completionHandler: @escaping (_ result: DetailCharacter, _ error: Error?) -> Void) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        detailMarvelClient.callAPIDetailCharacter(idDetailHeroe: idDetailCharacter) { (detailHeroe, error) in
            self.detailHeroeCharacter = detailHeroe
            completionHandler(detailHeroe,nil)
            hud.dismiss()
        }
    }
}
