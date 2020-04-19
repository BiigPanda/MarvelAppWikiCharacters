//
//  DetailCharacterService.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 19/04/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class DetailCharacterService {
    
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
