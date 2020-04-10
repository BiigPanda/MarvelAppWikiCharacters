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
    var identifier: Int32?
    var name: String?
    var descrip: String?
    var thumbnail: String = ""
    var numComic: Int32?
    var numSeries: Int32?
    var totalHeroes: Int32?
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
    
    func callApiNextCharacters(numberOffset: String, completionHandler: @escaping (_ result: [MarvelHeroe], _ error: Error?) -> Void)  {
        var heroesNextMarvel : [MarvelHeroe] = []
        let endPointNextCharacters = "https://gateway.marvel.com:443/v1/public/characters?offset=\(numberOffset)&apikey=cc3e270d04c7e50ec7c7db921c88bb96&hash=b223b72d5f71869ad340852bad7669d5&ts=1"
        Alamofire.request(endPointNextCharacters).responseJSON { (response) in
            switch response.result {
                   case .success(_):
                       guard let result = response.result.value as? [String:Any] else{
                           assertionFailure()
                           return
                       }
                       let json = JSON(result)
                       heroesNextMarvel = self.parsedHeroe(json: json)
                       completionHandler(heroesNextMarvel,nil)
                       break
                   case .failure(let error):
                       completionHandler(heroesNextMarvel,error)
                       break
                   }
            
        }
    }

    
    func parsedHeroe(json: JSON) -> [MarvelHeroe] {
        var heroeMarvel = MarvelHeroe()
        var heroesMarvel : [MarvelHeroe] = []
        heroeMarvel.totalHeroes = Int32(json["data"]["total"].intValue)
        heroesMarvel.reserveCapacity(json["data"]["results"].count)
        for (_,subJson):(String, JSON) in json["data"]["results"] {
                          heroeMarvel.name = subJson["name"].stringValue
                          heroeMarvel.descrip = subJson["description"].stringValue
                          heroeMarvel.identifier = Int32(subJson["id"].intValue)
                          heroeMarvel.thumbnail = subJson["thumbnail"]["path"].stringValue + "." + subJson["thumbnail"]["extension"].stringValue
                          heroeMarvel.numComic = Int32(subJson["comics"]["returned"].intValue)
                          heroeMarvel.numSeries = Int32(subJson["series"]["returned"].intValue)
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
        heroeTask.setValue(marvelHeroe.totalHeroes, forKey: "totalHeroes")
        heroeTask.setValue(marvelHeroe.name, forKey: "name")
        heroeTask.setValue(marvelHeroe.descrip, forKey: "descrip")
        heroeTask.setValue(marvelHeroe.identifier, forKey: "identifier")
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
        var detailHeroe = DetailCharacter()
        
        let endPointDetailCharacter = "https://gateway.marvel.com:443/v1/public/characters/\(idDetailHeroe)?ts=1&apikey=cc3e270d04c7e50ec7c7db921c88bb96&hash=b223b72d5f71869ad340852bad7669d5"
        Alamofire.request(endPointDetailCharacter).responseJSON { (response) in
                 switch response.result {
                        case .success(_):
                            guard let result = response.result.value as? [String:Any] else{
                                assertionFailure()
                                return
                            }
                            let json = JSON(result)
                            detailHeroe = self.parsedDetailHeroe(json: json)
                            print(detailHeroe)
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
    
    func parsedDetailHeroe(json: JSON) -> DetailCharacter {
        let detailHeroe = DetailCharacter()
        print(json)
        for (_,subJson):(String, JSON) in json["data"]["results"] {
            detailHeroe.nameDetail = subJson["name"].stringValue
            detailHeroe.thumbnailDetail = subJson["thumbnail"]["path"].stringValue + "." + subJson["thumbnail"]["extension"].stringValue
            detailHeroe.idDetail = Int32(subJson["id"].intValue)
            for (_,subJsonComics):(String, JSON) in subJson["comics"]["items"] {
                detailHeroe.titleComics.append(subJsonComics["name"].stringValue)
            }
            for (_,subJsonComics):(String, JSON) in subJson["series"]["items"] {
               detailHeroe.titleSeries.append(subJsonComics["name"].stringValue)
           }
        }
        return detailHeroe
    }
}
