//
//  DetailCharacterViewController.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 06/04/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage
import CoreData
import SwiftMessages

struct cellData {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}

class DetailCharacterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var detailHeroeObject = DetailCharacter()
    var marvelFavoriteHeroeDetail = FavoriteHeroe()
    var isFavActive : Bool = false
    @IBOutlet weak var lblNameDetailCharacter: UILabel!
    @IBOutlet weak var imageDetailCharacter: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var tableViewSeriesComic: UITableView!
    var tableViewData = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNameDetailCharacter.text = detailHeroeObject.nameDetail
        imageDetailCharacter.sd_setImage(with: URL(string: detailHeroeObject.thumbnailDetail), placeholderImage: UIImage(named:"img_splash_logo"))
        imageDetailCharacter.layer.cornerRadius = imageDetailCharacter.frame.size.width / 2
        imageDetailCharacter.clipsToBounds = true
        if isFavActive == true {
            btnFav.isHidden = false
        } else {
            btnFav.isHidden = true
        }
        convertHeroeSelectToFav(detailHeroe: detailHeroeObject)
        marvelFavoriteHeroeDetail =  loadFavoriteHeroeInfoCoreData(favoriteHeroe: marvelFavoriteHeroeDetail)
        setButtonImageFav()
        
        tableViewData = [cellData(opened: false, title: "Title of Series", sectionData: detailHeroeObject.titleSeries),
                         cellData(opened: false, title: "Title of Comics", sectionData: detailHeroeObject.titleComics)]
        tableViewSeriesComic.delegate = self
        tableViewSeriesComic.dataSource = self
    }
    
    @IBAction func backToMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addToFav(_ sender: Any) {
        if marvelFavoriteHeroeDetail.isFav == false {
            marvelFavoriteHeroeDetail.isFav = true
            btnFav.setImage(UIImage(named: "img_icon_black_full"), for: .normal)
            let viewM = MessageView.viewFromNib(layout: .statusLine)
            viewM.configureContent(title: nil, body: "Super Heroe añadido a favoritos", iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
            viewM.configureTheme(.success)
            viewM.configureDropShadow()
            SwiftMessages.show(view: viewM)
            saveFavoriteHeroeCoreData(marvelHeroe: marvelFavoriteHeroeDetail)
        } else {
            marvelFavoriteHeroeDetail.isFav = false
            btnFav.setImage(UIImage(named: "img_icon_white_favs"), for: .normal)
            let viewM = MessageView.viewFromNib(layout: .statusLine)
            viewM.configureContent(title: nil, body: "Super Heroe eliminado de favoritos", iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
            viewM.configureTheme(.error)
            viewM.configureDropShadow()
            SwiftMessages.show(view: viewM)
            deleteFavoriteHeroeInfoCoreData(favoriteHeroe: marvelFavoriteHeroeDetail)
        }
    }
    
    func setButtonImageFav() {
        if marvelFavoriteHeroeDetail.isFav == false {
            btnFav.setImage(UIImage(named: "img_icon_white_favs"), for: .normal)
        } else {
            btnFav.setImage(UIImage(named: "img_icon_black_full"), for: .normal)
        }
    }
        
    func convertHeroeSelectToFav(detailHeroe: DetailCharacter) {
        marvelFavoriteHeroeDetail.name = detailHeroeObject.nameDetail
        marvelFavoriteHeroeDetail.descrip = detailHeroeObject.descrip
        marvelFavoriteHeroeDetail.identifier = detailHeroeObject.idDetail
        marvelFavoriteHeroeDetail.thumbnail = detailHeroeObject.thumbnailDetail
        marvelFavoriteHeroeDetail.numSeries = Int32(detailHeroeObject.titleSeries.count)
        marvelFavoriteHeroeDetail.numComic = Int32(detailHeroeObject.titleComics.count)
    }
    
    func saveFavoriteHeroeCoreData(marvelHeroe: FavoriteHeroe) {
             let context = connection()
             let favoriteHeroeEntity = NSEntityDescription.entity(forEntityName: "FavoriteHeroeCharacter", in: context)
             let heroeTask = NSManagedObject(entity: favoriteHeroeEntity!, insertInto: context)
             heroeTask.setValue(marvelHeroe.name, forKey: "name")
             heroeTask.setValue(marvelHeroe.descrip, forKey: "descrip")
             heroeTask.setValue(marvelHeroe.identifier, forKey: "identifier")
             heroeTask.setValue(marvelHeroe.thumbnail, forKey: "thumbnail")
             heroeTask.setValue(marvelHeroe.numComic, forKey: "numcomics")
             heroeTask.setValue(marvelHeroe.numSeries, forKey: "numseries")
             heroeTask.setValue(marvelHeroe.isFav, forKey: "isFav")
             do {
               try context.save()
             } catch let error as NSError {
                 print("Error al guardar", error.localizedDescription)
             }
    }
    
    func loadFavoriteHeroeInfoCoreData(favoriteHeroe: FavoriteHeroe) -> FavoriteHeroe {
        
        // 1
              let appDelegate = UIApplication.shared.delegate as! AppDelegate
              let managedContext = appDelegate.persistentContainer.viewContext
              let emptyFavHeroe = FavoriteHeroe()
              
               // 2
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteHeroeCharacter")
              fetchRequest.predicate = NSPredicate(format: "identifier == \(favoriteHeroe.identifier ?? 0)")
               // 3
               do {
                 let records = try managedContext.fetch(fetchRequest)
                
                if records.count > 0 {
                    if let records = records as? [NSManagedObject]{
                                         for record in records {
                                             emptyFavHeroe.name = record.value(forKey: "name") as? String
                                             emptyFavHeroe.descrip = record.value(forKey: "descrip") as? String
                                             emptyFavHeroe.thumbnail = record.value(forKey: "thumbnail") as? String ?? ""
                                             emptyFavHeroe.identifier = record.value(forKey: "identifier") as? Int32
                                             emptyFavHeroe.numComic = record.value(forKey: "numcomics") as? Int32
                                             emptyFavHeroe.numSeries = record.value(forKey: "numseries") as? Int32
                                             emptyFavHeroe.isFav = record.value(forKey: "isFav") as! Bool
                                         }
                                         return emptyFavHeroe
                                     }
                } else {
                    return favoriteHeroe
                }
              } catch let error as NSError {
                 print("No ha sido posible cargar \(error), \(error.userInfo)")
                  return favoriteHeroe
              }
              // 4
              return favoriteHeroe
    }
    
    
    func deleteFavoriteHeroeInfoCoreData(favoriteHeroe: FavoriteHeroe)  {
        
        // 1
              let appDelegate = UIApplication.shared.delegate as! AppDelegate
              let managedContext = appDelegate.persistentContainer.viewContext
              
               // 2
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteHeroeCharacter")
              fetchRequest.predicate = NSPredicate(format: "identifier == \(favoriteHeroe.identifier ?? 0)")
               // 3
               do {
                 let records = try managedContext.fetch(fetchRequest)
                
                if records.count > 0 {
                    if let records = records as? [NSManagedObject]{
                                         for record in records {
                                            managedContext.delete(record)
                                         }
                                     }
                }
              } catch let error as NSError {
                 print("No ha sido posible cargar \(error), \(error.userInfo)")
              }
    }
    
    func connection() -> NSManagedObjectContext {
           // [MG] Esta función es para no estar llamando cada dos por tres al contexto
           let delegate = UIApplication.shared.delegate as! AppDelegate
           return delegate.persistentContainer.viewContext
       }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetail") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            cell.backgroundColor = UIColor(red: 213.0/255.0, green: 87.0/255.0, blue: 69.0/255.0, alpha: 1.0)
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetail") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            cell.backgroundColor = UIColor.white
            return cell
        }
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
          if tableViewData[indexPath.section].opened == true {
                    tableViewData[indexPath.section].opened = false
                    let sections = IndexSet.init(integer: indexPath.section)
                    tableView.reloadSections(sections, with: .none)
                } else {
                    tableViewData[indexPath.section].opened = true
                    let sections = IndexSet.init(integer: indexPath.section)
                    tableView.reloadSections(sections, with: .none)
                }
        }
    }
}
