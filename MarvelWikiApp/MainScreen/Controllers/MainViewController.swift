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
    private let detailMarvelClient = DetailCharacterService()
    var favHeroeCharacter : FavoriteHeroe = FavoriteHeroe()
    var detailHeroeCharacter = DetailCharacter()
    var marvelHeroeSelect : MarvelHeroe = MarvelHeroe()
    var heroesCharacter : [MarvelHeroe] = []
    var filterHeroesCharacter : [MarvelHeroe] = []
    var hud = JGProgressHUD(style: .dark)

        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        heroesCharacter = loadCharacter()
        if heroesCharacter.count == 0 {
            showAlertDownloadCharacters()
        }
        tableViewHeroes.delegate = self
        tableViewHeroes.dataSource = self
        tableViewHeroes.keyboardDismissMode = .onDrag
        searchBarHeroe.placeholder = "Search by Name of Heroe..."
        let textFieldInsideSearchBar = searchBarHeroe.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        tableViewHeroes.register(UINib(nibName: "MarvelHeroMainTableViewCell", bundle: nil), forCellReuseIdentifier: "MarvelHeroeCell")
    }
    

// MARK: Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterHeroesCharacter.count > 0 {
            return filterHeroesCharacter.count
        } else {
            return heroesCharacter.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewHeroes.dequeueReusableCell(withIdentifier: "MarvelHeroeCell", for: indexPath) as! MarvelHeroMainTableViewCell
        cell.detailMarvelHeroeView.clipsToBounds = true
        cell.detailMarvelHeroeView.layer.cornerRadius = 10

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
            cell.descripHeroe.becomeFirstResponder()
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
                cell.descripHeroe.becomeFirstResponder()
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var detailHeroe = MarvelHeroe()
        if filterHeroesCharacter.count > 0 {
           detailHeroe = filterHeroesCharacter[indexPath.row]
        } else {
           detailHeroe = heroesCharacter[indexPath.row]
        }
        guard let idDetailHeroe = detailHeroe.identifier else {
            print ("identifier error")
            return
        }
        let idHeroe = "\(idDetailHeroe)"
        downloadDetailCharacter(idDetailCharacter: idHeroe, completionHandler: {(detailHeroe, error) in
            print(self.detailHeroeCharacter)
            self.tableViewHeroes.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "detailCharacter", sender: nil)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if heroesCharacter.count > 0  && heroesCharacter.count != Int(heroesCharacter[0].totalHeroes!) {
            if indexPath.row == heroesCharacter.count - 1 {
                downloadNextCharacters()
            }
        }
    }

    
// MARK: Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailCharacter" {
            let detailVC = segue.destination as! DetailCharacterViewController
            detailVC.detailHeroeObject = self.detailHeroeCharacter
            detailVC.isFavActive = true
        }
    }
    
// MARK: Search Bar methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filterHeroesCharacter = heroesCharacter
            tableViewHeroes.reloadData()
            return
        }
        filterHeroesCharacter = heroesCharacter.filter({ (heroe) -> Bool in
            guard let text = searchBar.text else {return false}
            return (heroe.name?.contains(text))!
        })
        tableViewHeroes.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if filterHeroesCharacter.count == 0 {
            showAlertHeroeNotFound()
            searchBarHeroe.resignFirstResponder()
        } else {
            searchBarHeroe.resignFirstResponder()
        }
    }
    
    func showAlertHeroeNotFound() {
        let alert = UIAlertController(title: "Heroe not found", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true)
    }

// MARK: Core Data and Service Methods
    
    func showAlertDownloadCharacters() {
//        let alert = UIAlertController(title: "Se va descargar el contenido, que tipo de descarga prefiere?", message: "Si quiere optimizar el tiempo se le recomienda que seleccione la descarga secuencial.", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Descarga Secuencial", style: .default, handler: { action in
//            self.downloadCharacters()
//        }))
//        alert.addAction(UIAlertAction(title: "Descarga Completa", style: .default, handler: { action in
            self.downloadCharacters()
 //       }))

        //self.present(alert, animated: true)
    }
    
    func loadCharacter() -> [MarvelHeroe] {
         // 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        var arrayHeroes : [MarvelHeroe] = []
        var emptyHeroe = MarvelHeroe()
        
         // 2
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MarvelHeroeCharacter")
        
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
                    emptyHeroe.totalHeroes = record.value(forKey: "totalHeroes") as? Int32
                    arrayHeroes.append(emptyHeroe)
                    emptyHeroe = MarvelHeroe()
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
    
    
    func downloadCharacters() {
          let hud = JGProgressHUD(style: .dark)
          hud.textLabel.text = "Loading"
          hud.show(in: self.view)
          heroesCharacter = loadCharacter()
        if heroesCharacter.count == 0 {
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
    
    func downloadNextCharacters() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        let offsetHeroes = String(heroesCharacter.count)
        let total = Int(heroesCharacter[0].totalHeroes!)
        if heroesCharacter.count < total {
            marvelClient.callApiNextCharacters(numberOffset: offsetHeroes) { (heroesNext, error) in
                if error == nil {
                    self.heroesCharacter += heroesNext
                    self.tableViewHeroes.reloadData()
                    hud.dismiss()
                }
            }
        }
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

