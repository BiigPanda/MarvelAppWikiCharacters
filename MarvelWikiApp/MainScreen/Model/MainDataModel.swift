//
//  MainDataModel.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 22/03/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class MarvelHeroe {
    var id: Int = 0
    var name: String?
    var descrip: String?
    var thumbnail: String = ""
    var numComic: Int?
    var numSeries: Int?
}



class MarvelHeroeService {
    
    func connection() -> NSManagedObjectContext {
        // [MG] Esta función es para no estar llamando cada dos por tres al contexto
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func callAPICharacters(completionHandler: @escaping (_ result: [MarvelHeroe], _ error: Error?) -> Void)  {
        var heroesMarvel : [MarvelHeroe] = []
        let endpoints = Endpoints.init()
        Alamofire.request(endpoints.endPointCharacter).responseJSON { (response) in
            switch response.result {
                   case .success(_):
                       guard let result = response.result.value as? [String:Any] else{
                           assertionFailure()
                           return
                       }
                       let json = JSON(result)
                       heroesMarvel = self.parsedHeroe(json: json)
                       completionHandler(heroesMarvel,nil)
                       break
                   case .failure(let error):
                       completionHandler(heroesMarvel,error)
                       break
                   }
            
        }
    }
    
    func parsedHeroe(json: JSON) -> [MarvelHeroe] {
        var heroeMarvel = MarvelHeroe()
        var heroesMarvel : [MarvelHeroe] = []
        heroesMarvel.reserveCapacity(json["data"]["results"].count)
        for (_,subJson):(String, JSON) in json["data"]["results"] {
                          heroeMarvel.name = subJson["name"].stringValue
                          heroeMarvel.descrip = subJson["description"].stringValue
                          heroeMarvel.id = subJson["id"].intValue
                          heroeMarvel.thumbnail = subJson["thumbnail"]["path"].stringValue + "." + subJson["thumbnail"]["extension"].stringValue
                          heroeMarvel.numComic = subJson["comics"]["returned"].intValue
                          heroeMarvel.numSeries = subJson["series"]["returned"].intValue
                          saveHeroeCoreData(marvelHeroe: heroeMarvel)
                          heroesMarvel.append(heroeMarvel)
                          heroeMarvel = MarvelHeroe()
                      }
        return heroesMarvel
    }
    
    func saveHeroeCoreData(marvelHeroe: MarvelHeroe) {
        let context = connection()
        let heroeEntity = NSEntityDescription.entity(forEntityName: "MarvelHeroeCharacter", in: context)
        let heroeTask = NSManagedObject(entity: heroeEntity!, insertInto: context)

        heroeTask.setValue(marvelHeroe.name, forKey: "name")
        heroeTask.setValue(marvelHeroe.descrip, forKey: "descrip")
        heroeTask.setValue(marvelHeroe.id, forKey: "id")
        heroeTask.setValue(marvelHeroe.thumbnail, forKey: "thumbnail")
        heroeTask.setValue(marvelHeroe.numComic, forKey: "numcomics")
        heroeTask.setValue(marvelHeroe.numSeries, forKey: "numseries")
        do {
          try context.save()
        } catch let error as NSError {
            print("Error al guardar", error.localizedDescription)
        }
    }
    
    func callAPIDetailCharacter(idDetailHeroe: String, completionHandler: @escaping (_ result: DetailCharacter, _ error: Error?) -> Void)  {
        let detailHeroe = DetailCharacter()
        
        let endPointDetailCharacter = "https://gateway.marvel.com:443/v1/public/characters/\(idDetailHeroe)?ts=1&apikey=cc3e270d04c7e50ec7c7db921c88bb96&hash=b223b72d5f71869ad340852bad7669d5"
        Alamofire.request(endPointDetailCharacter).responseJSON { (response) in
                 switch response.result {
                        case .success(_):
                            guard let result = response.result.value as? [String:Any] else{
                                assertionFailure()
                                return
                            }
                            let json = JSON(result)
                            print(json)
                           // faltaría aqui parsearlo  y devolver el detail heroe
                           // detailHeroe = self.parsedHeroe(json: json)
                            completionHandler(detailHeroe,nil)
                            break
                        case .failure(let error):
                            completionHandler(detailHeroe,error)
                            break
                        }
                 
             }
    }
    
//    func parsedDetailHeroe(json: JSON) -> DetailCharacter {
//         var heroeMarvel = MarvelHeroe()
//         var heroesMarvel : [MarvelHeroe] = []
//         heroesMarvel.reserveCapacity(json["data"]["results"].count)
//         for (_,subJson):(String, JSON) in json["data"]["results"] {
//                           heroeMarvel.name = subJson["name"].stringValue
//                           heroeMarvel.descrip = subJson["description"].stringValue
//                           heroeMarvel.id = subJson["id"].intValue
//                           heroeMarvel.thumbnail = subJson["thumbnail"]["path"].stringValue + "." + subJson["thumbnail"]["extension"].stringValue
//                           heroeMarvel.numComic = subJson["comics"]["returned"].intValue
//                           heroeMarvel.numSeries = subJson["series"]["returned"].intValue
//                           saveHeroeCoreData(marvelHeroe: heroeMarvel)
//                           heroesMarvel.append(heroeMarvel)
//                           heroeMarvel = MarvelHeroe()
//                       }
//         return heroesMarvel
//     }
}
