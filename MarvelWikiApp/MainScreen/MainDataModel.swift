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

class MarvelHeroe {
    var id: Int = 0
    var name: String = ""
    var descrip: String?
    var thumbnail: String = ""
    var numComic: Int?
    var numSeries: Int?
}

class MarvelHeroeService {
    
    func callAPICharacters() {
        var heroesMarvel = [MarvelHeroe()]
        //https://gateway.marvel.com:443/v1/public/characters?apikey=cc3e270d04c7e50ec7c7db921c88bb96
        //(ts+privateKey+publicKey) md5
        //public key  cc3e270d04c7e50ec7c7db921c88bb96
        // private key 6b649549dcb530ed40a88f00c2c86b0fe8c37846
        // ts 1
        // hash -- b223b72d5f71869ad340852bad7669d5
        // http://gateway.marvel.com/v1/public/comics?ts=1&apikey=cc3e270d04c7e50ec7c7db921c88bb96&hash=b223b72d5f71869ad340852bad7669d5
        //el siguiente paso es crear el objeto en el modelo y hacer las llamadas dejando libre el viewcontroller
        Alamofire.request("http://gateway.marvel.com/v1/public/characters?ts=1&apikey=cc3e270d04c7e50ec7c7db921c88bb96&hash=b223b72d5f71869ad340852bad7669d5", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
            switch response.result {
            case .success(_):
                guard let result = response.result.value as? [String:Any] else{
                    assertionFailure()
                    return
                }
                let json = JSON(result)
                heroesMarvel = self.parsedHeroe(json: json)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    //
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
                          heroesMarvel.append(heroeMarvel)
                          heroeMarvel = MarvelHeroe()
                      }
        return heroesMarvel
    }
}
