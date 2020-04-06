//
//  DetailCharacterModel.swift
//  MarvelWikiApp
//
//  Created by Marc Gallardo on 06/04/2020.
//  Copyright © 2020 Marc Gallardo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class DetailCharacter {
    var id: Int = 0
    var name: String?
    var thumbnail: String = ""
    var titleComics: [String] = []
    var titleSeries: [String] = []
}
