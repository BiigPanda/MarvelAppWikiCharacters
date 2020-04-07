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
    var idDetail: Int32?
    var nameDetail: String?
    var thumbnailDetail: String = ""
    var titleComics: [String] = []
    var titleSeries: [String] = []
}
