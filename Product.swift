//
//  Product.swift
//  hplus-sports
//
//  Created by Saul Mora on 2/12/17.
//  Copyright © 2017 Lynda.com. All rights reserved.
//

import Foundation

struct Product
{
  let id: String
  let name: String
  let description: String?
  let date: Date?
  fileprivate let imageURLString: String
  let imageTitle: String
  let formattedPrice: String?
  
  var imageURL: URL?
  {
    return URL(string: imageURLString)
  }
}


extension Product: JSONDecodable
{
  init(_ decoder: JSONDecoder) throws {
    self.id = try decoder.value(forKey: "id")
    self.name = try decoder.value(forKey: "name")
    self.imageTitle = try decoder.value(forKey: "image_title")
    self.imageURLString = try decoder.value(forKey: "image")
    
    self.description = try? decoder.value(forKey: "description")
    self.formattedPrice = try? decoder.value(forKey: "price")
    self.date = try? decoder.value(forKey: "date")
  }
}

